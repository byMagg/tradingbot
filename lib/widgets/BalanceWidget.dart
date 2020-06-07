import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';

class BalanceWidget extends StatefulWidget {
  final Stream stream;

  BalanceWidget({Key key, @required this.stream}) : super(key: key);

  @override
  BalanceWidgetState createState() => BalanceWidgetState();
}

class BalanceWidgetState extends State<BalanceWidget> {
  @override
  Widget build(BuildContext context) {
    final _formatCurrency = new NumberFormat.simpleCurrency();
    double fontSize = MediaQuery.of(context).size.height * 0.03;

    CoinbaseController controller = new CoinbaseController();

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
                  stream: widget.stream,
                  builder: (context, snapshot) {
                    print(snapshot.data);
                    print(snapshot.connectionState);
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
