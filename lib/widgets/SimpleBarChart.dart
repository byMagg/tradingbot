/// Bar chart example
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class SimpleBarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleBarChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory SimpleBarChart.withSampleData() {
    return new SimpleBarChart(
      _createSampleData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<CurrencyVolume, String>> _createSampleData() {
    final data = [
      new CurrencyVolume('2014', 5),
      new CurrencyVolume('2015', 25),
      new CurrencyVolume('2016', 100),
      new CurrencyVolume('2017', 75),
    ];

    return [
      new charts.Series<CurrencyVolume, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (CurrencyVolume sales, _) => sales.currency,
        measureFn: (CurrencyVolume sales, _) => sales.volume,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.
class CurrencyVolume {
  final String currency;
  final double volume;

  CurrencyVolume(this.currency, this.volume);
}
