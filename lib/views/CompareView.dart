import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/streams/PriceStream.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class CompareView extends StatefulWidget {
  final List<Product> products;
  CompareView({Key key, @required this.products}) : super(key: key);
  @override
  _CompareViewState createState() => _CompareViewState();
}

class _CompareViewState extends State<CompareView> {
  Map<String, bool> activeIndex = {};
  int _choiceIndex;

  @override
  void initState() {
    super.initState();
    priceStream.fetchData();
    int _choiceIndex = 0;
    for (Product product in widget.products) {
      activeIndex[product.id] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(activeIndex);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: Column(children: [
          Container(
              height: 400,
              child: StreamBuilder<Map<String, List<HistoricCurrency>>>(
                  stream: priceStream.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data.entries
                          .where((element) => activeIndex[element.key] == true);
                      var palette =
                          charts.MaterialPalette.getOrderedPalettes(11);

                      List<charts.Series<HistoricCurrency, DateTime>>
                          _createData() {
                        var list = new List<
                            charts.Series<HistoricCurrency, DateTime>>();
                        for (MapEntry<String, List<HistoricCurrency>> item
                            in data) {
                          list.add(
                              new charts.Series<HistoricCurrency, DateTime>(
                            id: item.key,
                            colorFn: (_, __) =>
                                charts.MaterialPalette.blue.shadeDefault,
                            domainFn: (HistoricCurrency sales, _) => sales.time,
                            measureFn: (HistoricCurrency sales, _) =>
                                sales.balance,
                            data: item.value,
                          ));
                        }

                        return list;
                      }

                      return SimpleTimeSeriesChart(
                        _createData(),
                        lines: true,
                      );
                    }
                    return Center(child: CircularProgressIndicator());
                  })),
          Container(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.products.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ChoiceChip(
                    label: Text(widget.products[index].id),
                    selected: activeIndex[widget.products[index].id] == true,
                    selectedColor: Colors.red,
                    onSelected: (bool selected) {
                      setState(() {
                        activeIndex[widget.products[index].id] =
                            selected ? true : false;
                      });
                    },
                    backgroundColor: Colors.green,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ]));
  }
}
