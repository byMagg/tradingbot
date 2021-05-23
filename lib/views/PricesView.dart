import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/streams/BalanceStream.dart';
import 'package:tradingbot/streams/PriceStream.dart';

import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class PricesView extends StatefulWidget {
  @override
  _PricesViewState createState() => _PricesViewState();
}

class _PricesViewState extends State<PricesView> {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Text(
              //   "24hr",
              //   style: TextStyle(
              //       fontSize: 10,
              //       color: Theme.of(context).primaryColor,
              //       fontWeight: FontWeight.w400),
              // ),
              Text(
                "Market Prices",
                style: TextStyle(
                    fontSize: 25,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        StreamBuilder(
            stream: priceStream.stream,
            builder: (context,
                AsyncSnapshot<Map<String, List<HistoricCurrency>>> snapshot) {
              if (snapshot.hasData) {
                Map<String, List<HistoricCurrency>> data =
                    new Map.from(snapshot.data);

                data.removeWhere((key, value) => !key.endsWith("USD"));
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      String key = data.keys.elementAt(index);

                      List<HistoricCurrency> value =
                          data.values.elementAt(index);
                      // double number = _wallets[index].priceUSD;
                      bool gains = false;
                      double initialValue = value.first.balance;
                      double finalValue = value.last.balance;

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
                            domainFn: (HistoricCurrency sales, _) => sales.time,
                            measureFn: (HistoricCurrency sales, _) =>
                                sales.balance,
                            data: value,
                          )
                        ];
                      }

                      return ListTile(
                        leading: SizedBox(
                          height: 30,
                          child: Image(
                            image: AssetImage(
                                'lib/assets/currencies/color/${key.split("-")[0].toLowerCase()}.png'),
                          ),
                        ),
                        title: Text(
                          key.split("-")[0],
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        subtitle: Text(
                          key.split("-")[0],
                          style: TextStyle(color: Colors.black45),
                        ),

                        trailing: Container(
                          width: 240,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: 150,
                                    child: AbsorbPointer(
                                        child: SimpleTimeSeriesChart(
                                      _createData(),
                                      lines: false,
                                    ))),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "\$ ${value.last.balance.toStringAsFixed(2)}",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    gains
                                        ? Text(
                                            "+${(percentage * 100).toStringAsFixed(2)}%",
                                            style: TextStyle(
                                              color: Colors.green,
                                            ))
                                        : Text(
                                            "${(percentage * 100).toStringAsFixed(2)}%",
                                            style: TextStyle(
                                              color: Colors.red,
                                            )),
                                  ],
                                )
                              ]),
                        ),
                        // trailing: Text(
                        //   "\$ ${number.toStringAsFixed(2)}",
                        //   style: TextStyle(color: Theme.of(context).primaryColor),
                        // ),
                        onTap: () {},
                      );
                    });
              }
              return Center(child: CircularProgressIndicator());
            }),
      ],
    );
  }
}
