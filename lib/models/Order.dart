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

  @override
  int compareTo(other) {
    return this.date.compareTo(other.date);
  }
}
