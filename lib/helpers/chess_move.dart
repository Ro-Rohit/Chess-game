import 'package:chess/piece.dart';


//calculate valid Move for king
List<List<int>> calculateRealValidMoves( int row, int  col, ChessPiece? piece, bool checkSimulation,
    List<List<ChessPiece?>> board, List<int> whiteKingPosition, List<int>blackKingPosition,
    ){

  List<List<int>> realValidMoves = [];

  //possible moves for a pieces if king is not under attack
  List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece, board);

  if(checkSimulation){
    for(var move in candidateMoves){
      int targetRow  = move[0];
      int targetCol  = move[1];

      //is Piece's king safe by taking target move?
      if(simulatedMoveIsSafe( row, col, targetRow, targetCol, piece, board,
          whiteKingPosition, blackKingPosition))
      {
        realValidMoves.add([targetRow, targetCol]);
      }
    }
  }
  else{
    realValidMoves = candidateMoves;
  }

  return realValidMoves;

}



// simulate A Future move
bool simulatedMoveIsSafe(int currentRow, int currentCol, int targetRow, int targetCol,
    ChessPiece? piece, List<List<ChessPiece?>> board,
    List<int> whiteKingPosition, List<int>blackKingPosition,
    ){

  //save the current board state
  ChessPiece? originalDestinationPiece = board[targetRow][targetCol];

  //if the piece is king, save it's current position and update to the new one
  List<int>? originalKingPosition;
  if(piece!.type == PieceType.king){
    originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;
    if(piece.isWhite){
      whiteKingPosition = [targetRow, targetCol];
    }else{
      blackKingPosition = [targetRow, targetCol];
    }
  }


  // simulate move
  board[targetRow][targetCol] = piece;
  board[currentRow][currentCol] = null;


  //check if our own king under attack
  bool kingInCheck = isKingInCheck(piece.isWhite,  whiteKingPosition,  blackKingPosition, board);

  // restore board to initial state
  board[currentRow][currentCol] = piece;
  board[targetRow][targetCol] = originalDestinationPiece;

  //if the piece was the king, restore it original position!
  if(piece.type ==PieceType.king){
    if(piece.isWhite){
      whiteKingPosition = originalKingPosition!;
    }else{
      blackKingPosition = originalKingPosition!;
    }
  }

  //if king is in check, means it under attack
  return !kingInCheck;
}



bool isKingInCheck(bool isWhiteKing, List<int> whiteKingPosition, List<int>blackKingPosition,
    List<List<ChessPiece?>> board){

  List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;


  //check if any enemies piece are attacking
  for(int i =0; i<8; i++){
    for(int j =0; j<8; j++){
      if(board[i][j] ==null || board[i][j]!.isWhite == isWhiteKing){
        continue;
      }
      else{
        //calculate raw valid moves
        List<List<int>> pieceValidMoves = calculateRawValidMoves(i, j, board[i][j],board,);

        //now check piece validMoves contains kingPosition
        if (pieceValidMoves.any((move) =>
        move[0]==kingPosition[0] && move[1] ==kingPosition[1]))
        {
          return true;
        }
      }
    }
  }
  return false;
}


List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece,
    List<List<ChessPiece?>> piecesArrangement){
  List<List<int>> candidateMoves = [];

  switch(piece!.type){
    case PieceType.pawn:
      candidateMoves = pawnMovingOption(row, col, piece, piecesArrangement);
      break;
    case PieceType.rook:
      candidateMoves = rookMovingOption(row, col, piece, piecesArrangement);
      break;

    case PieceType.knight:
      candidateMoves = knightMovingOption(row, col, piece, piecesArrangement);
      break;

    case PieceType.queen:
      candidateMoves = queenMovingOption(row, col, piece, piecesArrangement);
      break;

    case PieceType.king:
      candidateMoves = kingMovingOption(row, col, piece, piecesArrangement);
      break;

    case PieceType.bishop:
      candidateMoves = bishopMovingOption(row, col, piece, piecesArrangement);
      break;
    default:
      break;
  }

  return candidateMoves;

}


bool isOnBoard(int row, int col) {
  if (row < 8 && row >= 0 && col < 8 && col >= 0) {
    return true;
  }
  return false;
}

bool isPiecesHaveDifType(int row, int col, ChessPiece piece,
    List<List<ChessPiece?>> piecesArrangement){
  if(piecesArrangement[row][col]!.isWhite != piece.isWhite){
    return true;
  }
  return false;
}


bool isPieceExists(int row, int col,
    List<List<ChessPiece?>> piecesArrangement){
  if(piecesArrangement[row][col] != null){
    return true;
  }
  return false;
}



List<List<int>> checkPossiblePath(
    List<List<int>> directions,
    int row, int col, ChessPiece piece,
    List<List<ChessPiece?>>piecesArrangement,
    List<List<int>>candidateMove){

  for (var direction in directions) {
    var i = 1;
    while (true) {
      var cordY = row + i * direction[0];
      var cordX = col + i * direction[1];
      if (isOnBoard(cordY, cordX)) {
        if (isPieceExists(cordY, cordX, piecesArrangement)) {
          if(isPiecesHaveDifType(cordY, cordX, piece, piecesArrangement)){
            candidateMove.add([cordY, cordX]);
            break;
          }else{
            break;
          }
        }
        else{
          candidateMove.add([cordY, cordX]);
          i++;
        }
      }else{
        break;
      }
    }
  }
  return candidateMove;
}



List<List<int>> pawnMovingOption(int row, int col, ChessPiece piece,
    List<List<ChessPiece?>> piecesArrangement) {

  List<List<int>> candidateMoves = [];
  int direction = piece.isWhite ? 1 : -1;

  //pawns move by 1 if onboard and
  if (isOnBoard(row + direction, col) && !isPieceExists(row + direction, col, piecesArrangement)
  ){
    candidateMoves.add([row + direction, col]);
  }


  // initial move for white  && black piece (1 or 2) steps
  if (((row == 1 && piece.isWhite) ||(row == 6 && !piece.isWhite)) &&
      (
          !isPieceExists(row + 2 *direction, col,  piecesArrangement)
      )

    ) {candidateMoves.add([row + 2 * direction, col]);}


  // pawn kills diagonally on right side
  if (isOnBoard(row + direction, col + 1) &&
      isPieceExists(row + direction, col + 1, piecesArrangement) &&
      isPiecesHaveDifType(row+direction, col +1, piece, piecesArrangement)

    ) {candidateMoves.add([row + direction, col + 1]);}


  // pawn kills diagonally on left side
  if (isOnBoard(row + direction, col - 1) &&
      isPieceExists(row + direction, col - 1,  piecesArrangement) &&
      isPiecesHaveDifType(row+direction, col -1, piece, piecesArrangement)

  ) {candidateMoves.add([row + direction, col - 1]);}

  return candidateMoves;
}

List<List<int>> rookMovingOption(int row, int col, ChessPiece piece,
    List<List<ChessPiece?>> piecesArrangement) {
  List<List<int>> candidateMove = [];
  var directions = [
    [-1, 0], //up
    [1, 0], //down
    [0, -1], //left
    [0, 1]
  ]; //right
  return checkPossiblePath(directions, row, col, piece, piecesArrangement, candidateMove);
}


List<List<int>> bishopMovingOption(int row, int col, ChessPiece piece,
    List<List<ChessPiece?>> piecesArrangement) {
  List<List<int>> candidateMove = [];

  var directions = [
    [-1, -1], //left up diagonal
     [-1, 1],  // right up diagonal
     [1, -1],  // left down diagonal
    [1, 1],  //right down diagonal
  ];
  return checkPossiblePath(directions, row, col, piece, piecesArrangement, candidateMove);
}

List<List<int>> queenMovingOption(int row, int col, ChessPiece piece,
    List<List<ChessPiece?>> piecesArrangement) {
  List<List<int>> candidateMove = [];
  var directions = [

    [-1, -1], //left up diagonal
    [-1, 1],  // right up diagonal
    [1, -1],  // left down diagonal
    [1, 1],  //right down diagonal
    [-1, 0], // up
    [1, 0], // down
    [0, -1],  //left
    [0, 1],  //right
  ];

  return checkPossiblePath(directions, row, col, piece, piecesArrangement, candidateMove);
}


List<List<int>> knightMovingOption(int row, int col, ChessPiece piece,
    List<List<ChessPiece?>> piecesArrangement) {
  List<List<int>> candidateMove = [];
  var directions = [

    [-1, -2], //left up
    [1, -2], //left down
    [-1, 2], //right up
    [1, 2],  //right down
    [2, -1],  //down left
    [2, 1],  //down right
    [-2, -1],  //up left
    [-2, 1],  //up right
  ];

  for(var pos in directions){
    var cordY = row+ pos[0];
    var cordX = col + pos[1];
    if (isOnBoard(cordY, cordX)) {
      if ( isPieceExists(cordY, cordX,  piecesArrangement) &&
          !isPiecesHaveDifType(cordY, cordX, piece, piecesArrangement)) {
        continue;
      }
      else {
        candidateMove.add([cordY, cordX]);
      }
    }
  }
  return candidateMove;
}


List<List<int>> kingMovingOption(int row, int col, ChessPiece piece,
    List<List<ChessPiece?>> piecesArrangement) {
  List<List<int>> candidateMove = [];
  var directions = [

    [-1, -1], //left up diagonal
    [-1, 1],  // right up diagonal
    [1, -1],  // left down diagonal
     [1, 1],  //right down diagonal
    [-1, 0], // up
    [1, 0], // down
    [0, -1],  //left
    [0, 1],  //right
  ];

  for(var pos in directions){
    var cordY = row+ pos[0];
    var cordX = col + pos[1];
    if (isOnBoard(cordY, cordX)) {
      if (isPieceExists(cordY, cordX, piecesArrangement)&&
          !isPiecesHaveDifType(cordY, cordX, piece, piecesArrangement)) {
        continue;
      }
      else {
        candidateMove.add([cordY, cordX]);
      }
    }
  }
  return candidateMove;
}









