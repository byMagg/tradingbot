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
    pricesStream.fetchData();

    Timer.periodic(Duration(seconds: 5), (Timer t) async {
      pricesStream.fetchData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "Market Prices",
            style: TextStyle(
                fontSize: 25,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder(
            stream: balanceStream.stream,
            builder: (context, AsyncSnapshot<Balance> snapshot) {
              if (snapshot.hasData) {
                List<Wallet> _wallets = snapshot.data.wallets;

                return StreamBuilder(
                    stream: pricesStream.stream,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        Map<String, List<TimeSeriesSales>> data = snapshot.data;
                        return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _wallets.length,
                            itemBuilder: (context, index) {
                              if (_wallets[index].currency == "USD" ||
                                  _wallets[index].currency == "EUR" ||
                                  _wallets[index].currency == "GBP" ||
                                  _wallets[index].currency == "USDC")
                                return Container();
                              double number = _wallets[index].priceUSD;
                              bool gains = false;

                              double initialValue =
                                  data["${_wallets[index].currency}"].first.low;
                              double finalValue =
                                  data["${_wallets[index].currency}"].last.low;
                              if (initialValue < finalValue) gains = true;

                              double percentage = (finalValue - initialValue) /
                                  ((finalValue + initialValue) / 2);

                              List<charts.Series<TimeSeriesSales, DateTime>>
                                  _createData() {
                                return [
                                  new charts.Series<TimeSeriesSales, DateTime>(
                                    id: 'Sales',
                                    colorFn: (_, __) => gains
                                        ? charts
                                            .MaterialPalette.green.shadeDefault
                                        : charts
                                            .MaterialPalette.red.shadeDefault,
                                    domainFn: (TimeSeriesSales sales, _) =>
                                        sales.time,
                                    measureFn: (TimeSeriesSales sales, _) =>
                                        sales.low,
                                    data: data["${_wallets[index].currency}"],
                                  )
                                ];
                              }

                              return ListTile(
                                leading: SizedBox(
                                  height: 30,
                                  child: Image(
                                    image: AssetImage(
                                        'lib/assets/currencies/color/${_wallets[index].currency.toLowerCase()}.png'),
                                  ),
                                ),
                                title: Text(
                                  _wallets[index].name,
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                ),
                                subtitle: Text(
                                  _wallets[index].currency,
                                  style: TextStyle(color: Colors.black45),
                                ),

                                trailing: Container(
                                  width: 240,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            width: 150,
                                            child: AbsorbPointer(
                                                child: SimpleTimeSeriesChart(
                                              _createData(),
                                              lines: false,
                                            ))),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              "\$ ${number.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor),
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
                      return CircularProgressIndicator();
                    });
              }
              return Center(child: CircularProgressIndicator());
            }),
      ],
    );
  }
}
