import 'package:flutter/material.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';

// class BalanceWidget extends StatefulWidget {
//   final double number;
//   BalanceWidget({Key key, @required this.number}) : super(key: key);

//   @override
//   BalanceWidgetState createState() => BalanceWidgetState();
// }

class ProductsWidget extends StatefulWidget {
  final Future<List> futureProducts;
  ProductsWidget({Key key, @required this.futureProducts}) : super(key: key);

  @override
  _ProductsWidgetState createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
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
                          return ListTile(
                            title: Text(snapshot.data[index]['id']),
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
                            // onTap: () {
                            //   Navigator.of(context).push(MaterialPageRoute(
                            //       builder: (context) => ProductView(
                            //             product: resultProducts[index]['id'],
                            //             controller: coinbaseController,
                            //           )));
                            // },
                          );
                        });
                  } else {
                    return CircularProgressIndicator();
                  }
                }))
      ],
    );
  }
}
