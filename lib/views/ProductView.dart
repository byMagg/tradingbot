import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:web_socket_channel/io.dart';

class ProductView extends StatefulWidget {
  final String product;
  final Future future;

  ProductView({Key key, @required this.product, @required this.future})
      : super(key: key);

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  // _fetchCandles() async {
  //   List<KLineEntity> candles =
  //       await widget.controller.getCandles(widget.product);
  //   DataUtil.calculate(candles);
  //   return candles;
  // }
  //

  final channel = IOWebSocketChannel.connect('wss://ws-feed.pro.coinbase.com');

  List<KLineEntity> candles = [];

  StreamController<List<KLineEntity>> streamController;

  initCandles() async {
    candles = await CoinbaseController.getCandles(widget.product);
    candles.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  void initState() {
    super.initState();
    streamController = new StreamController<List<KLineEntity>>();
    initCandles();
    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "product_ids": [widget.product],
      "channels": ["matches"]
    }));

    channel.stream.listen((event) {
      var msg = jsonDecode(event);
      if (msg['price'] == null) return;
      if (msg['size'] == null) return;

      msg['price'] = double.parse(msg['price']);
      msg['size'] = double.parse(msg['size']);

      var productId = msg['product_id'];
      var split = productId.split("-");
      var base = split[0];
      var quote = split[1];

      var roundedTime =
          ((DateTime.parse(msg['time']).millisecondsSinceEpoch / 1000).floor() -
                  ((DateTime.parse(msg['time']).millisecondsSinceEpoch / 1000)
                          .floor() %
                      60)) *
              1000;

      if (candles.last.time == roundedTime) {
        if (candles.last.low > msg['price']) candles.last.low = msg['price'];
        if (candles.last.high < msg['price']) candles.last.high = msg['price'];
        candles.last.close = msg['price'];
        candles.last.vol = msg['size'];
      } else {
        candles.add(new KLineEntity.fromCustom(
            time: roundedTime,
            low: msg['price'].toDouble(),
            high: msg['price'].toDouble(),
            open: msg['price'].toDouble(),
            close: msg['price'].toDouble(),
            vol: msg['size'].toDouble()));
        // print(candles.last);
      }

      DataUtil.calculate(candles);

      print(candles.map((e) => e.time).last);
      // candles.last
    });

    Timer.periodic(Duration(seconds: 10), (Timer t) async {
      streamController.sink.add(candles);
      // print(candles);
    });
    // streamController.stream.listen((event) {});
  }

  // @override
  // void dispose() {
  //   channel.sink.close();
  //   streamController.close();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // _fetchCandles();
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
          children: [SizedBox(width: 10), Text(widget.product)],
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 500,
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
                    mainState: MainState.NONE,
                    secondaryState: SecondaryState.NONE,
                    isOnDrag: (isDrag) {},
                    timeFormat: TimeFormat.YEAR_MONTH_DAY_WITH_HOUR,
                    volHidden: true,
                    isChinese: false,

                    // bgColor: [
                    //   Color.fromRGBO(255, 255, 255, 1),
                    //   Color.fromRGBO(255, 255, 255, 1)
                    // ],
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
          Expanded(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text('1M'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      shadowColor: Colors.red,
                      elevation: 5,
                    ),
                    onPressed: () {},
                  ),
                  TextButton(
                    child: Text('5M'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      shadowColor: Colors.red,
                      elevation: 5,
                    ),
                    onPressed: () {},
                  ),
                  TextButton(
                    child: Text('15M'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      shadowColor: Colors.red,
                      elevation: 5,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
              color: Colors.white,
            ),
          )
        ],
      ),
      // ]),
    );
  }
}
