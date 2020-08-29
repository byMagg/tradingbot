import 'package:flutter/material.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';

class ProductView extends StatefulWidget {
  final String symbol;
  final List<KLineEntity> candles;

  ProductView({Key key, @required this.symbol, @required this.candles})
      : super(key: key);

  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  @override
  Widget build(BuildContext context) {
    DataUtil.calculate(widget.candles);

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
          children: [SizedBox(width: 10), Text(widget.symbol)],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: KChartWidget(
          widget.candles,
          onLoadMore: (bool a) {},
          maDayList: [5, 10, 20],
          isOnDrag: (isDrag) {},
        ),
      ),
      // ]),
    );
  }
}
