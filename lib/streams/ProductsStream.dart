import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:tradingbot/controllers/CoinbaseController.dart';
import 'package:tradingbot/models/Product.dart';

class ProductsStream {
  final BehaviorSubject<List<Product>> _productsStream =
      BehaviorSubject<List<Product>>();
  Stream<List<Product>> get stream => _productsStream.stream;

  fetchData() async {
    List<Product> products = await CoinbaseController.getProducts();
    _productsStream.add(products);
  }
}

final productsStream = ProductsStream();
