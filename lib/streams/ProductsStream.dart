import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';

class ProductsStream {
  final BehaviorSubject<List> _productsStream = BehaviorSubject<List>();
  Stream<List> get stream => _productsStream.stream;

  fetchData() async {
    List products = await CoinbaseController.getProducts();
    _productsStream.add(products);
  }
}

final productsStream = ProductsStream();
