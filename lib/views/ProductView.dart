import 'package:flutter/material.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';

class ProductView extends StatefulWidget {
  final String product;
  final CoinbaseController controller;

  ProductView({Key key, @required this.product, @required this.controller})
      : super(key: key);

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  _fetchCandles() async {
    List<KLineEntity> candles =
        await widget.controller.getCandles(widget.product);
    DataUtil.calculate(candles);
    return candles;
  }

  @override
  Widget build(BuildContext context) {
    _fetchCandles();
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
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: FutureBuilder(
            future: _fetchCandles(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return KChartWidget(
                  snapshot.data,
                  onLoadMore: (bool a) {},
                  maDayList: [5, 10, 20],
                  isOnDrag: (isDrag) {},
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
      ),
      // ]),
    );
  }
}
