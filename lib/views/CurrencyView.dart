import 'package:flutter/material.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/streams/BalanceStream.dart';
import 'package:tradingbot/streams/OrdersStream.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';

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
                StreamBuilder(
                    stream: ordersStream.stream,
                    builder: (context, AsyncSnapshot<List<Order>> snapshot) {
                      if (snapshot.hasData) {
                        List<Order> specificOrders =
                            CoinbaseController.getSpecificOrders(
                                widget.symbol, snapshot.data);

                        print(snapshot.data);
                        return OperationsWidget(
                          everything: true,
                          fixed: true,
                          orders: specificOrders,
                        );
                      }
                      return CircularProgressIndicator();
                    }),
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
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 250,
                  //  child: SimpleLineChart.withSampleData()
                ),
              ),
            ),
            Container(
              height: 70,
              color: Colors.white,
            )
          ],
        ),
        _listOperations(),
      ]),
    );
  }
}
