#! /bin/sh
project=shot
input='{
	"xCoord":3,
	"yCoord":3,
	"xCoords":[0,1,2,3,4,5,6,7,8,9],
	"yCoords":[0,1,2,3,4,5,6,7,8,9],
	"expBoardHash": "871153728749625219211668493470620319107635849458208915140047406307843302106",
	"hit": 1
}'

# Compile
circom $project.circom --r1cs --wasm --sym --c

# Generate Witness
cd ${project}_js
echo $input > input.json
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
