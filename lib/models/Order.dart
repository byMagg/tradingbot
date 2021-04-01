class Order extends Comparable {
  String productId;
  double currency1;
  double currency2;
  DateTime date;

  Order(String productId, double currency1, double currency2, DateTime date) {
    this.productId = productId;
    this.currency1 = currency1;
    this.currency2 = currency2;
    this.date = date;
  }

  Order.fromJson(Map<String, dynamic> json)
      : productId = json['product_id'],
        currency1 = double.parse(json['filled_size']),
        currency2 = double.parse(json['executed_value']),
        date = DateTime.parse(json['created_at']);

  @override
  int compareTo(other) {
    return this.date.compareTo(other.date);
  }
}
