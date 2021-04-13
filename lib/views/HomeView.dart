import 'package:flutter/material.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/streams/BalanceStream.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/streams/OrdersStream.dart';
import 'package:tradingbot/streams/ProductsStream.dart';
import 'package:tradingbot/views/PricesView.dart';
import 'package:tradingbot/widgets/BalanceWidget.dart';
import 'package:tradingbot/widgets/BarChartWidget.dart';
import 'package:tradingbot/widgets/LineChartWidget.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';
import 'package:tradingbot/widgets/ProductsWidget.dart';
import 'package:tradingbot/widgets/TitleWidget.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Wallet.dart';

import 'dart:async';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tradingbot/widgets/WalletWidget.dart';

import 'OperationsView.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Widget drawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            child: TitleWidget(25),
            height: 200,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            title: Text('Page 1'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Page 2'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget page(Widget widget) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 35, left: 12, right: 12),
        child: Column(children: [Expanded(child: widget)]),
      ),
    );
  }

  CoinbaseController coinbaseController = new CoinbaseController();
  double resultNumber = -1;
  List<Wallet> resultWallets = [];
  List<Order> resultOrders = [];
  List<KLineEntity> resultCandles = [];

   final BehaviorSubject<List<Product>> _productsStream =
      BehaviorSubject<List<Product>>();

  Balance initialBalance;

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(seconds: 30), (Timer t) async {
      ordersStream.fetchData();
    });

    Timer.periodic(Duration(seconds: 5), (Timer t) async {
      balanceStream.fetchData();
      productsStream.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    final expandedHeight = MediaQuery.of(context).size.height * 0.24;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 50;

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.white,
          drawer: drawer(),
          appBar: AppBar(
            elevation: 0,
            title: TitleWidget(25),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.account_balance_wallet),
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => PricesView()));
                  }),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                  height: expandedHeight,
                  width: MediaQuery.of(context).size.width,
                  color: Theme.of(context).primaryColor,
                  child: StreamBuilder(
                      stream: balanceStream.stream,
                      builder: (context, AsyncSnapshot<Balance> snapshot) {
                        if (snapshot.hasData) {
                          return Column(
                            children: <Widget>[
                              BalanceWidget(
                                  totalBalance: snapshot.data.totalBalance),
                              WalletWidget(
                                wallets: snapshot.data.wallets,
                              )
                            ],
                          );
                        }
                        return Column(
                          children: [
                            LinearProgressIndicator(
                              backgroundColor: Colors.white,
                            ),
                            Expanded(
                              child: Center(
                                  child: Text(
                                "We are loading your wallets...",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )),
                            ),
                          ],
                        );
                      }),
                ),
                Container(
                  height: 320,
                  child: FutureBuilder(
                      future: CoinbaseController.getProducts(),
                      builder:
                          (context, AsyncSnapshot<List<Product>> snapshot) {
                        if (snapshot.hasData) {
                          snapshot.data.sort((a, b) => a.id.compareTo(b.id));
                          return ProductsWidget(products: snapshot.data);
                        }
                        return CircularProgressIndicator();
                      }),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Divider(
                    thickness: 2,
                    color: Theme.of(context).primaryColor.withOpacity(0.5),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height -
                      expandedHeight -
                      statusBarHeight -
                      appBarHeight,
                  alignment: Alignment.center,
                  child: Stack(
                    children: [
                      PageView(
                        controller: controller,
                        children: <Widget>[
                          page(LineChartWidget()),
                          page(BarChartWidget()),
                          page(LineChartWidget()),
                          page(BarChartWidget()),
                        ],
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 15),
                          child: SmoothPageIndicator(
                            controller: controller,
                            count: 4,
                            effect: ExpandingDotsEffect(
                                dotHeight: 5,
                                dotWidth: 15,
                                expansionFactor: 3,
                                activeDotColor: Theme.of(context).primaryColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
            ),
          ),
        ));
  }
}
