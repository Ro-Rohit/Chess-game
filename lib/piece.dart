enum PieceType{
  pawn,
  king,
  queen,
  bishop,
  knight,
  rook
}

class ChessPiece {
  final PieceType type;
  final String imgPath;
  final bool isWhite;

  ChessPiece({required this.type, required this.imgPath, required this.isWhite });

}

