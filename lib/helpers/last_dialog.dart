import 'package:flutter/material.dart';
import '../app_colors.dart';

//
// Widget playAgainDialog(BuildContext context, Function reset, bool isWhite) {
//   return
// }

class PlayAgainDialog extends StatelessWidget {
  final Function reset;
  final bool isWhite;
  const PlayAgainDialog({Key? key, required this.reset, required this.isWhite}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("CHECK MATE!", style: TextStyle(letterSpacing: 2, fontSize: 30 ),),
      content:  Text(isWhite ? "White win" : "Black win"),
      actions: <Widget>[
        TextButton(
            onPressed: () {
              reset();
              Navigator.of(context).pop();
            },
            child:  Text(
              "Play again",
              style: TextStyle(color: AppColors.tileColor2, fontSize: 17),
            ))
      ],
    );
  }
}











