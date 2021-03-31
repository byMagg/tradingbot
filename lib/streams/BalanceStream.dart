import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Balance.dart';

class BalanceStream {
  final BehaviorSubject<Balance> _balanceCount = BehaviorSubject<Balance>();
  Stream<Balance> get stream => _balanceCount.stream;

  fetchData() async {
    Balance balance = await CoinbaseController.getBalances();
    _balanceCount.add(balance);
  }
}

final balanceStream = BalanceStream();
