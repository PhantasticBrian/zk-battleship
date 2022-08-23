pragma circom 2.0.0;

include "../helpers/mimcsponge.circom"; 

template VerifyBoard () {  

	// Declaration of signals 
	signal input xCoords[10];
	signal input yCoords[10];
	signal output boardHash;

	// Check duplicates
	for (var i = 0; i < 10; i++) {
		for (var j = 0; j < 10; j++) {
			if (i != j) {
				assert(xCoords[i] != xCoords[j] || yCoords[i] != yCoords[j]);
			}
		}
	}

	// Validate bounds
	for (var i = 0; i < 10; i++) {
		assert(xCoords[i] >= 0);
		assert(xCoords[i] <= 9);
		assert(yCoords[i] >= 0);
		assert(yCoords[i] <= 9);
	}

	// Generate hash
	component mimc = MiMCSponge(20, 220, 1);
	for (var i = 0; i < 10; i++) {
		mimc.ins[i] <== xCoords[i];
		mimc.ins[i+10] <== yCoords[i];
	}
	mimc.k <== 0;

	boardHash <== mimc.outs[0];

}

// component main = VerifyBoard();