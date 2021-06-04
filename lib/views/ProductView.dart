import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/models/Pair.dart';

import 'package:web_socket_channel/io.dart';

class ProductView extends StatefulWidget {
  // final String product;
  final Product product;
  // final List<KLineEntity> candles;

  ProductView({Key key, @required this.product
      // , @required this.candles
      })
      : super(key: key);

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final channel = IOWebSocketChannel.connect('wss://ws-feed.pro.coinbase.com');

  String period = "1H";

  List<Pair<double, double>> lastOrdersBUY = [];
  List<Pair<double, double>> lastOrdersSELL = [];
  // Queue<Pair<double, Pair<double, bool>>> lastTrades = new Queue();
  Queue<Order> lastTrades = new Queue();

  BehaviorSubject<List<KLineEntity>> streamController =
      new BehaviorSubject<List<KLineEntity>>();

  bool gains = false;
  double lastValue = 0;

  initCandles(String period, [String granularity]) async {
    setGranularity();
    this.period = period;
    widget.product.candles =
        await CoinbaseController.getCandles(widget.product.id, granularity);
    DataUtil.calculate(widget.product.candles);
    streamController.sink.add(widget.product.candles);
  }

  checkNumCandles() {}

  setGranularity() {
    switch (_chosenValue) {
      case "1m":
        granularityNum = 60;
        break;
      case "5m":
        granularityNum = 300;
        break;
      case "15m":
        granularityNum = 900;
        break;
      case "1H":
        granularityNum = 3600;
        break;
      case "6H":
        granularityNum = 21600;
        break;
      case "1D":
        granularityNum = 86400;
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    streamController = new BehaviorSubject<List<KLineEntity>>();
    setGranularity();
    initCandles("1H", _chosenValue);
    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "product_ids": [widget.product.id],
      "channels": ["ticker"]
    }));

    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "product_ids": [widget.product.id],
      "channels": ["level2"]
    }));

    channel.stream.listen((event) {
      var msg = jsonDecode(event);
      if (msg['price'] != null && msg['last_size'] != null) {
        msg['price'] = double.parse(msg['price']);
        msg['last_size'] = double.parse(msg['last_size']);

        var productId = msg['product_id'];
        var split = productId.split("-");
        var base = split[0];
        var quote = split[1];

        var roundedTime =
            ((DateTime.parse(msg['time']).millisecondsSinceEpoch / 1000)
                        .floor() -
                    ((DateTime.parse(msg['time']).millisecondsSinceEpoch / 1000)
                            .floor() %
                        granularityNum)) *
                1000;

        // print(granularityNum);

        if (widget.product.candles.isEmpty) return;

        if (widget.product.candles.last.time == roundedTime) {
          if (widget.product.candles.last.low > msg['price'])
            widget.product.candles.last.low = msg['price'];
          if (widget.product.candles.last.high < msg['price'])
            widget.product.candles.last.high = msg['price'];
          widget.product.candles.last.close = msg['price'];
          widget.product.candles.last.vol = msg['last_size'];
        } else {
          widget.product.candles.add(new KLineEntity.fromCustom(
              time: roundedTime,
              low: msg['price'].toDouble(),
              high: msg['price'].toDouble(),
              open: msg['price'].toDouble(),
              close: msg['price'].toDouble(),
              vol: msg['last_size'].toDouble()));
        }

        DataUtil.calculate(widget.product.candles);
        streamController.sink.add(widget.product.candles);
        if (widget.product.candles.last.close > lastValue) {
          gains = true;
        } else {
          gains = false;
        }
        lastValue = widget.product.candles.last.close;
        lastTrades.addFirst(Order(widget.product.id, lastValue,
            widget.product.candles.last.vol, DateTime.now(), gains));

        if (lastTrades.length > 30) lastTrades.removeLast();
      } else if (msg['changes'] != null) {
        if (!mounted) return;
        setState(() {
          var temp = msg['changes'][0];
          if (double.parse(temp[2]) == 0.0) return;
          if (temp[0] == "sell")
            lastOrdersSELL
                .add(Pair(double.parse(temp[1]), double.parse(temp[2])));
          if (temp[0] == "buy")
            lastOrdersBUY
                .add(Pair(double.parse(temp[1]), double.parse(temp[2])));

          if (lastOrdersBUY.length > 10) lastOrdersBUY.removeAt(0);
          if (lastOrdersSELL.length > 10) lastOrdersSELL.removeAt(0);
        });
      }
    });
  }

  int granularityNum = 60;

  String _chosenValue = "1m";

  @override
  Widget build(BuildContext context) {
    final controller = PageController();

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
          children: [SizedBox(width: 10), Text(widget.product.id)],
        ),
        actions: [
          StreamBuilder<List<KLineEntity>>(
              stream: streamController.stream,
              builder: (context, AsyncSnapshot<List<KLineEntity>> snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(40))),
                        child: gains
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.arrow_drop_up,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    "${snapshot.data.last.close}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.green),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.red,
                                  ),
                                  Text(
                                    "${snapshot.data.last.close.toStringAsFixed(2)}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.red),
                                  ),
                                ],
                              )),
                  );
                }
                return Container();
              })
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 450,
            color: Colors.white,
            width: MediaQuery.of(context).size.width,
            child: StreamBuilder(
              stream: streamController.stream,
              builder: (context, AsyncSnapshot<List<KLineEntity>> snapshot) {
                if (snapshot.hasData) {
                  return KChartWidget(
                    snapshot.data,
                    onLoadMore: (bool a) {},
                    fixedLength: 2,
                    maDayList: [5, 10, 20],
                    // isLine: true,
                    mainState: MainState.MA,
                    secondaryState: SecondaryState.NONE,
                    isOnDrag: (isDrag) {},
                    timeFormat: TimeFormat.YEAR_MONTH_DAY_WITH_HOUR,
                    volHidden: true,
                    isChinese: false,

                    bgColor: [
                      Color.fromRGBO(255, 255, 255, 1),
                      Color.fromRGBO(255, 255, 255, 1),
                      Color.fromRGBO(255, 255, 255, 1),
                    ],
                  );
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Stack(
                  children: [
                    PageView(
                      controller: controller,
                      children: <Widget>[
                        Column(
                          children: [
                            Text(
                              "Order Book",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text("Price"),
                                    Container(
                                      width: 170,
                                      height: 160,
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: lastOrdersSELL.length,
                                          shrinkWrap: true,
                                          reverse: true,
                                          itemBuilder: (context, index) {
                                            return Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "${lastOrdersSELL[index].b.toStringAsFixed(7)}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green),
                                                  ),
                                                  Text(
                                                    "${lastOrdersSELL[index].a.toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.green),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Price"),
                                    Container(
                                      width: 170,
                                      height: 160,
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount: lastOrdersSELL.length,
                                          shrinkWrap: true,
                                          reverse: true,
                                          itemBuilder: (context, index) {
                                            return Align(
                                              alignment: Alignment.centerRight,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    "${lastOrdersSELL[index].a.toStringAsFixed(2)}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.red),
                                                  ),
                                                  Text(
                                                    "${lastOrdersSELL[index].b.toStringAsFixed(7)}",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.red),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Trade History",
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            Column(
                              children: [
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          width: 100,
                                          child: Center(
                                              child: Text("Trade Size"))),
                                      Container(
                                          width: 100,
                                          child: Center(child: Text("Price"))),
                                      Container(
                                          width: 100,
                                          child: Center(child: Text("Time"))),
                                    ]),
                                Container(
                                  height: 160,
                                  child: ListView.builder(
                                      itemCount: lastTrades.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        var element =
                                            lastTrades.elementAt(index);

                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: 100,
                                              child: Center(
                                                child: Text(
                                                  "${element.currency2.toStringAsFixed(7)}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              child: Center(
                                                child: Text(
                                                  "${element.currency1.toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: element.buy
                                                          ? Colors.green
                                                          : Colors.red),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 100,
                                              child: Center(
                                                child: Text(
                                                  "${DateFormat.Hms().format(element.date)}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: SmoothPageIndicator(
                          controller: controller,
                          count: 2,
                          effect: ExpandingDotsEffect(
                              dotHeight: 5,
                              dotWidth: 15,
                              expansionFactor: 3,
                              activeDotColor: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    Container(
                      height: 15,
                      alignment: Alignment.centerLeft,
                      width: 80,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButton<String>(
                          value: _chosenValue,
                          //elevation: 5,
                          style: TextStyle(color: Colors.black),

                          items: <String>[
                            '1m',
                            '5m',
                            '15m',
                            '1H',
                            '6H',
                            '1D',
                          ].map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          hint: Text(
                            "1m",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          onChanged: (String value) {
                            initCandles(this.period, value);
                            setState(() {
                              _chosenValue = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      // ]),
    );
  }
}
