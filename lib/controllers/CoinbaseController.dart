import 'dart:convert';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';

class CoinbaseController {
  Stream getBalance() async* {
    yield await _fetchCoinbasePro().then((value) => value['value']);
  }

  Stream getCurrencies() async* {
    yield await _fetchCoinbasePro().then((value) => value['balances']);
  }

  Future _fetchCoinbasePro() async {
    final apikey = "f5e39c91cc9636966d2a630f259f9cbc";
    final secret =
        "Uhfp4rqy69aeoKotpjV2KoXxXH+It05yHiIjwFwrRTlk115XYGukuoSkFByiFE9+4X0DgIHmIk+btMwnvBxGyg==";
    final passphrase = "vwvomszp10d";

    final coinbasePro = new CoinbasePro(apikey, secret, passphrase);
    var balances = await coinbasePro.getBalance();
    if (balances == null) {
      return null;
    }

    var wallets = [];

    for (var balance in balances) {
      wallets.add({
        'currency': balance['currency'],
        'amount': balance['balance'],
      });
    }

    var data = {'balances': wallets, 'value': 0};

    data = await _calculateAmount(data);

    return data;
  }

  _calculateAmount(data) async {
    var coingecko = await get('https://api.coingecko.com/api/v3/coins/list')
        .then((res) => json.decode(res.body));
    var id;
    double result = 0;
    var wallets = data['balances'];

    try {
      for (var wallet in wallets) {
        var currency = wallet['currency'];

        var amount = double.parse(wallet['amount']);

        double currencyPrice = 0;

        double eur;

        var icon;
        var fiat = "USD";
        if (currency == 'EUR' || currency == 'USD' || currency == 'GBP') {
          if (currency == fiat) {
            eur = amount;
            wallet['value'] = eur.toStringAsFixed(2);
          } else {
            var exchangeRate = await get(
                    'https://api.exchangeratesapi.io/latest?base=$currency&symbols=$fiat')
                .then((res) => json.decode(res.body)['rates'][fiat]);
            eur = amount * exchangeRate;
            wallet['value'] = eur.toStringAsFixed(2);
          }

          icon = _fetchIcons(currency);
        } else {
          for (int i = 0; i < coingecko.length; i++) {
            if (currency == coingecko[i]['symbol'].toUpperCase()) {
              id = coingecko[i]['id'];
              break;
            }
          }

          var response = await get(
                  'https://api.coingecko.com/api/v3/coins/markets?vs_currency=${fiat.toLowerCase()}&ids=$id')
              .then((res) => json.decode(res.body));

          currencyPrice = double.parse(response[0]['current_price'].toString());

          eur = currencyPrice * amount;
          wallet['value'] = eur.toStringAsFixed(2);
          icon = response[0]['image'];
        }
        result += eur;
        wallet['icon'] = icon;
      }

      data['value'] = result.toStringAsFixed(2);

      return data;
    } on Exception {
      return null;
    }
  }

  _fetchIcons(id) {
    if (id == 'EUR')
      return 'http://cdn.onlinewebfonts.com/svg/img_408170.png';
    else if (id == 'GBP')
      return 'http://cdn.onlinewebfonts.com/svg/img_221173.png';
    else if (id == 'USD') {
      return 'http://cdn.onlinewebfonts.com/svg/img_455423.png';
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
}
