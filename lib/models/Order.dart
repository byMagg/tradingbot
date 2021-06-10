class Order extends Comparable {
  String productId;
  String id;
  double price;
  double size;
  DateTime date;
  String side;
  String type;
  String status;

  Order(String productId, double price, double size, DateTime date, String side,
      String type, String status) {
    this.productId = productId;
    this.price = price;
    this.size = size;
    this.date = date;
    this.side = side;
    this.type = type;
    this.status = status;
  }

  Order.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        productId = json['product_id'],
        type = json['type'],
        status = json['status'],
        price = (json['status'] == "open")
            ? double.parse(json['price'])
            : (double.parse(json['executed_value']) /
                double.parse(json['filled_size'])),
        size = double.parse(json['filled_size']),
        date = DateTime.parse(json['created_at']),
        side = json['side'];

  @override
  int compareTo(other) {
    return this.date.compareTo(other.date);
  }
}
