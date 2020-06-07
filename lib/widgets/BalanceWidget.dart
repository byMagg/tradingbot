import 'dart:async';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';

class BalanceWidget extends StatefulWidget {
  final CoinbaseController controller;
  final StreamController streamController;

  BalanceWidget(
      {Key key, @required this.controller, @required this.streamController})
      : super(key: key);

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
              StreamBuilder(
                  stream: widget.streamController.stream,
                  builder: (context, snapshot) {
                    print(snapshot.data);
                    if (snapshot.hasData) {
                      double number = double.parse(snapshot.data);

                      return Text(
                        '${_formatCurrency.format(number)}',
                        style: TextStyle(
                            fontSize: fontSize, color: Colors.white54),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  }),
            ],
          ),
        ));
  }
}
