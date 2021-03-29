import 'package:tradingbot/models/Wallet.dart';

class Balance {
  final double totalBalance;
  final List<Wallet> wallets;

  Balance.fromJson(Map<String, dynamic> json)
      : totalBalance = json['value'],
        wallets = json['balances'];
}
