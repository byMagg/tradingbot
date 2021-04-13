import 'dart:async';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/controllers/RequestController.dart';

class CoinbaseController {
  static Future<List<Product>> getProducts() async {
    var products = await _fetchProducts();

    List<Product> result = [];

    for (var product in products) {
      result.add(Product.fromJson(product));
    }

    return result;
  }

  static Future<List<Order>> getOrders() async {
    var orders = await _fetchOrders();

    List<Order> result = [];

    for (var order in orders) {
      if (order['done_reason'] == "canceled") continue;

      result.add(Order.fromJson(order));
    }

    return result;
  }

  static Future<List<KLineEntity>> getCandles(String product,
      [String period = "1H"]) async {
    var candleReq = await _fetchCandlesData(product, period = period);
    if (candleReq == null) return null;

    List<KLineEntity> candles = [];

    for (var item in candleReq) {
      candles.add(new KLineEntity.fromCustom(
          time: item[0].toInt() * 1000,
          low: item[1].toDouble(),
          high: item[2].toDouble(),
          open: item[3].toDouble(),
          close: item[4].toDouble(),
          vol: item[5].toDouble()));
    }

    return candles;
  }

  static Future<Balance> getBalances() async {
    var balances = await _fetchWalletData();
    if (balances == null) return null;

    List<Wallet> wallets = [];

    double result = 0;

    for (var wallet in balances) {
      String currency = wallet['currency'];
      String name = currency;
      double amount = double.parse(wallet['balance']);
      var price = (await _fetchPriceOfCurrency(currency))['data']['amount'];
      double priceUSD = double.parse(price);
      double value = priceUSD * amount;

      wallets.add(new Wallet(currency, name, amount, value, priceUSD));
      result += value;
    }

    return Balance(result, wallets);
  }

  static Future _fetchWalletData() async {
    var options = {'method': 'GET', 'endPoint': '/accounts', 'body': ''};
    return await RequestController.sendRequest(options);
  }

  static Future _fetchPriceOfCurrency(String currency) async {
    return (await RequestController.sendRequest(null, currency));
  }

  static Future _fetchProducts() async {
    var options = {'method': 'GET', 'endPoint': '/products', 'body': ''};
    return await RequestController.sendRequest(options);
  }

  static Future _fetchOrders() async {
    var end = new DateTime.now().toIso8601String();
    var start =
        new DateTime.now().subtract(Duration(days: 90)).toIso8601String();
    var options = {
      'method': 'GET',
      'endPoint': '/orders?status=done&start_date=$start&after=$end',
      'body': ''
    };
    return await RequestController.sendRequest(options);
  }

  static Future _fetchCandlesData(String product,
      [String period = "1h"]) async {
    DateTime now = new DateTime.now();
    DateTime start;
    int granularity;

    switch (period) {
      case "1H":
        start = new DateTime.now().subtract(Duration(hours: 1));
        granularity = 60;
        break;
      case "1D":
        start = new DateTime.now().subtract(Duration(days: 1));
        granularity = 300;
        break;
      case "1W":
        start = new DateTime.now().subtract(Duration(days: 7));
        granularity = 3600;
        break;
      case "1M":
        start = new DateTime(now.year, now.month - 1, now.day);
        granularity = 21600;
        break;
      case "6M":
        start = new DateTime(now.year, now.month - 6, now.day);
        granularity = 86400;
        break;
    }

    var options = {
      'method': 'GET',
      'endPoint':
          '/products/$product/candles?granularity=$granularity&start=${start.toUtc().toIso8601String()}&end=${now.toUtc().toIso8601String()}',
      'body': ''
    };
    print(options);
    return await RequestController.sendRequest(options = options, null, true);
  }

  static List<Order> getSpecificOrders(String currency, List<Order> orders) {
    List<Order> result = [];
    for (Order order in orders) {
      if (order.productId.contains(currency)) result.add(order);
    }
    return result;
  }

  static bool checkSameValueOfCurrencies(
      List<Wallet> before, List<Wallet> after) {
    if (before == null || after == null) return null;
    for (var i = 0; i < before.length; i++) {
      if (before[i].value.toStringAsFixed(2) !=
          after[i].value.toStringAsFixed(2)) return false;
    }
    return true;
  }
}
