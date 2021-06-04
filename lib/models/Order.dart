class Order extends Comparable {
  String productId;
  double currency1;
  double currency2;
  DateTime date;
  bool buy; //TRUE = BUY

  Order(String productId, double currency1, double currency2, DateTime date,
      bool buy) {
    this.productId = productId;
    this.currency1 = currency1;
    this.currency2 = currency2;
    this.date = date;
    this.buy = buy;
  }

  Order.fromJson(Map<String, dynamic> json)
      : productId = json['product_id'],
        currency1 = double.parse(json['filled_size']),
        currency2 = double.parse(json['executed_value']),
        date = DateTime.parse(json['created_at']),
        buy = json['side'] == "buy" ? true : false;

  @override
  int compareTo(other) {
    return this.date.compareTo(other.date);
  }
}
