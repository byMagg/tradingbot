import 'package:flutter/material.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/views/PricesView.dart';
import 'package:tradingbot/widgets/BalanceWidget.dart';
import 'package:tradingbot/widgets/BarChartWidget.dart';
import 'package:tradingbot/widgets/LineChartWidget.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';
import 'package:tradingbot/widgets/ProductsWidget.dart';
import 'package:tradingbot/widgets/TitleWidget.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Currency.dart';

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

  Future<List> _futureProducts;
  Future<List> _futureOrders;
  Future<List> _futureCandles;

  @override
  void initState() {
    super.initState();

    _loadData();
    _loadOrders();
    _futureOrders = CoinbaseController.getOrders();
    _futureProducts = CoinbaseController.getProducts();

    Timer.periodic(Duration(seconds: 5), (Timer t) async {
      _loadData();
      _loadOrders();
    });
  }

  _loadOrders() async {
    List<Order> tempOrders = await CoinbaseController.getOrders();

    setState(() {
      resultOrders = tempOrders;
    });
  }

  _loadData() async {
    await CoinbaseController.refreshBalances();
    // double tempNumber = CoinbaseController.totalBalance;
    // List<Currency> tempWallets = CoinbaseController.wallets;

    // setState(() {
    //   if (resultNumber != tempNumber) resultNumber = tempNumber;
    //   if (!CoinbaseController.checkSameValueOfCurrencies(
    //           resultWallets, tempWallets) ||
    //       resultWallets.isEmpty) {
    //     resultWallets = tempWallets;
    //   }
    // });
  }

  // static List<charts.Series<LinearPrices, DateTime>> _createSampleData() {
  //   final data = [
  //     new LinearPrices(DateTime.now(), double.parse("1000")),
  //     new LinearPrices(DateTime.now(), double.parse("1000")),
  //     new LinearPrices(DateTime.now(), double.parse("1000")),
  //     new LinearPrices(DateTime.now(), double.parse("1000")),
  //   ];

  //   return [
  //     new charts.Series<LinearPrices, DateTime>(
  //       id: 'Sales',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (LinearPrices sales, _) => sales.time,
  //       measureFn: (LinearPrices sales, _) => sales.price,
  //       data: data,
  //     )
  //   ];
  // }

  // _fetchChartPrices(List listPrices) {
  //   var data = [];

  //   for (var item in listPrices) {
  //     data.add(LinearPrices(
  //         DateTime.parse(item['time']), double.parse(item['price'])));
  //   }
  //   return data;
  // }

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
                              wallets: CoinbaseController.wallets,
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
                          number: CoinbaseController.totalBalance,
                        ),
                        WalletWidget(
                          wallets: CoinbaseController.wallets,
                          orders: resultOrders,
                        )
                      ],
                    ),
                  ),
                  ProductsWidget(futureProducts: _futureProducts),
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
                                  activeDotColor:
                                      Theme.of(context).primaryColor),
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
