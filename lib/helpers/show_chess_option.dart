import 'package:chess/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../piece.dart';

class ShowChessOption extends StatefulWidget {
  final bool isWhite;
  final Function substitutePiece;
  const ShowChessOption({Key? key, required this.isWhite, required this.substitutePiece}) : super(key: key);

  @override
  State<ShowChessOption> createState() => _ShowChessOptionState();
}

class _ShowChessOptionState extends State<ShowChessOption> {

  double size = 40;
   ChessPiece? selectedPiece;

  List<bool> activeList = List.generate(4, (index) => false);

  List<ChessPiece> chessPieces = [
    ChessPiece(type: PieceType.queen, imgPath: 'images/Chess_qdt45.svg', isWhite: true),
    ChessPiece(type: PieceType.bishop, imgPath: 'images/Chess_bdt45.svg', isWhite: true),
    ChessPiece(type: PieceType.rook, imgPath: 'images/Chess_rdt45.svg', isWhite: true),
    ChessPiece(type: PieceType.knight, imgPath: 'images/Chess_ndt45.svg', isWhite: true),
  ];


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title:  Text("Pick a Piece!", style: TextStyle(letterSpacing: 2, fontSize: 30, color: AppColors.tileColor2 ),),
      content:  Wrap(
        spacing: 50,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: List.generate(chessPieces.length, (i){
          return Container(
            height:  50,
            width:  50,
            decoration:  BoxDecoration(
              shape: BoxShape.circle,
              border: activeList[i]
                  ? Border.all(color:  Colors.greenAccent, width: 3)
                  : Border.all(color:  AppColors.tileColor2, width: 1)
            ),
            child: InkWell(
              onTap: (){
                activeList = activeList = List.generate(5, (index) => false);
                setState( () {
                      activeList[i] = true;
                      selectedPiece = chessPieces[i];
                });

              },
              child: SvgPicture.asset(
                chessPieces[i].imgPath,
                fit: BoxFit.contain,
                colorFilter: widget.isWhite
                    ?  ColorFilter.mode(Colors.white.withOpacity(0.6).withAlpha(180), BlendMode.srcATop)
                    : null,
              ),
            ),
          );
        }),
      ),
      actions: <Widget>[
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: AppColors.tileColor2,
            foregroundColor: Colors.white,
            elevation: 20, //<-- SEE HERE
            shadowColor: Colors.grey.shade200.withOpacity(0.3), //<-- SEE HERE
          ),
          onPressed: selectedPiece ==null ? null : () {
            widget.substitutePiece(selectedPiece);
            Navigator.pop(context);
          },
          child: const Text(
            'Okay',
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

}
