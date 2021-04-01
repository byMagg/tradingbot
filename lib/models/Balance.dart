import 'package:tradingbot/models/Wallet.dart';

class Balance {
  double totalBalance;
  List<Wallet> wallets;

  Balance(double totalBalance, List<Wallet> wallets) {
    wallets.sort();
    this.totalBalance = totalBalance;
    this.wallets = wallets;
  }
}
