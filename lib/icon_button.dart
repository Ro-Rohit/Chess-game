import 'package:chess/app_colors.dart';
import 'package:flutter/material.dart';

class IconButtonWidget extends StatelessWidget {
  final IconData icon;
  final Function onTap;
  const IconButtonWidget({Key? key, required this.icon, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 30, color: AppColors.tileColor1,),
      onPressed: (){onTap();},);
  }
}
