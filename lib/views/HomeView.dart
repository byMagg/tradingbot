import 'package:flutter/material.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:start_chart/chart/candle/entity/candle_entity.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/views/PricesView.dart';
import 'package:tradingbot/widgets/BalanceWidget.dart';
import 'package:tradingbot/widgets/BarChartWidget.dart';
import 'package:tradingbot/widgets/LineChartWidget.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';
import 'package:tradingbot/widgets/TitleWidget.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Currency.dart';
import 'package:tradingbot/models/Candle.dart';

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
  List<Currency> resultWallets = [];
  List<Order> resultOrders = [];
  List<KLineEntity> resultCandles = [];

  @override
  void initState() {
    super.initState();

    _loadData();
    _loadOrders();
    _loadCandles();

    Timer.periodic(Duration(seconds: 5), (Timer t) async {
      _loadData();
      _loadOrders();
      _loadCandles();
    });
  }

  _loadCandles() async {
    List<KLineEntity> tempCandles = await coinbaseController.getCandles();
    setState(() {
      resultCandles = tempCandles;
    });
  }

  _loadOrders() async {
    List<Order> tempOrders = await coinbaseController.getOrders();

    setState(() {
      resultOrders = tempOrders;
    });
  }

  _loadData() async {
    await coinbaseController.refreshBalances();
    double tempNumber = coinbaseController.getValue();
    List<Currency> tempWallets = coinbaseController.getCurrencies();

    setState(() {
      if (resultNumber != tempNumber) resultNumber = tempNumber;
      if (!coinbaseController.checkSameValueOfCurrencies(
              resultWallets, tempWallets) ||
          resultWallets.isEmpty) {
        resultWallets = tempWallets;
      }
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
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PricesView(
                              wallets: resultWallets,
                            )));
                  }),
            ],
          ),
          body: Stack(
            children: <Widget>[
              ListView(
                children: <Widget>[
                  Container(
                    height: expandedHeight,
                    color: Theme.of(context).primaryColor,
                    child: Column(
                      children: <Widget>[
                        BalanceWidget(
                          number: resultNumber,
                        ),
                        WalletWidget(
                          wallets: resultWallets,
                          orders: resultOrders,
                          candles: resultCandles,
                        )
                      ],
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
                                  activeDotColor:
                                      Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                      ],
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
                  OperationsWidget(
                    everything: false,
                    fixed: true,
                    orders: resultOrders,
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
                  )
                ],
              ),
            ],
          ),
        ));
  }
}
