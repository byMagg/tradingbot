import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradingbot/models/Currency.dart';

class MainController {
  Stream<QuerySnapshot> initCurrencies() {
    return Firestore.instance
        .collection('currencies')
        .orderBy('totalUSD', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> initAllOperations() {
    return Firestore.instance
        .collection('operations')
        .orderBy('date', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> initOperations(Currency currency) {
    return Firestore.instance
        .collection('operations')
        .where('symbol', isEqualTo: currency.symbol)
        .orderBy('date', descending: true)
        .snapshots();
  }
}
