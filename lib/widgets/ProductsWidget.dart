import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/views/ProductView.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';
import 'package:web_socket_channel/io.dart';

class ProductsWidget extends StatefulWidget {
  final List<Product> products;
  ProductsWidget({Key key, @required this.products}) : super(key: key);

  @override
  _ProductsWidgetState createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  CoinbaseController coinbaseController = new CoinbaseController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "Products",
            style: TextStyle(
                fontSize: 25,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: widget.products.length,
              itemBuilder: (context, index) {
                String currencyId = widget.products[index].id;
                String currencyDisplayName = widget.products[index].displayName;
                return ListTile(
                  title: Text(currencyDisplayName +
                      " ${widget.products[index].candles.length}"),
                  trailing: Container(
                    width: 130,
                    child: Row(children: [
                      Container(
                          width: 100,
                          child: AbsorbPointer(
                              child:
                                  SimpleTimeSeriesChart.withSampleData(false))),
                      Icon(Icons.arrow_forward_ios)
                    ]),
                  ),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ProductView(
                              product: widget.products[index],
                            )));
                  },
                );
              }),
        )
      ],
    );
  }
}
