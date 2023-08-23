import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DeadPiece extends StatelessWidget {
  final String imgPath;
  final bool isWhite;
  final Function onTap;
  const DeadPiece({Key? key, required this.imgPath, required this.isWhite, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap : (){
        onTap();
      },
      child: SvgPicture.asset(
        imgPath,
        fit: BoxFit.contain,
        colorFilter: isWhite
            ?  ColorFilter.mode(Colors.white.withOpacity(0.6).withAlpha(180), BlendMode.srcATop)
            : null,
      ),
    );
  }
}
