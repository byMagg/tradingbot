import 'dart:convert';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';
import 'package:tradingbot/Config.dart';

class RequestController {
  static _hmacSha256Base64(String message, String secret) {
    var base64 = new Base64Codec();
    var key = base64.decode(secret);
    var msg = utf8.encode(message);
    var hmac = new Hmac(sha256, key);
    var signature = hmac.convert(msg);

    return base64.encode(signature.bytes);
  }

  static sendRequest(options, [String currency, bool candle]) async {
    var response;
    if (currency == null && candle == null) {
      var timestamp = await get('https://api.coinbase.com/v2/time')
          .then((res) => json.decode(res.body))
          .then((res) => res['data']['epoch']);
      String query = timestamp.toString() +
          options['method'] +
          options['endPoint'] +
          options['body'];
      String signature = _hmacSha256Base64(query, Config.API_SECRET);
      var url = Config.API_URL_SANDBOX + options['endPoint'];

      response = await get(url, headers: {
        'CB-ACCESS-KEY': Config.API_KEY,
        'CB-ACCESS-SIGN': signature,
        'CB-ACCESS-TIMESTAMP': timestamp.toString(),
        'CB-ACCESS-PASSPHRASE': Config.API_PASSPHRASE
      });
    } else if (candle != null) {
      response = await get(Config.API_URL + options['endPoint']);
    } else {
      response =
          await get("https://api.coinbase.com/v2/prices/$currency-USD/spot");
    }

    if (response != null && response.statusCode == 200) {
      return json.decode(response.body);
    }
  }
}
