import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Balance.dart';

class BalanceStream {
  final PublishSubject<Balance> _contactCount = PublishSubject<Balance>();
  Stream<Balance> get contactCount => _contactCount.stream;

  fetchData() async {
    Balance balance = await CoinbaseController.getBalances();

    print(balance.totalBalance);
    _contactCount.sink.add(balance);
  }

  // Stream<Balance> get contactListView async* {
  //   yield await CoinbaseController.getBalances();
  // }

  dispose() {
    _contactCount.close();
  }

  // BalanceStream() {
  //   contactListView.listen((list) => _contactCount.add(list));
  // }
}

final balanceStream = BalanceStream();
