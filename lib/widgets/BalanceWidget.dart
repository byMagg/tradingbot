import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'dart:async';

class BalanceWidget extends StatefulWidget {
  final Future<double> number;
  BalanceWidget({Key key, @required this.number}) : super(key: key);

  @override
  BalanceWidgetState createState() => BalanceWidgetState();
}

class BalanceWidgetState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    final _formatCurrency = new NumberFormat.simpleCurrency();
    double fontSize = MediaQuery.of(context).size.height * 0.03;

    return Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            children: [
              Text(
                "Balance",
                style: TextStyle(fontSize: fontSize, color: Colors.white),
              ),
              FutureBuilder(
                  future: widget.number,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        '${_formatCurrency.format(snapshot.data)}',
                        style: TextStyle(
                            fontSize: fontSize, color: Colors.white54),
                      );
                    } else {
                      return Text(
                        '${_formatCurrency.format(0)}',
                        style: TextStyle(
                            fontSize: fontSize, color: Colors.white54),
                      );
                    }
                  }),
            ],
          ),
        ));
  }
}
