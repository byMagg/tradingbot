import 'package:flutter/material.dart';

class TitleWidget extends StatelessWidget {
  final double fontSize;

  TitleWidget(this.fontSize);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Trading",
          style: TextStyle(
            letterSpacing: 1,
            fontSize: this.fontSize,
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontFamily: 'Montserrat',
          ),
        ),
        Text(
          "BOT",
          style: TextStyle(
            color: Colors.white,
            fontSize: this.fontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
          ),
        ),
      ],
    );
  }
}
