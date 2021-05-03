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
      new TimeSeriesSales(new DateTime(2017, 9, 19), 5),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 3), 100),
      new TimeSeriesSales(new DateTime(2017, 10, 10), 75),
    ];

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}
