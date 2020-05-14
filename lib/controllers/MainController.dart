import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tradingbot/models/Currency.dart';

class MainController {
  Stream<QuerySnapshot> initWallets() {
    return Firestore.instance.collection('currencies').snapshots();
  }

  Stream<QuerySnapshot> initBalance() {
    return Firestore.instance.collection('balances').snapshots();
  }

  Stream<QuerySnapshot> initAllOperations() {
    return Firestore.instance.collection('operations').snapshots();
  }

  Stream<QuerySnapshot> initOperations(Currency currency) {
    return Firestore.instance
        .collection('operations')
        .where('symbol', isEqualTo: currency.symbol)
        .snapshots();
  }
}
