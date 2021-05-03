import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static final API_KEY = env['API_KEY'];
  static final API_SECRET = env['API_SECRET'];
  static final API_PASSPHRASE = env['API_PASSPHRASE'];
  static final SANDBOX = env['SANDBOX'];
  static const API_URL_SANDBOX = 'https://api-public.sandbox.pro.coinbase.com';
  static const API_URL = 'https://api.pro.coinbase.com';
}
