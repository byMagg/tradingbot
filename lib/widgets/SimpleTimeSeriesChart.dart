/// Example of a simple line chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';

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
    final data = [
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119700), 56101.49),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119760), 56083.38),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119820), 56083.39),
      new HistoricCurrency(
          DateTime.fromMillisecondsSinceEpoch(1620119880), 56186.23),
    ];

    return [
      new charts.Series<HistoricCurrency, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (HistoricCurrency sales, _) => sales.time,
        measureFn: (HistoricCurrency sales, _) => sales.balance,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class HistoricCurrency {
  final DateTime time;
  final double balance;

  HistoricCurrency(this.time, this.balance);
}
