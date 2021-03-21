import 'dart:async';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:tradingbot/models/Currency.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/controllers/RequestController.dart';

class CoinbaseController {
  static double totalBalance = -1;
  static List<Currency> wallets = [];

  static Future<List> getProducts() async {
    return await _fetchProducts();
  }

  static Future<List<Order>> getOrders() async {
    var orders = await _fetchOrders();

    List<Order> data = [];

    for (var item in orders) {
      if (item['done_reason'] == "canceled") continue;

      data.add(new Order(
          item['product_id'],
          double.parse(item['filled_size']),
          double.parse(item['executed_value']),
          DateTime.parse(item['created_at'])));
    }

    return data;
  }

  static Future<List<KLineEntity>> getCandles(String product) async {
    var candleReq = await _fetchCandlesData(product);
    if (candleReq == null) return null;

    List<KLineEntity> candles = [];

    for (var item in candleReq) {
      candles.add(new KLineEntity.fromCustom(
          time: item[0],
          low: item[1].toDouble(),
          high: item[2].toDouble(),
          open: item[3].toDouble(),
          close: item[4].toDouble(),
          vol: item[5].toDouble()));
    }

    return candles;
  }

  static refreshBalances() async {
    var balances = await _fetchWalletData();
    if (balances == null) return null;

    List<Currency> wallets = [];

    try {
      double result = 0;

      var prices = await _fetchPrices();

      for (var wallet in balances) {
        String currency = wallet['currency'];
        String name = currency;
        double amount = double.parse(wallet['balance']);
        double priceUSD = 1 / double.parse(prices[currency]);
        double value = priceUSD * amount;

        wallets.add(new Currency(currency, name, amount, value, priceUSD));
        result += value;
      }
      wallets.sort();

      CoinbaseController.totalBalance = result;
      CoinbaseController.wallets = wallets;
    } catch (e) {
      print("Error while loading wallet data");
    }
  }

  static Future _fetchWalletData() async {
    var options = {'method': 'GET', 'endPoint': '/accounts', 'body': ''};
    return await RequestController.sendRequest(options);
  }

  static Future _fetchPrices() async {
    return (await RequestController.sendRequest(null))["data"]["rates"];
  }

  static Future _fetchProducts() async {
    var options = {'method': 'GET', 'endPoint': '/products', 'body': ''};
    return await RequestController.sendRequest(options);
  }

  static Future _fetchOrders() async {
    var options = {
      'method': 'GET',
      'endPoint': '/orders?status=done',
      'body': ''
    };
    return await RequestController.sendRequest(options);
  }

  static Future _fetchCandlesData(String product) async {
    // var end = new DateTime.now().toIso8601String();
    // var start =
    //     new DateTime.now().subtract(Duration(minutes: 2)).toIso8601String();
    var options = {
      'method': 'GET',
      'endPoint': '/products/$product/candles?granularity=60',
      'body': ''
    };
    return await RequestController.sendRequest(options);
  }

  static List<Order> getSpecificOrders(String currency, List<Order> orders) {
    List<Order> result = [];
    for (Order order in orders) {
      if (order.productId.contains(currency)) result.add(order);
    }
    return result;
  }

  static bool checkSameValueOfCurrencies(
      List<Currency> before, List<Currency> after) {
    if (before == null || after == null) return null;
    for (var i = 0; i < before.length; i++) {
      if (before[i].value.toStringAsFixed(2) !=
          after[i].value.toStringAsFixed(2)) return false;
    }
    return true;
  }
}
