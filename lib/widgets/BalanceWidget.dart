import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

class BalanceWidget extends StatefulWidget {
  final double number;
  BalanceWidget({Key key, @required this.number}) : super(key: key);

  @override
  BalanceWidgetState createState() => BalanceWidgetState();
}

class BalanceWidgetState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    double fontSize = MediaQuery.of(context).size.height * 0.03;

    return Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: (widget.number == 0)
              ? LinearProgressIndicator(
                  backgroundColor: Colors.white,
                )
              : Column(
                  children: [
                    Text(
                      "Balance",
                      style: TextStyle(fontSize: fontSize, color: Colors.white),
                    ),
                    Text(
                      '${NumberFormat.simpleCurrency().format(widget.number)}',
                      style:
                          TextStyle(fontSize: fontSize, color: Colors.white54),
                    )
                  ],
                ),
        ));
  }
}
