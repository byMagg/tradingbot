import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/MainController.dart';

class BalanceWidget extends StatefulWidget {
  BalanceWidget({Key key}) : super(key: key);

  @override
  BalanceWidgetState createState() => BalanceWidgetState();
}

class BalanceWidgetState extends State<BalanceWidget> {
  MainController mainController;

  @override
  void initState() {
    super.initState();
    this.mainController = new MainController();
  }

  @override
  Widget build(BuildContext context) {
    final _formatCurrency = new NumberFormat.simpleCurrency();
    double fontSize = MediaQuery.of(context).size.height * 0.03;

    return Container(
        color: Theme.of(context).primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Balance",
                style: TextStyle(fontSize: fontSize, color: Colors.white),
              ),
              StreamBuilder(
                  stream: this.mainController.initCurrencies(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      double balance = 0.0;
                      for (var item in snapshot.data.documents) {
                        balance += item['totalUSD'];
                      }
                      return Text(
                        '${_formatCurrency.format(balance)}',
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
