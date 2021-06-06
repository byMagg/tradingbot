/// Vertical bar chart with bar label renderer example.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class VerticalBarLabelChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  VerticalBarLabelChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory VerticalBarLabelChart.withSampleData() {
    return new VerticalBarLabelChart(
      _createSampleData(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.BarChart(
      seriesList,
      animate: animate,
      // Set a bar label decorator.
      // Example configuring different styles for inside/outside:
      //       barRendererDecorator: new charts.BarLabelDecorator(
      //          insideLabelStyleSpec: new charts.TextStyleSpec(...),
      //          outsideLabelStyleSpec: new charts.TextStyleSpec(...)),
      barRendererDecorator: new charts.BarLabelDecorator<String>(),
      domainAxis: new charts.OrdinalAxisSpec(),
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
          domainFn: (CurrencyVolume sales, _) => sales.currency,
          measureFn: (CurrencyVolume sales, _) => sales.volume,
          data: data,
          // Set a label accessor to control the text of the bar label.
          labelAccessorFn: (CurrencyVolume sales, _) =>
              '\$${sales.volume.toString()}')
    ];
  }
}

/// Sample ordinal data type.
class CurrencyVolume {
  final String currency;
  final double volume;

  CurrencyVolume(this.currency, this.volume);
}
