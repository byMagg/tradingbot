import 'dart:async';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';

class CandleStream {
  final BehaviorSubject<List<KLineEntity>> _candlesCount =
      BehaviorSubject<List<KLineEntity>>();
  Stream<List<KLineEntity>> get stream => _candlesCount.stream;

  void fetchData(String product) async {
    List<KLineEntity> candles = await CoinbaseController.getCandles(product);
    _candlesCount.add(candles);
  }
}

final candleStream = CandleStream();
