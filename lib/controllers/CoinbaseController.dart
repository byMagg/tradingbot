import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:tradingbot/models/Currency.dart';

class CoinbaseController {
  String apikey;
  String secret;
  String passphrase;
  CoinbasePro coinbasePro;

  CoinbaseController() {
    this.apikey = "f5e39c91cc9636966d2a630f259f9cbc";
    this.secret =
        "Uhfp4rqy69aeoKotpjV2KoXxXH+It05yHiIjwFwrRTlk115XYGukuoSkFByiFE9+4X0DgIHmIk+btMwnvBxGyg==";
    this.passphrase = "vwvomszp10d";
    this.coinbasePro = new CoinbasePro(apikey, secret, passphrase);
  }

  Future<double> getValue() async {
    return await _fetchCoinbasePro()
        .then((value) => double.parse(value['value']));
  }

  Future<List<Currency>> getCurrencies() async {
    return await _fetchCoinbasePro().then((value) => value['balances']);
  }

  bool isEqual(List<Currency> before, List<Currency> after) {
    for (var i = 0; i < before.length; i++) {
      if (before[i].value.toStringAsFixed(2) !=
          after[i].value.toStringAsFixed(2)) return false;
    }
    return true;
  }

  Future _fetchCoinbasePro() async {
    var balances = await coinbasePro.getBalance();
    if (balances == null) return null;

    List<Currency> wallets = [];

    for (var balance in balances) {
      wallets.add(new Currency(
          balance['currency'], double.parse(balance['balance']), 0));
    }

    var data = {'balances': wallets, 'value': 0};

    return await _calculateAmount(data);
  }

  _calculateAmount(data) async {
    List<Currency> wallets = data['balances'];
    double result = 0;

    try {
      for (var wallet in wallets) {
        if (wallet.currency == 'USD') {
          wallet.value = wallet.amount;
        } else {
          var coingecko =
              await get('https://api.coingecko.com/api/v3/coins/list')
                  .then((res) => json.decode(res.body));
          for (int i = 0; i < coingecko.length; i++) {
            if (wallet.currency == coingecko[i]['symbol'].toUpperCase()) {
              var response = await get(
                      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=$coingecko[i]["id"]')
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
      wallets.sort();
      data['value'] = result.toStringAsFixed(2);

      return data;
    } on Exception {
      return null;
    }
  }
}

class CoinbasePro {
  String _apiKey;
  String _secret;
  String _passPhrase;
  String _base = 'https://api-public.sandbox.pro.coinbase.com';

  CoinbasePro(String apiKey, String secret, String passPhrase) {
    this._apiKey = apiKey;
    this._secret = secret;
    this._passPhrase = passPhrase;
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

  getBalance() async {
    var request = {'method': 'GET', 'endPoint': '/accounts', 'body': ''};
    var response = await this._response(request);

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

  getFills() async {
    var request = {'method': 'GET', 'endPoint': '/accounts', 'body': ''};
    var response = await this._response(request);

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
