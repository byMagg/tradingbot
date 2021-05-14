import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Product.dart';
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

  BehaviorSubject<List<KLineEntity>> streamController =
      new BehaviorSubject<List<KLineEntity>>();

  initCandles(String period) async {
    widget.product.candles =
        await CoinbaseController.getCandles(widget.product.id, period = period);
    DataUtil.calculate(widget.product.candles);
    streamController.sink.add(widget.product.candles);
  }

  @override
  void initState() {
    super.initState();
    streamController = new BehaviorSubject<List<KLineEntity>>();
    initCandles("1H");
    channel.sink.add(jsonEncode({
      "type": "subscribe",
      "product_ids": [widget.product.id],
      "channels": ["ticker"]
    }));

    channel.stream.listen((event) {
      var msg = jsonDecode(event);
      if (msg['price'] == null) return;
      if (msg['last_size'] == null) return;

      msg['price'] = double.parse(msg['price']);
      msg['last_size'] = double.parse(msg['last_size']);

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
    });
  }

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
          children: [SizedBox(width: 10), Text(widget.product.id)],
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text('1H'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      shadowColor: Colors.red,
                      elevation: 5,
                    ),
                    onPressed: () {
                      initCandles('1H');
                    },
                  ),
                  TextButton(
                    child: Text('1D'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      shadowColor: Colors.red,
                      elevation: 5,
                    ),
                    onPressed: () {
                      initCandles('1D');
                    },
                  ),
                  TextButton(
                    child: Text('1W'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      shadowColor: Colors.red,
                      elevation: 5,
                    ),
                    onPressed: () {
                      initCandles('1W');
                    },
                  ),
                  TextButton(
                    child: Text('1M'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      shadowColor: Colors.red,
                      elevation: 5,
                    ),
                    onPressed: () {
                      initCandles('1M');
                    },
                  ),
                  TextButton(
                    child: Text('6M'),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).accentColor,
                      shadowColor: Colors.red,
                      elevation: 5,
                    ),
                    onPressed: () {
                      initCandles('6M');
                    },
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
