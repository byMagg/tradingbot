class Product {
  final String id;
  final String displayName;

  Product.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        displayName = json['display_name'];
}
