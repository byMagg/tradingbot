import 'package:flutter/material.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:start_chart/chart/candle/candle_widget.dart';
import 'package:start_chart/chart/candle/entity/candle_entity.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/models/Candle.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';

import 'package:tradingbot/widgets/SimpleLineChart.dart';

class CurrencyView extends StatefulWidget {
  final String symbol;
  final List<Order> orders;
  final List<KLineEntity> candles;

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
    DataUtil.calculate(widget
        .candles); //This function has some optional parameters: n is BOLL N-day closing price. k is BOLL param.

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
      // body: Stack(children: [
      //   Column(
      //     children: <Widget>[
      //       Container(
      //         color: Colors.white,
      //         child: Padding(
      //           padding: const EdgeInsets.all(8.0),
      //           child: Container(
      //               height: 250, child: SimpleLineChart.withSampleData()),
      //         ),
      //       ),
      //       Container(
      //         height: 70,
      //         color: Colors.white,
      //       )
      //     ],
      //   ),
      //   _listOperations(),
      body: Container(
        color: Colors.white,
        child: KChartWidget(
          widget
              .candles, // Required，Data must be an ordered list，(history=>now)/ Decide what the sub view shows
          fixedLength: 2, // Displayed decimal precision
          onLoadMore: (bool
              a) {}, // Called when the data scrolls to the end. When a is true, it means the user is pulled to the end of the right side of the data. When a
          // is false, it means the user is pulled to the end of the left side of the data.
          maDayList: [
            5,
            10,
            20
          ], // Display of MA,This parameter must be equal to DataUtil.calculate‘s maDayList
          bgColor: [
            Colors.black,
            Colors.black
          ], // The background color of the chart is gradient
          isOnDrag:
              (isDrag) {}, // true is on Drag.Don't load data while Draging.
        ),
        // child: OHLCVGraph(
        //     data: widget.candles, enableGridLines: true, volumeProp: 0.2),
      ),
      // ]),
    );
  }
}
