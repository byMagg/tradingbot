import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Order.dart';

class OrdersStream {
  final BehaviorSubject<List<Order>> _ordersCount =
      BehaviorSubject<List<Order>>();
  Stream<List<Order>> get stream => _ordersCount.stream;

  void fetchData() async {
    var start = DateTime.now();
    List<Order> orders = await CoinbaseController.getOrders();
    var end = DateTime.now();
    print(end.difference(start).inSeconds);
    _ordersCount.add(orders);
  }
}

final ordersStream = OrdersStream();
