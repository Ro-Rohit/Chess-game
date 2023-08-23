
 import '../piece.dart';

 List<List<ChessPiece?>>  arrangeToInitial(){
    late List<List<ChessPiece?>> board;
   board = List.generate(8, (i) => List.filled(8, null, growable: false), growable: false);

   //pawn placement
   List.generate(8, (i) {
     board[1][i] = ChessPiece(type: PieceType.pawn, imgPath: 'images/Chess_pdt45.svg', isWhite: true);
     board[6][i] = ChessPiece(type: PieceType.pawn, imgPath: 'images/Chess_pdt45.svg', isWhite: false);
   });

   // //king placement
   board[0][4] = ChessPiece(type: PieceType.king, imgPath: 'images/Chess_kdt45.svg', isWhite: true);
   board[7][4] = ChessPiece(type: PieceType.king, imgPath: 'images/Chess_kdt45.svg', isWhite: false);

   // //queen placement
   board[0][3] = ChessPiece(type: PieceType.queen, imgPath: 'images/Chess_qdt45.svg', isWhite: true);
   board[7][3] = ChessPiece(type: PieceType.queen, imgPath: 'images/Chess_qdt45.svg', isWhite: false);

   // //bishop
   board[0][2] = ChessPiece(type: PieceType.bishop, imgPath: 'images/Chess_bdt45.svg', isWhite: true);
   board[0][5] = ChessPiece(type: PieceType.bishop, imgPath: 'images/Chess_bdt45.svg', isWhite: true);
   board[7][2] = ChessPiece(type: PieceType.bishop, imgPath: 'images/Chess_bdt45.svg', isWhite: false);
   board[7][5] = ChessPiece(type: PieceType.bishop, imgPath: 'images/Chess_bdt45.svg', isWhite: false);

   // //knight
   board[0][1] = ChessPiece(type: PieceType.knight, imgPath: 'images/Chess_ndt45.svg', isWhite: true);
   board[0][6] = ChessPiece(type: PieceType.knight, imgPath: 'images/Chess_ndt45.svg', isWhite: true);
   board[7][1] = ChessPiece(type: PieceType.knight, imgPath: 'images/Chess_ndt45.svg', isWhite: false);
   board[7][6] = ChessPiece(type: PieceType.knight, imgPath: 'images/Chess_ndt45.svg', isWhite: false);


   // //rook
   board[0][0] = ChessPiece(type: PieceType.rook, imgPath: 'images/Chess_rdt45.svg', isWhite: true);
   board[0][7] = ChessPiece(type: PieceType.rook, imgPath: 'images/Chess_rdt45.svg', isWhite: true);
   board[7][0] = ChessPiece(type: PieceType.rook, imgPath: 'images/Chess_rdt45.svg', isWhite: false);
   board[7][7] = ChessPiece(type: PieceType.rook, imgPath: 'images/Chess_rdt45.svg', isWhite: false);

   return board;
 }


 bool isWhite(int index){
   var x = index ~/ 8;
   var y  = index % 8;
   return (x+y) %2==0;
 }


