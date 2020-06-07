import 'package:flutter/material.dart';
import 'package:tradingbot/views/PricesView.dart';
import 'package:tradingbot/widgets/BalanceWidget.dart';
import 'package:tradingbot/widgets/BarChartWidget.dart';
import 'package:tradingbot/widgets/LineChartWidget.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';
import 'package:tradingbot/widgets/TitleWidget.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'dart:async';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tradingbot/widgets/WalletWidget.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key, this.title}) : super(key: key);

  final String title;

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

  CoinbaseController coinbaseController;
  StreamController controllerValue;
  StreamController controllerBalance;

  @override
  void initState() {
    this.coinbaseController = new CoinbaseController();
    this.controllerBalance = new StreamController.broadcast();
    this.controllerValue = new StreamController.broadcast();

    _loadToStreams();
    super.initState();
  }

  _loadToStreams() async {
    this
        .controllerValue
        .add(await this.coinbaseController.getBalance().then((value) => value));
    this.controllerBalance.add(
        await this.coinbaseController.getCurrencies().then((value) => value));
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
                          controller: coinbaseController,
                          streamController: controllerValue,
                        ),
                        WalletWidget(
                          controller: coinbaseController,
                          streamController: controllerBalance,
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
                  OperationsWidget(),
                ],
              ),
            ],
          ),
        ));
  }
}
