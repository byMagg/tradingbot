import 'package:flutter/material.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/views/ProductView.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';

class ProductsWidget extends StatefulWidget {
  final Future<List> futureProducts;
  ProductsWidget({Key key, @required this.futureProducts}) : super(key: key);

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
        Container(
            height: 300,
            child: FutureBuilder(
                future: widget.futureProducts,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          var currency = snapshot.data[index]['id'];
                          return ListTile(
                            title: Text(currency),
                            trailing: Container(
                              width: 130,
                              child: Row(children: [
                                Container(
                                    width: 100,
                                    child:
                                        SimpleTimeSeriesChart.withSampleData()),
                                Icon(Icons.arrow_forward_ios)
                              ]),
                            ),
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProductView(
                                      product: currency,
                                      future: CoinbaseController.getCandles(
                                          currency))));
                            },
                          );
                        });
                  }
                  return Center(child: CircularProgressIndicator());
                }))
      ],
    );
  }
}
