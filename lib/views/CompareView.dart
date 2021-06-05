import 'dart:math';

import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Pair.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/streams/PriceStream.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';
import 'package:tradingbot/widgets/SimpleBarChart.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_common/src/common/palette.dart' show Palette;

class CompareView extends StatefulWidget {
  final List<Product> products;
  final List<Wallet> wallets;
  CompareView({Key key, @required this.products, @required this.wallets})
      : super(key: key);
  @override
  _CompareViewState createState() => _CompareViewState();
}

class _CompareViewState extends State<CompareView> {
  Map<String, bool> activeIndex = {};
  String compareValue = "Price";
  List<Pair<Palette, String>> paletteAssign = [];

  Future<List<Pair<CurrencyVolume, CurrencyVolume>>> dataVolumes;

  Future<List<Pair<CurrencyVolume, CurrencyVolume>>> get24hrStats() async {
    List<Pair<CurrencyVolume, CurrencyVolume>> dataVolumes = [];
    for (Product product in widget.products) {
      Pair<CurrencyVolume, CurrencyVolume> temp =
          await CoinbaseController.get24hrStats(product.id);
      // if (temp.volume == 0) continue;
      dataVolumes.add(temp);
    }

    return dataVolumes;
  }

  @override
  void initState() {
    super.initState();
    priceStream.fetchData();
    dataVolumes = get24hrStats();
    int i = 0;
    for (Product product in widget.products) {
      if (i == 0) {
        activeIndex[product.id] = true;
      } else {
        activeIndex[product.id] = false;
      }
      i++;
    }

    List<Palette> palettes = charts.MaterialPalette.getOrderedPalettes(10);

    for (var i = 0; i < palettes.length; i++) {
      if (i == 0) {
        paletteAssign.add(Pair(palettes[i], activeIndex.keys.first));
      } else {
        paletteAssign.add(Pair(palettes[i], ""));
      }
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

                      List<charts.Series<HistoricCurrency, DateTime>>
                          _createData() {
                        var list = new List<
                            charts.Series<HistoricCurrency, DateTime>>();
                        if (data.isEmpty) {
                          list.add(
                              new charts.Series<HistoricCurrency, DateTime>(
                            id: "",
                            colorFn: (_, __) =>
                                charts.MaterialPalette.blue.shadeDefault,
                            domainFn: (HistoricCurrency sales, _) => sales.time,
                            measureFn: (HistoricCurrency sales, _) =>
                                sales.balance,
                            data: [],
                          ));
                        } else if (compareValue == "Price") {
                          for (MapEntry<String, List<HistoricCurrency>> item
                              in data) {
                            list.add(
                                new charts.Series<HistoricCurrency, DateTime>(
                              id: item.key,
                              colorFn: (_, __) => paletteAssign
                                  .firstWhere(
                                      (element) => element.b == item.key)
                                  .a
                                  .shadeDefault,
                              domainFn: (HistoricCurrency sales, _) =>
                                  sales.time,
                              measureFn: (HistoricCurrency sales, _) =>
                                  sales.balance,
                              data: item.value,
                            ));
                          }
                        } else {
                          for (MapEntry<String, List<HistoricCurrency>> item
                              in data) {
                            list.add(
                                new charts.Series<HistoricCurrency, DateTime>(
                              id: item.key,
                              colorFn: (_, __) => paletteAssign
                                  .firstWhere(
                                      (element) => element.b == item.key)
                                  .a
                                  .shadeDefault,
                              domainFn: (HistoricCurrency sales, _) =>
                                  sales.time,
                              measureFn: (HistoricCurrency sales, _) =>
                                  sales.volume,
                              data: item.value,
                            ));
                          }
                        }

                        return list;
                      }

                      List<charts.Series<CurrencyVolume, String>>
                          _createDataVolumes(List<CurrencyVolume> list) {
                        return [
                          new charts.Series<CurrencyVolume, String>(
                            id: "",
                            colorFn: (_, __) =>
                                charts.MaterialPalette.blue.shadeDefault,
                            domainFn: (CurrencyVolume sales, _) =>
                                sales.currency,
                            measureFn: (CurrencyVolume sales, _) =>
                                sales.volume,
                            data: list,
                          )
                        ];
                      }

                      if (compareValue == "30 Day Volume") {
                        return FutureBuilder<
                                List<Pair<CurrencyVolume, CurrencyVolume>>>(
                            future: dataVolumes,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<CurrencyVolume> test = snapshot.data
                                    .where((element) =>
                                        activeIndex[element.a.currency] == true)
                                    .toList()
                                    .map((e) => e.a)
                                    .toList();
                                return SimpleBarChart(_createDataVolumes(test));
                              }
                              return Center(child: CircularProgressIndicator());
                            });
                      } else if (compareValue == "24hr Volume") {
                        return FutureBuilder<
                                List<Pair<CurrencyVolume, CurrencyVolume>>>(
                            future: dataVolumes,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                List<CurrencyVolume> test = snapshot.data
                                    .where((element) =>
                                        activeIndex[element.b.currency] == true)
                                    .toList()
                                    .map((e) => e.b)
                                    .toList();
                                return SimpleBarChart(_createDataVolumes(test));
                              }
                              return Center(child: CircularProgressIndicator());
                            });
                      } else {
                        return SimpleTimeSeriesChart(
                          _createData(),
                          lines: true,
                        );
                      }
                    }
                    return Center(child: CircularProgressIndicator());
                  })),
          Container(
            height: 15,
            alignment: Alignment.center,
            // width: 90,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButton<String>(
                value: compareValue,
                //elevation: 5,
                style: TextStyle(color: Colors.black),

                items: <String>[
                  'Price',
                  'Volume',
                  '30 Day Volume',
                  '24hr Volume',
                  '6H',
                  '1D',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                hint: Text(
                  "Price",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
                onChanged: (String value) {
                  setState(() {
                    compareValue = value;
                  });
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Max 10",
                style: TextStyle(color: Colors.black45),
              ),
            ),
          ),
          Container(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: widget.products.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ChoiceChip(
                    label: Text(widget.products[index].id),
                    selected: activeIndex[widget.products[index].id] == true,
                    selectedColor: Colors.blueGrey.shade200,
                    onSelected: (bool selected) {
                      setState(() {
                        activeIndex[widget.products[index].id] =
                            selected ? true : false;
                        if (activeIndex[widget.products[index].id] == true) {
                          paletteAssign
                              .firstWhere((element) => element.b == "")
                              .b = widget.products[index].id;
                        } else {
                          paletteAssign
                              .firstWhere((element) =>
                                  element.b == widget.products[index].id)
                              .b = "";
                        }
                        if (activeIndex.length > 10) {
                          MapEntry<String, bool> temp = activeIndex.entries
                              .firstWhere((element) => element.value == true);
                          activeIndex[temp.key] = false;
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    labelStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                  ),
                );
              },
            ),
          ),
        ]));
  }
}
