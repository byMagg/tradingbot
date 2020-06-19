import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:tradingbot/models/Currency.dart';
import 'package:tradingbot/models/Order.dart';

class CoinbaseController {
  String _apiKey;
  String _secret;
  String _passPhrase;
  String _base = 'https://api-public.sandbox.pro.coinbase.com';
  // String _base = 'https://api.pro.coinbase.com';

  CoinbaseController() {
    _loadApiKeys();
  }

  void _loadApiKeys() async {
    var jsonStr = await rootBundle.loadString('lib/assets/secrets.json');
    var jsonData = json.decode(jsonStr);
    this._apiKey = jsonData['key'];
    this._secret = jsonData['secret'];
    this._passPhrase = jsonData['passphrase'];
  }

  Future balances;

  refreshBalances() {
    this.balances = _fetchBalances();
  }

  Future<double> getValue() async {
    return await balances.then((value) => value['value']);
  }

  Future<List<Currency>> getCurrencies() async {
    return await balances.then((value) => value['balances']);
  }

  Future<List<Order>> getOrders() async {
    return await _fetchOrders().then((value) => value);
  }

  bool checkSameValueOfCurrencies(List<Currency> before, List<Currency> after) {
    if (before == null || after == null) return null;
    for (var i = 0; i < before.length; i++) {
      if (before[i].value.toStringAsFixed(2) !=
          after[i].value.toStringAsFixed(2)) return false;
    }
    return true;
  }

  Future _fetchOrders() async {
    var orders = await _getOrders();

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

  Future _fetchBalances() async {
    var balances = await _getBalance();
    if (balances == null) return null;

    List<Currency> wallets = [];

    try {
      var currencyPrices = await get(
              'https://api.exchangeratesapi.io/latest?symbols=EUR,GBP&base=USD')
          .then((value) => json.decode(value.body));

      var eurPrice = currencyPrices['rates']['EUR'];
      var gbpPrice = currencyPrices['rates']['GBP'];

      double result = 0;

      for (var wallet in balances) {
        String currency = wallet['currency'];
        String name = "";
        double amount = double.parse(wallet['balance']);
        double priceUSD = 0;
        double value = 0;

        if (currency == 'USD') {
          name = "United States Dollar";
          value = amount;
          priceUSD = 1;
        } else if (currency == 'EUR') {
          name = "Euro";
          priceUSD = 1 / eurPrice;
        } else if (currency == 'GBP') {
          name = "Great Britain Pound";
          priceUSD = 1 / gbpPrice;
        } else {
          var coinPrices =
              await get('https://api.coingecko.com/api/v3/coins/list')
                  .then((res) => json.decode(res.body));

          for (var coin in coinPrices) {
            if (currency == coin['symbol'].toUpperCase()) {
              var id = coin['id'];
              var response = await get(
                      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$id')
                  .then((res) => json.decode(res.body));
              name = coin['name'];
              priceUSD = double.parse(response[0]['current_price'].toString());
              value = priceUSD * amount;
              break;
            }
          }
        }
        wallets.add(new Currency(currency, name, amount, value, priceUSD));
        result += value;
      }
      wallets.sort();

      return {'balances': wallets, 'value': result};
    } catch (e) {
      return e;
    }
  }

  _hmacSha256Base64(String message, String secret) {
    var base64 = new Base64Codec();
    var key = base64.decode(secret);
    var msg = utf8.encode(message);
    var hmac = new Hmac(sha256, key);
    var signature = hmac.convert(msg);

    return base64.encode(signature.bytes);
  }

  _response(request) async {
    try {
      var timestamp = await get('https://api.coinbase.com/v2/time')
          .then((res) => json.decode(res.body))
          .then((res) => res['data']['epoch']);
      String query = timestamp.toString() +
          request['method'] +
          request['endPoint'] +
          request['body'];
      String signature = _hmacSha256Base64(query, this._secret);
      var url = _base + request['endPoint'];

      var response = await get(url, headers: {
        'CB-ACCESS-KEY': this._apiKey,
        'CB-ACCESS-SIGN': signature,
        'CB-ACCESS-TIMESTAMP': timestamp.toString(),
        'CB-ACCESS-PASSPHRASE': this._passPhrase
      });
      return response;
    } on Exception {
      return null;
    }
  }

  Future _getBalance() async {
    var request = {'method': 'GET', 'endPoint': '/accounts', 'body': ''};
    Response response = await this._response(request);

    if (response != null && response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }

  Future _getOrders() async {
    var request = {
      'method': 'GET',
      'endPoint': '/orders?status=done',
      'body': ''
    };
    Response response = await this._response(request);

    if (response != null && response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
