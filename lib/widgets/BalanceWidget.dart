import 'dart:async';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/controllers/MainController.dart';

class BalanceWidget extends StatefulWidget {
  BalanceWidget({Key key}) : super(key: key);

  @override
  BalanceWidgetState createState() => BalanceWidgetState();
}

class BalanceWidgetState extends State<BalanceWidget> {
  CoinbaseController mainController;
  StreamController streamController;

  @override
  void initState() {
    super.initState();
    this.mainController = new CoinbaseController();
    this.streamController = new StreamController();

    _loadToStream();
  }

  _loadToStream() async {
    this
        .streamController
        .add(await this.mainController.getBalance().then((value) => value));
    Timer.periodic(Duration(seconds: 5), (timer) async {
      return this
          .streamController
          .add(await this.mainController.getBalance().then((value) => value));
    });
  }

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
                  stream: this.streamController.stream,
                  builder: (context, snapshot) {
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
