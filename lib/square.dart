import 'package:chess/piece.dart';
import 'package:flutter/material.dart';
import './app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SquareTile extends StatelessWidget {
  final bool isTileWhite;
  final bool isSelected;
  final bool isValidMove;
  final ChessPiece? chessPiece;
  final Function onTap;

  const SquareTile({Key? key, required this.isTileWhite, this.chessPiece, required this.onTap, required this.isSelected, required this.isValidMove})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Color squareColor;

    if(isSelected || isValidMove){
      squareColor = AppColors.selectedColor;
    }
    else{
      squareColor = isTileWhite ? AppColors.tileColor1 : AppColors.tileColor2;
    }

    return GestureDetector(
      onTap: (){
        onTap();
        },
      child: Container(
        color:squareColor,
        margin: EdgeInsets.all(isValidMove ? 8 : 0),
        child: chessPiece ==null? null : SvgPicture.asset(
            chessPiece!.imgPath,
            colorFilter: chessPiece!.isWhite
                ?  ColorFilter.mode(Colors.white.withOpacity(0.6).withAlpha(180), BlendMode.srcATop)
                : null,
        ),
      ),
    );
  }
}


