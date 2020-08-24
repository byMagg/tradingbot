import 'package:flutter/material.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/models/Candle.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';

import 'package:tradingbot/widgets/SimpleLineChart.dart';

class CurrencyView extends StatefulWidget {
  final String symbol;
  final List<Order> orders;
  final List candles;

  CurrencyView(
      {Key key,
      @required this.orders,
      @required this.symbol,
      @required this.candles})
      : super(key: key);

  @override
  _CurrencyViewState createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  _listOperations() {
    List<Order> specificOrders =
        CoinbaseController.getSpecificOrders(widget.symbol, widget.orders);

    return Container(
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 270,
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Operations",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                OperationsWidget(
                  everything: true,
                  fixed: true,
                  orders: specificOrders,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 25,
              child: Image(
                image: AssetImage(
                    'lib/assets/currencies/color/${widget.symbol.toLowerCase()}.png'),
              ),
            ),
            SizedBox(width: 10),
            Text(widget.symbol)
          ],
        ),
      ),
      body: Stack(children: [
        Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: OHLCVGraph(
                  data: widget.candles, enableGridLines: true, volumeProp: 0.2),
            ),
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    height: 250, child: SimpleLineChart.withSampleData()),
              ),
            ),
            Container(
              height: 70,
              color: Colors.white,
            )
          ],
        ),
        _listOperations()
      ]),
    );
  }
}
