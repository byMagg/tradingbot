/// Example of a simple line chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:charts_flutter/src/text_element.dart';
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:charts_flutter/src/text_element.dart' as TextElement;
import 'package:charts_flutter/src/text_style.dart' as style;

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;
  final bool lines;

  SimpleTimeSeriesChart(this.seriesList, {this.animate, this.lines});

  factory SimpleTimeSeriesChart.withSampleData(bool lines) {
    return new SimpleTimeSeriesChart(
      _createSampleData(),
      animate: true,
      lines: lines,
    );
  }

  double min = double.infinity;
  double max = double.negativeInfinity;

  getMinMax() {
    if (seriesList == null) return;
    for (HistoricCurrency item in seriesList.first.data) {
      if (item.balance < min) min = item.balance;
      if (item.balance > max) max = item.balance;
    }
  }

  @override
  Widget build(BuildContext context) {
    getMinMax();

    if (lines) {
      return new charts.TimeSeriesChart(
        seriesList,
        animate: animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        behaviors: [
          LinePointHighlighter(
              symbolRenderer:
                  CustomCircleSymbolRenderer() // add this line in behaviours
              )
        ],
        selectionModels: [
          SelectionModelConfig(changedListener: (SelectionModel model) {
            if (model.hasDatumSelection) {
              CustomCircleSymbolRenderer.list =
                  model.selectedDatum; // paints the tapped value
            }
          })
        ],
      );
    } else {
      return new charts.TimeSeriesChart(
        seriesList,
        animate: animate,
        dateTimeFactory: const charts.LocalDateTimeFactory(),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            viewport: new charts.NumericExtents(min, max),
            renderSpec: new charts.NoneRenderSpec()),
        domainAxis: new charts.DateTimeAxisSpec(
            // viewport: new charts.DateTimeExtents(
            //     start: DateTime.now().subtract(Duration(days: 30)),
            //     end: DateTime.now()),
            renderSpec: new charts.NoneRenderSpec()),
      );
    }
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<HistoricCurrency, DateTime>> _createSampleData() {
    final data1 = [
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119700), 56101.49, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119760), 56083.38, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119820), 56083.39, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119880), 56186.23, null),
    ];

    final data2 = [
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119700), 2333.49, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119760), 123333.38, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119820), 4455.39, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119880), 112.23, null),
    ];

    final data3 = [
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119700), 664112.49, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119760), 233.38, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119820), 3456.39, null),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119880), 12344.23, null),
    ];

    return [
      new charts.Series<HistoricCurrency, DateTime>(
        id: 'Sales1',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (HistoricCurrency sales, _) => sales.time,
        measureFn: (HistoricCurrency sales, _) => sales.balance,
        data: data1,
      ),
      new charts.Series<HistoricCurrency, DateTime>(
        id: 'Sales2',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (HistoricCurrency sales, _) => sales.time,
        measureFn: (HistoricCurrency sales, _) => sales.balance,
        data: data2,
      ),
      new charts.Series<HistoricCurrency, DateTime>(
        id: 'Sales3',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (HistoricCurrency sales, _) => sales.time,
        measureFn: (HistoricCurrency sales, _) => sales.balance,
        data: data3,
      )
    ];
  }
}

/// Sample time series data type.
class HistoricCurrency {
  final DateTime time;
  final double balance;
  final double volume;

  HistoricCurrency(this.time, this.balance, this.volume);
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  static List<charts.SeriesDatum> list;

  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      Color fillColor,
      FillPatternType fillPattern,
      Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);

    String value = "";

    List<charts.SeriesDatum> resultList = []..addAll(list);

    resultList.sort((a, b) =>
        b.series.measureFn(b.index).compareTo(a.series.measureFn(a.index)));

    for (charts.SeriesDatum item in resultList) {
      value += "${item.series.measureFn(item.index)}\n";
    }

    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 35, bounds.width + 70,
            bounds.height + (20 * list.length)),
        fill: Color.fromHex(code: "#FF637D"));
    var textStyle = style.TextStyle();
    textStyle.color = Color.white;
    textStyle.fontSize = 15;
    canvas.drawText(TextElement.TextElement(value, style: textStyle),
        (bounds.left).round(), (bounds.top - 28).round());
  }
}
