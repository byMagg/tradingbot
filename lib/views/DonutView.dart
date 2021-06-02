import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/streams/BalanceStream.dart';

import 'package:tradingbot/views/MainLayout.dart';

class DonutView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DonutViewState();
}

class DonutViewState extends State {
  int touchedIndex = -1;
  bool initColor = false;
  List colors = [];

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: StreamBuilder<Balance>(
          stream: balanceStream.stream,
          builder: (context, AsyncSnapshot<Balance> snapshot) {
            if (snapshot.hasData) {
              if (!initColor) {
                for (var i = 0; i < snapshot.data.wallets.length; i++) {
                  colors.add(Color(Random().nextInt(0xffffffff)));
                }
                initColor = true;
              }
              List<PieChartSectionData> sections = [];
              Map<String, double> percentages = {};
              for (var i = 0; i < snapshot.data.wallets.length; i++) {
                // final isTouched = false;
                final isTouched = i == touchedIndex;
                final fontSize = isTouched ? 25.0 : 16.0;
                final radius = isTouched ? 60.0 : 50.0;
                var wallet = snapshot.data.wallets[i];
                var value = ((wallet.priceUSD * wallet.amount) /
                        snapshot.data.totalBalance) *
                    100;
                percentages[wallet.currency] = value;
                sections.add(PieChartSectionData(
                  color: colors[i],
                  value: value,
                  title: value > 10 ? '${wallet.currency}' : "",
                  radius: radius,
                  titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffffffff)),
                ));
              }

              return AspectRatio(
                aspectRatio: 1.3,
                child: Card(
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      const SizedBox(
                        height: 18,
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: PieChart(
                            PieChartData(
                                pieTouchData: PieTouchData(
                                    touchCallback: (pieTouchResponse) {
                                  setState(() {
                                    if (pieTouchResponse.touchInput
                                            is FlLongPressEnd ||
                                        pieTouchResponse.touchInput
                                            is FlPanEnd) {
                                      touchedIndex = -1;
                                    } else {
                                      touchedIndex =
                                          pieTouchResponse.touchedSectionIndex;
                                    }
                                  });
                                }),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 0,
                                centerSpaceRadius: 60,
                                sections: sections),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 200,
                            width: 120,
                            child: ListView.builder(
                                itemCount: snapshot.data.wallets.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  if (percentages[snapshot
                                          .data.wallets[index].currency] <
                                      1) return Container();
                                  return Indicator(
                                    color: colors[index],
                                    text:
                                        '${snapshot.data.wallets[index].currency} | ${percentages[snapshot.data.wallets[index].currency].toStringAsFixed(2)}%',
                                    isSquare: true,
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 18,
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 28,
                      ),
                    ],
                  ),
                ),
              );
            }
            return CircularProgressIndicator();
          }),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: const Color(0xff0293ee),
            value: 40,
            title: '40%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: const Color(0xfff8b250),
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: const Color(0xff845bef),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 3:
          return PieChartSectionData(
            color: const Color(0xff13d38e),
            value: 15,
            title: '15%',
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          throw Error();
      }
    });
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    Key key,
    @required this.color,
    @required this.text,
    @required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }
}
