import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Product.dart';

import 'package:k_chart/entity/k_line_entity.dart';

import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';

class PriceStream {
  final BehaviorSubject<Map<String, List<HistoricCurrency>>> _candlesCount =
      BehaviorSubject<Map<String, List<HistoricCurrency>>>();
  Stream<Map<String, List<HistoricCurrency>>> get stream =>
      _candlesCount.stream;
  List<Product> products;

  initTimer() async {
    if (!_candlesCount.hasValue) {
      products = await CoinbaseController.getProducts();
      Timer.periodic(Duration(seconds: 15), (Timer t) async {
        priceStream.fetchData();
      });
    }
  }

  void fetchData() async {
    await initTimer();

    Map<String, List<HistoricCurrency>> result =
        new Map<String, List<HistoricCurrency>>();

    for (Product item in products) {
      List<HistoricCurrency> temp = [];
      String currency = item.id;

      List<KLineEntity> actualCandles =
          await CoinbaseController.getCandles(currency);

      if (actualCandles == null) continue;

      for (KLineEntity candle in actualCandles) {
        temp.add(HistoricCurrency(
            DateTime.fromMillisecondsSinceEpoch(candle.time),
            candle.close,
            candle.vol));
        result["$currency"] = temp;
      }
    }
    _candlesCount.add(result);
  }
}

final priceStream = PriceStream();
