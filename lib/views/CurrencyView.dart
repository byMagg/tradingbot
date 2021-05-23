import 'package:flutter/material.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/streams/OrdersStream.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CurrencyView extends StatefulWidget {
  final String symbol;

  CurrencyView({
    Key key,
    @required this.symbol,
  }) : super(key: key);

  @override
  _CurrencyViewState createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  _listOperations() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
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
          StreamBuilder(
              stream: ordersStream.stream,
              builder: (context, AsyncSnapshot<List<Order>> snapshot) {
                if (snapshot.hasData) {
                  List<Order> specificOrders =
                      CoinbaseController.getSpecificOrders(
                          widget.symbol, snapshot.data);

                  return OperationsWidget(
                    everything: true,
                    fixed: true,
                    orders: specificOrders,
                  );
                }
                return Container(
                  height: 350,
                  child: Align(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white,
                      )),
                );
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).primaryColor,
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
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            height: 270,
            child: FutureBuilder(
                future: CoinbaseController.getHistoricCurrency(
                    "f6f21298-0b69-4a59-97d5-ea4cd12a3722"),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<charts.Series<HistoricCurrency, DateTime>>
                        _createData() {
                      return [
                        new charts.Series<HistoricCurrency, DateTime>(
                          id: 'Sales',
                          colorFn: (_, __) =>
                              charts.MaterialPalette.blue.shadeDefault,
                          domainFn: (HistoricCurrency sales, _) => sales.time,
                          measureFn: (HistoricCurrency sales, _) =>
                              sales.balance,
                          data: snapshot.data,
                        )
                      ];
                    }

                    return SimpleTimeSeriesChart(
                      _createData(),
                      lines: true,
                    );
                  }
                  return LinearProgressIndicator();
                }),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: _listOperations(),
          )
        ]),
      ),
    );
  }
}
