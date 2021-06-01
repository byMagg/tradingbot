import 'package:flutter/material.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/streams/BalanceStream.dart';
import 'package:tradingbot/streams/OrdersStream.dart';
import 'package:tradingbot/streams/ProductsStream.dart';
import 'package:tradingbot/widgets/BalanceWidget.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';
import 'package:tradingbot/widgets/ProductsWidget.dart';
import 'package:tradingbot/widgets/WalletWidget.dart';
import 'package:tradingbot/widgets/PagesWidget.dart';

import 'OperationsView.dart';

class MainPage extends StatelessWidget {
  const MainPage({
    Key key,
    @required this.expandedHeight,
    @required this.resultOrders,
  }) : super(key: key);

  final double expandedHeight;
  final List<Order> resultOrders;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            height: 370,
            child: StreamBuilder(
                stream: productsStream.stream,
                builder: (context, AsyncSnapshot<List<Product>> snapshot) {
                  if (snapshot.hasData) {
                    snapshot.data.sort((a, b) => a.id.compareTo(b.id));
                    return ProductsWidget(products: snapshot.data);
                  }
                  return Center(child: CircularProgressIndicator());
                })),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Divider(
            thickness: 2,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        ),
        PagesWidget(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Divider(
            thickness: 2,
            color: Theme.of(context).primaryColor.withOpacity(0.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Align(
            alignment: Alignment.center,
            child: Text(
              "Recent operations",
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        StreamBuilder(
            stream: ordersStream.stream,
            builder: (context, AsyncSnapshot<List<Order>> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    OperationsWidget(
                      everything: false,
                      fixed: true,
                      orders: snapshot.data,
                    ),
                    MaterialButton(
                      height: 50,
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Center(child: Text("View more")),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => OperationsView(
                                  orders: resultOrders,
                                )));
                      },
                    ),
                  ],
                );
              }
              return Container(
                  height: 350,
                  child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text("Loading recent operations..."),
                        )
                      ])));
            }),
      ],
    );
  }
}
