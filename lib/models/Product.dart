import 'package:k_chart/entity/k_line_entity.dart';

class Product {
  final String id;
  final String displayName;
  List<KLineEntity> candles = [];

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        displayName = json['display_name'];
}
