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
import 'package:tradingbot/views/MainPage.dart';

import 'package:tradingbot/widgets/BalanceWidget.dart';
import 'package:tradingbot/widgets/BarChartWidget.dart';
import 'package:tradingbot/widgets/PagesWidget.dart';
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

  CoinbaseController coinbaseController = new CoinbaseController();
  double resultNumber = -1;
  List<Wallet> resultWallets = [];
  List<Order> resultOrders = [];
  List<KLineEntity> resultCandles = [];

  int _currentIndex = 0;

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

    final List<Widget> _children = [
      PricesView(),
      MainPage(
        expandedHeight: expandedHeight,
        resultOrders: resultOrders,
      )
    ];

    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            backgroundColor: Colors.white,
            drawer: drawer(),
            bottomNavigationBar: BottomNavigationBar(
              onTap: onTabTapped,
              currentIndex:
                  _currentIndex, // this will be set when a new tab is tapped
              items: [
                BottomNavigationBarItem(
                  icon: new Icon(Icons.home),
                  title: new Text('Home'),
                ),
                BottomNavigationBarItem(
                  icon: new Icon(Icons.mail),
                  title: new Text('Messages'),
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), title: Text('Profile'))
              ],
            ),
            appBar: AppBar(
              elevation: 0,
              title: TitleWidget(25),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.account_balance_wallet),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => PricesView()));
                    }),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
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
                  _children[_currentIndex],
                ],
              ),
            )));
  }

  onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
