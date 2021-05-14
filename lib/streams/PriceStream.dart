import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Product.dart';

import 'package:k_chart/entity/k_line_entity.dart';

import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';

class PriceStream {
  final BehaviorSubject<Map<String, List<TimeSeriesSales>>> _candlesCount =
      BehaviorSubject<Map<String, List<TimeSeriesSales>>>();
  Stream<Map<String, List<TimeSeriesSales>>> get stream => _candlesCount.stream;

  initTimer() {
    if (!_candlesCount.hasValue) {
      Timer.periodic(Duration(seconds: 15), (Timer t) async {
        priceStream.fetchData();
      });
    }
  }

  void fetchData() async {
    initTimer();

    Map<String, List<TimeSeriesSales>> result =
        new Map<String, List<TimeSeriesSales>>();

    List<Product> products = await CoinbaseController.getProducts();

    for (Product item in products) {
      List<TimeSeriesSales> temp = [];
      String currency = item.id;

      List<KLineEntity> actualCandles =
          await CoinbaseController.getCandles(currency, "1D", 3600);

      if (actualCandles == null) continue;

      for (KLineEntity candle in actualCandles) {
        temp.add(TimeSeriesSales(
            DateTime.fromMillisecondsSinceEpoch(candle.time), candle.close));
        result["$currency"] = temp;
      }
    }
    _candlesCount.add(result);
  }
}

final priceStream = PriceStream();
