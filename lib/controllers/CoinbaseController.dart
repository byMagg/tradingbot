import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:tradingbot/models/Currency.dart';

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

  Future<double> getValue() async {
    var value = await _fetchCoinbasePro().then((value) => value);

    return (value == null) ? 0 : double.parse(value['value']);
  }

  Future<List<Currency>> getCurrencies() async {
    var currencies = await _fetchCoinbasePro().then((value) => value);
    var fills = await _fetchOrders().then((value) => value);

    return (currencies == null) ? List<Currency>() : currencies['balances'];
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
    if (orders == null) return null;

    List data = [];

    for (var item in orders) {
      if (item['size'] == null) {
        data.add({
          "product_id": item['product_id'],
          "side": item['side'],
          "specified_funds": item['specified_funds'],
          "executed_value": item['executed_value']
        });
      } else {
        data.add({
          "product_id": item['product_id'],
          "side": item['side'],
          "size": item['size'],
          "executed_value": item['executed_value']
        });
      }
    }

    print(data);

    return data;
  }

  Future _fetchCoinbasePro() async {
    var balances = await _getBalance();
    if (balances == null) return null;

    List<Currency> wallets = [];

    for (var balance in balances) {
      wallets.add(new Currency(
          balance['currency'], double.parse(balance['balance']), 0));
    }

    var data = {'balances': wallets, 'value': 0};

    return await _calculateValueOfCurrencies(data);
  }

  Future _calculateValueOfCurrencies(data) async {
    List<Currency> wallets = data['balances'];
    double result = 0;

    try {
      for (var wallet in wallets) {
        if (wallet.currency == 'USD') {
          wallet.value = wallet.amount;
        } else {
          var coinPrices =
              await get('https://api.coingecko.com/api/v3/coins/list')
                  .then((res) => json.decode(res.body));

          for (var coin in coinPrices) {
            if (wallet.currency == coin['symbol'].toUpperCase()) {
              var id = coin['id'];
              var response = await get(
                      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$id')
                  .then((res) => json.decode(res.body));
              wallet.value =
                  double.parse(response[0]['current_price'].toString()) *
                      wallet.amount;
              break;
            }
          }
        }
        result += wallet.value;
      }
      data['value'] = result.toStringAsFixed(2);
      wallets.sort();

      return data;
    } on Exception {
      return Exception;
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

  _getBalance() async {
    var request = {'method': 'GET', 'endPoint': '/accounts', 'body': ''};
    Response response = await this._response(request);

    if (response != null && response.statusCode == 200) {
      var result = json.decode(response.body);
      var balance = [];
      for (var res in result) {
        balance.add(res);
      }
      return balance;
    }
    return null;
  }

  _getOrders() async {
    var request = {
      'method': 'GET',
      'endPoint': '/orders?status=done&product_id=BTC-USD',
      'body': ''
    };
    Response response = await this._response(request);

    if (response != null && response.statusCode == 200) {
      var result = json.decode(response.body);
      var balance = [];
      for (var res in result) {
        balance.add(res);
      }
      return balance;
    }
    return null;
  }
}
