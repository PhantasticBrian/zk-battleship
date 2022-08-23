pragma circom 2.0.0;

include "../board/board.circom";

template VerifyShot () {  

  // Declaration of signals.  
  signal input xCoord;
  signal input yCoord;
  signal input xCoords[10];
  signal input yCoords[10];
  signal input expBoardHash;
  signal input hit;

	// Validate board
  component boardHasher = VerifyBoard();
  for (var i = 0; i < 10; i++) {
    boardHasher.xCoords[i] <== xCoords[i];
    boardHasher.yCoords[i] <== yCoords[i];
  }
  expBoardHash === boardHasher.boardHash;

	// Validate bounds
  assert(xCoord >= 0);
  assert(xCoord <= 9);
  assert(yCoord >= 0);
  assert(yCoord <= 9);

  // Validate shot
  var realHit = 0;
  for (var i = 0; i < 10; i++) {
    if (xCoords[i] == xCoord) {
      if (yCoords[i] == yCoord) {
        realHit = 1;
      }
    }
  }
  assert(hit == realHit);
}

component main {public [xCoord, yCoord, expBoardHash, hit]} = VerifyShot();