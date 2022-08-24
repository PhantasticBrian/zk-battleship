#! /bin/sh
project=board

# Compile
circom $project.circom --r1cs --wasm --sym --c

# Generate Witness
cd ${project}_js
echo '{"xCoords":[0,0,2,3,4,5,6,7,8,9],"yCoords":[0,0,2,3,4,5,6,7,8,9]}' > input.json
node generate_witness.js $project.wasm input.json witness.wtns
cd ..

# Powers of Tau
# phase 1
snarkjs powersoftau new bn128 15 pot12_0000.ptau -v
snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v

# phase 2
snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v
snarkjs groth16 setup $project.r1cs pot12_final.ptau ${project}_0000.zkey
snarkjs zkey contribute ${project}_0000.zkey ${project}_0001.zkey --name="1st Contributor" -v
snarkjs zkey export verificationkey ${project}_0001.zkey verification_key.json

# Generating a Proof
snarkjs groth16 prove ${project}_0001.zkey ${project}_js/witness.wtns proof.json public.json

# Verifying a Proof
snarkjs groth16 verify verification_key.json public.json proof.json
