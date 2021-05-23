import 'package:flutter/material.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/streams/PriceStream.dart';
import 'package:tradingbot/views/ProductView.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class ProductsWidget extends StatefulWidget {
  final List<Product> products;
  ProductsWidget({Key key, @required this.products}) : super(key: key);

  @override
  _ProductsWidgetState createState() => _ProductsWidgetState();
}

class _ProductsWidgetState extends State<ProductsWidget> {
  CoinbaseController coinbaseController = new CoinbaseController();

  @override
  void initState() {
    super.initState();
    priceStream.fetchData();
  }

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
          child: StreamBuilder(
              stream: priceStream.stream,
              builder: (context,
                  AsyncSnapshot<Map<String, List<HistoricCurrency>>> snapshot) {
                if (snapshot.hasData) {
                  Map<String, List<HistoricCurrency>> data = snapshot.data;

                  return ListView.builder(
                      itemCount: widget.products.length,
                      itemBuilder: (context, index) {
                        bool gains = false;
                        if (data["${widget.products[index].id}"] == null)
                          return Container();
                        double initialValue =
                            data["${widget.products[index].id}"].first.balance;
                        double finalValue =
                            data["${widget.products[index].id}"].last.balance;

                        if (initialValue < finalValue) gains = true;

                        double percentage = (finalValue - initialValue) /
                            ((finalValue + initialValue) / 2);
                        List<charts.Series<HistoricCurrency, DateTime>>
                            _createData() {
                          return [
                            new charts.Series<HistoricCurrency, DateTime>(
                              id: 'Sales',
                              colorFn: (_, __) => gains
                                  ? charts.MaterialPalette.green.shadeDefault
                                  : charts.MaterialPalette.red.shadeDefault,
                              domainFn: (HistoricCurrency sales, _) =>
                                  sales.time,
                              measureFn: (HistoricCurrency sales, _) =>
                                  sales.balance,
                              data: data["${widget.products[index].id}"],
                            )
                          ];
                        }

                        String currencyId = widget.products[index].id;
                        String currencyDisplayName =
                            widget.products[index].displayName;
                        return ListTile(
                          title: Text(currencyDisplayName),
                          trailing: Container(
                            width: 130,
                            child: Row(children: [
                              Container(
                                  width: 100,
                                  child: AbsorbPointer(
                                      child: SimpleTimeSeriesChart(
                                    _createData(),
                                    lines: false,
                                  ))),
                              Container(
                                child: Text(""),
                              ),
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
                      });
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
        )
      ],
    );
  }
}
