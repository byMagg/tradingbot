import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/models/Pair.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/streams/BalanceStream.dart';

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

  Map<double, double> asks = {};
  Map<double, double> bids = {};
  List<MapEntry<double, double>> bidsEntries = [];
  List<MapEntry<double, double>> asksEntries = [];

  BehaviorSubject<List<KLineEntity>> streamController =
      new BehaviorSubject<List<KLineEntity>>();

  bool gains = false;
  double lastValue = 0;

  bool init = false;

  int listLength = 0;

  initOrderBook() async {
    // Pair<Map, Map> temp =
    //     await CoinbaseController.getOrderBook(widget.product.id);
    // bids = temp.a;
    // asks = temp.b;
    // bidsEntries = bids.entries.toList();
    // asksEntries = asks.entries.toList();
    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "product_ids": [widget.product.id],
      "channels": ["level2"]
    }));
  }

  initCandles(String period, [String granularity]) async {
    setGranularity();
    this.period = period;
    widget.product.candles =
        await CoinbaseController.getCandles(widget.product.id, granularity);
    if (widget.product.candles == null) return;
    DataUtil.calculate(widget.product.candles);
    streamController.sink.add(widget.product.candles);
    if (!init) {
      double number = widget.product.candles.last.close;

      txt.text = number.toStringAsFixed(2);
      init = true;
    }
  }

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

  List totalBids = [];
  List totalAsks = [];

  @override
  void initState() {
    super.initState();
    streamController = new BehaviorSubject<List<KLineEntity>>();
    initOrderBook();
    setGranularity();
    initCandles("1H", _chosenValue);
    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "product_ids": [widget.product.id],
      "channels": ["ticker"]
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

        if (lastTrades.length > 15) lastTrades.removeLast();
      } else if (msg['changes'] != null) {
        if (!mounted) return;
        setState(() {
          var temp = msg['changes'][0];
          double price = double.parse(temp[1]);
          double marketSize = double.parse(temp[2]);
          if (temp[0] == "sell") {
            if (marketSize == 0.0) {
              asks.remove(price);
            } else {
              asks[price] = marketSize;
            }
          } else if (temp[0] == "buy") {
            if (marketSize == 0.0) {
              bids.remove(price);
            } else {
              bids[price] = marketSize;
            }
          }

          // bids.removeWhere(
          //     (key, value) => key > widget.product.candles.last.close);
          // asks.removeWhere(
          //     (key, value) => key < widget.product.candles.last.close);

          bidsEntries = bids.entries.toList();
          asksEntries = asks.entries.toList();
          bidsEntries.sort((a, b) => -a.key.compareTo(b.key));
          asksEntries.sort((a, b) => a.key.compareTo(b.key));
          if (bidsEntries.length > 15)
            bidsEntries = bidsEntries.getRange(0, 15).toList();
          if (asksEntries.length > 15)
            asksEntries = asksEntries.getRange(0, 15).toList();

          double total = 0;
          double bidSum = 0;
          double askSum = 0;

          listLength = min(asksEntries.length, bidsEntries.length);

          totalAsks.clear();
          totalBids.clear();

          for (var i = 0; i < listLength; i++) {
            var tempBidAmount = 0.0;
            var tempAskAmount = 0.0;
            tempBidAmount = bidsEntries[i].value;
            tempAskAmount = asksEntries[i].value;
            total += tempBidAmount + tempAskAmount;
          }

          for (var i = 0; i < listLength; i++) {
            var tempBidAmount = 0.0;
            var tempAskAmount = 0.0;
            tempBidAmount = bidsEntries[i].value;
            tempAskAmount = asksEntries[i].value;

            bidSum += tempBidAmount;
            askSum += tempAskAmount;

            totalAsks.add(askSum / total);
            totalBids.add(bidSum / total);
          }
        });
      }
    });
  }

  int granularityNum = 60;

  String _chosenValue = "1m";

  int counter = 0;

  // List<bool> _selections = List.generate(2, (index) => false);
  List<bool> _selections = [true, false];

  TextEditingController txt = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = PageController();

    return Scaffold(
      backgroundColor: Colors.white,
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
                                    "${snapshot.data.last.close.toStringAsFixed(5)}",
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
                                    "${snapshot.data.last.close.toStringAsFixed(5)}",
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 350,
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
            Container(
              height: MediaQuery.of(context).size.height / 2 -
                  MediaQuery.of(context).size.height * 0.13,
              color: Colors.white,
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
                          Container(
                            // height: 100,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          10,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Market Size"),
                                          Text("Price"),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                              2 -
                                          10,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Price"),
                                          Text("Market Size"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  // height: MediaQuery.of(context).size.height /
                                  //         2 -
                                  //     MediaQuery.of(context).size.height * 0.2,
                                  child: ListView.builder(
                                      itemCount: listLength,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        double containerW =
                                            MediaQuery.of(context).size.width /
                                                2;

                                        return Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  width: containerW,
                                                  child: index > bids.length - 1
                                                      ? Container()
                                                      : Stack(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Container(
                                                                height: 15,
                                                                color: Colors
                                                                    .green
                                                                    .shade300,
                                                                child:
                                                                    FractionallySizedBox(
                                                                  widthFactor:
                                                                      totalBids[
                                                                          index],
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "${bidsEntries[index].value.toStringAsFixed(4)}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child: Text(
                                                                    "${bidsEntries[index].key.toStringAsFixed(5)}",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .green
                                                                            .shade900),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                                Container(
                                                  width: containerW,
                                                  child: index > asks.length - 1
                                                      ? Container()
                                                      : Stack(
                                                          children: [
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Container(
                                                                height: 15,
                                                                color: Colors
                                                                    .red
                                                                    .shade300,
                                                                child:
                                                                    FractionallySizedBox(
                                                                  widthFactor:
                                                                      totalAsks[
                                                                          index],
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          5),
                                                                  child: Text(
                                                                    "${asksEntries[index].key.toStringAsFixed(5)}",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .red
                                                                            .shade900),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  "${asksEntries[index].value.toStringAsFixed(4)}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      }),
                                ),
                              ],
                            ),
                          )
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
                                        child:
                                            Center(child: Text("Trade Size"))),
                                    Container(
                                        width: 100,
                                        child: Center(child: Text("Price"))),
                                    Container(
                                        width: 100,
                                        child: Center(child: Text("Time"))),
                                  ]),
                              Container(
                                // height: MediaQuery.of(context).size.height / 2 -
                                //     MediaQuery.of(context).size.height * 0.2,
                                child: ListView.builder(
                                    itemCount: lastTrades.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      var element = lastTrades.elementAt(index);

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
                                                "${element.currency1.toStringAsFixed(4)}",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
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
            Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                children: [
                  Expanded(
                      child: Column(
                    children: [
                      StreamBuilder<Balance>(
                          stream: balanceStream.stream,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List splittedData = widget.product.id.split("-");
                              Wallet base = snapshot.data.wallets.firstWhere(
                                  (element) =>
                                      element.currency == splittedData[0]);
                              Wallet quote = snapshot.data.wallets.firstWhere(
                                  (element) =>
                                      element.currency == splittedData[1]);
                              Widget result;

                              if (_selections[0]) {
                                result = Container(
                                  width: 150,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${base.currency}"),
                                      Text("${base.amount.toStringAsFixed(4)}"),
                                    ],
                                  ),
                                );
                              } else {
                                if (!init) {
                                  txt.text = quote.amount.toStringAsFixed(4);
                                  init = true;
                                }
                                result = Container(
                                  width: 150,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${quote.currency}"),
                                      Text(
                                          "${quote.amount.toStringAsFixed(4)}"),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: [
                                  Container(
                                      height: 30,
                                      color: Colors.white,
                                      child: ToggleButtons(
                                        // fillColor: Colors.transparent,

                                        children: [
                                          Container(
                                              height: 30,
                                              width: 100,
                                              color: _selections[0]
                                                  ? Colors.green
                                                  : Colors.white,
                                              child: Center(
                                                child: Text(
                                                  "BUY",
                                                  style: TextStyle(
                                                      color: _selections[0]
                                                          ? Colors.white
                                                          : Theme.of(context)
                                                              .primaryColor),
                                                ),
                                              )),
                                          Container(
                                              height: 30,
                                              width: 100,
                                              color: _selections[1]
                                                  ? Colors.red
                                                  : Colors.white,
                                              child: Center(
                                                child: Text(
                                                  "SELL",
                                                  style: TextStyle(
                                                      color: _selections[1]
                                                          ? Colors.white
                                                          : Theme.of(context)
                                                              .primaryColor),
                                                ),
                                              )),
                                        ],
                                        renderBorder: true,
                                        isSelected: _selections,
                                        onPressed: (int index) {
                                          setState(() {
                                            _selections[index] = true;
                                            for (var i = 0;
                                                i < _selections.length;
                                                i++) {
                                              if (i == index) continue;
                                              _selections[i] =
                                                  !_selections[index];
                                            }
                                          });
                                        },
                                      )),
                                  result,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.remove,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 18.0),
                                        iconSize: 32.0,
                                        color: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          setState(() {
                                            double value =
                                                double.tryParse(txt.text);
                                            if (value > 0) {
                                              txt.text = (value - 1).toString();
                                            }
                                          });
                                        },
                                      ),
                                      Container(
                                        height: 20,
                                        width: 200,
                                        child: TextFormField(
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          // inputFormatters: <TextInputFormatter>[
                                          //   FilteringTextInputFormatter
                                          //       .digitsOnly
                                          // ],
                                          controller: txt,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.add,
                                          color: Theme.of(context).accentColor,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 18.0),
                                        iconSize: 32.0,
                                        color: Theme.of(context).primaryColor,
                                        onPressed: () {
                                          txt.text =
                                              (double.tryParse(txt.text) + 1)
                                                  .toString();
                                        },
                                      ),
                                    ],
                                  ),
                                  MaterialButton(
                                      child: Text("Place order"),
                                      onPressed: () {
                                        String side = "sell";
                                        if (_selections[0]) side = "buy";
                                        CoinbaseController.placeOrder(
                                            0.01,
                                            double.tryParse(
                                                double.tryParse(txt.text)
                                                    .toStringAsFixed(2)),
                                            side,
                                            widget.product.id);
                                      }),
                                  Container(
                                    height: 200,
                                    color: Colors.green,
                                    child: FutureBuilder<List<Order>>(
                                        future: CoinbaseController
                                            .getSpecificOrdersReq(
                                                widget.product.id, "open"),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return ListView.builder(
                                                itemCount: snapshot.data.length,
                                                itemBuilder: (context, index) {
                                                  return Text(
                                                      "${snapshot.data[index].currency1}");
                                                });
                                          }
                                          return CircularProgressIndicator();
                                        }),
                                  )
                                ],
                              );
                            }
                            return LinearProgressIndicator();
                          }),
                    ],
                  )),
                ],
              ),
            )
          ],
        ),
      ),
      // ]),
    );
  }
}
