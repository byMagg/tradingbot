import 'dart:async';
import 'package:k_chart/entity/k_line_entity.dart';
import 'package:tradingbot/models/Pair.dart';
import 'package:tradingbot/models/Product.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/controllers/RequestController.dart';
import 'package:tradingbot/widgets/SimpleBarChart.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';

class CoinbaseController {
  static Future<List<Product>> getProducts() async {
    var products = await _fetchProducts();

    List<Product> result = [];

    for (var product in products) {
      result.add(Product.fromJson(product));
    }

    return result;
  }

  static Future<Pair<CurrencyVolume, CurrencyVolume>> get24hrStats(
      String productId) async {
    var stats = await _fetch24hrStats(productId);

    return Pair(CurrencyVolume(productId, double.parse(stats["volume"])),
        CurrencyVolume(productId, double.parse(stats["volume_30day"])));
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
      [String gran]) async {
    int granularityNum = 60;

    switch (gran) {
      case "1m":
        granularityNum = 60;
        break;
      case "5m":
        granularityNum = 300;
        break;
      case "15m":
        granularityNum = 900;
        break;
      case "1H":
        granularityNum = 3600;
        break;
      case "6H":
        granularityNum = 21600;
        break;
      case "1D":
        granularityNum = 86400;
        break;
      default:
        granularityNum = null;
        break;
    }

    var candleReq = await _fetchCandlesData(product, granularityNum);
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

    return candles.reversed.toList();
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
      var tempWallet = new Wallet(currency, name, amount, value, priceUSD);
      await tempWallet.getImagePalette();
      wallets.add(tempWallet);

      result += value;
    }

    return Balance(result, wallets);
  }

  static Future getHistoric() async {
    var balances = await _fetchWalletData();
    if (balances == null) return null;

    List<HistoricCurrency> result = [];

    for (var wallet in balances) {
      List<HistoricCurrency> test = await getHistoricCurrency(wallet['id']);

      print(test);
    }

    return result;
  }

  static Future<List<HistoricCurrency>> getHistoricCurrency(String id) async {
    var test = await _fetchHistoric(id);

    List<HistoricCurrency> result = [];
    for (var temp in test) {
      HistoricCurrency rightBefore = HistoricCurrency(
          DateTime.parse(temp['created_at']).subtract(Duration(seconds: 1)),
          result.isEmpty ? 0 : result.last.balance,
          null);
      HistoricCurrency actual = HistoricCurrency(
          DateTime.parse(temp['created_at']),
          double.parse(temp['balance']),
          null);
      result.add(rightBefore);
      result.add(actual);
    }
    result.sort((a, b) => a.time.compareTo(b.time));

    return result;
  }

  static Future _fetchWalletData() async {
    var options = {'method': 'GET', 'endPoint': '/accounts', 'body': ''};
    return await RequestController.sendRequestWithAuth(options);
  }

  static Future _fetchHistoric(String id) async {
    var options = {
      'method': 'GET',
      'endPoint': '/accounts/$id/ledger',
      'body': ''
    };
    return await RequestController.sendRequestWithAuth(options);
  }

  static Future _fetchPriceOfCurrency(String currency) async {
    return (await RequestController.sendRequestNoAuth(null,
        currency: currency));
  }

  static Future _fetchProducts() async {
    var options = {'method': 'GET', 'endPoint': '/products', 'body': ''};
    return await RequestController.sendRequestNoAuth(options);
  }

  static Future _fetch24hrStats(String productId) async {
    var options = {
      'method': 'GET',
      'endPoint': '/products/$productId/stats',
      'body': ''
    };
    return await RequestController.sendRequestNoAuth(options);
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
    return await RequestController.sendRequestWithAuth(options);
  }

  static Future _fetchCandlesData(String product, [int granularity]) async {
    DateTime now = new DateTime.now();
    DateTime start = (granularity == null)
        ? new DateTime.now().subtract(Duration(days: 1))
        : new DateTime.now().subtract(Duration(seconds: (granularity * 300)));

    if (granularity == null) granularity = 3600;

    var options = {
      'method': 'GET',
      'endPoint':
          '/products/$product/candles?granularity=$granularity&start=${start.toUtc().toIso8601String()}&end=${now.toUtc().toIso8601String()}',
      'body': ''
    };
    // print(options);
    return await RequestController.sendRequestNoAuth(options, sandbox: false);
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
