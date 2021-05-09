import 'dart:async';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/streams/BalanceStream.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';

class PriceStream {
  final BehaviorSubject<Map<String, List<TimeSeriesSales>>> _candlesCount =
      BehaviorSubject<Map<String, List<TimeSeriesSales>>>();
  Stream<Map<String, List<TimeSeriesSales>>> get stream => _candlesCount.stream;
  List<Wallet> wallets;

  PriceStream() {
    initProducts();
  }

  initProducts() async {
    Balance balance = await balanceStream.stream.first;
    wallets = balance.wallets;
  }

  initTimer() {
    if (!_candlesCount.hasValue) {
      Timer.periodic(Duration(seconds: 5), (Timer t) async {
        pricesStream.fetchData();
      });
    }
  }

  void fetchData() async {
    initTimer();

    Map<String, List<TimeSeriesSales>> result =
        new Map<String, List<TimeSeriesSales>>();

    if (wallets == null) return;

    for (Wallet item in wallets) {
      List<TimeSeriesSales> temp = [];
      String currency = item.currency;
      if (currency == "USD" ||
          currency == "EUR" ||
          currency == "GBP" ||
          currency == "USDC") continue;
      List<KLineEntity> actualCandles =
          await CoinbaseController.getCandles("$currency-USD", "1D", 300);

      for (KLineEntity candle in actualCandles) {
        temp.add(TimeSeriesSales(
            DateTime.fromMillisecondsSinceEpoch(candle.time), candle.close));
        result["$currency"] = temp;
      }
    }
    _candlesCount.add(result);
  }
}

final pricesStream = PriceStream();
