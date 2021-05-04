/// Example of a simple line chart.
import 'package:charts_flutter/flutter.dart' as charts;
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

  @override
  Widget build(BuildContext context) {
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
        primaryMeasureAxis:
            new charts.NumericAxisSpec(renderSpec: new charts.NoneRenderSpec()),
        domainAxis: new charts.DateTimeAxisSpec(
            renderSpec: new charts.NoneRenderSpec()),
      );
    }
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData() {
    final data = [
      new TimeSeriesSales(
          DateTime.fromMillisecondsSinceEpoch(1620119700), 56101.49),
      new TimeSeriesSales(
          DateTime.fromMillisecondsSinceEpoch(1620119760), 56083.38),
      new TimeSeriesSales(
          DateTime.fromMillisecondsSinceEpoch(1620119820), 56083.39),
      new TimeSeriesSales(
          DateTime.fromMillisecondsSinceEpoch(1620119880), 56186.23),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.low,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final double low;

  TimeSeriesSales(this.time, this.low);
}
