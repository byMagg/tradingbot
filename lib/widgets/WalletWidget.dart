import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/views/CurrencyView.dart';

import 'dart:async';

class WalletWidget extends StatefulWidget {
  final CoinbaseController controller;
  final StreamController streamController;

  WalletWidget(
      {Key key, @required this.controller, @required this.streamController})
      : super(key: key);

  @override
  WalletWidgetState createState() => WalletWidgetState();
}

class WalletWidgetState extends State<WalletWidget> {
  @override
  Widget build(BuildContext context) {
    double cardMargin = 5;

    return Expanded(
        child: StreamBuilder(
      stream: widget.streamController.stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                var it = snapshot.data[index];

                print(it);
                var number = NumberFormat.compactCurrency(
                        decimalDigits: 2, symbol: '\$ ')
                    .format(double.parse(it["value"]));
                return Card(
                  margin: EdgeInsets.only(
                      left: cardMargin, right: cardMargin, bottom: 10),
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CurrencyView(
                                symbol: it["currency"],
                              )));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.2 -
                          (cardMargin * 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 40,
                            child: Image(
                              image: AssetImage(
                                  'lib/assets/currencies/color/${it["currency"].toLowerCase()}.png'),
                            ),
                          ),
                          Text(
                            "$number",
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        } else {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ));
        }
      },
    ));
  }
}
