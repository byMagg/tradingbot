class Currency extends Comparable {
  String currency;
  double amount;
  double value;

  Currency(String currency, double amount, double value) {
    this.currency = currency;
    this.amount = amount;
    this.value = value;
  }

  @override
  int compareTo(other) {
    if (this.value == other.value) return 0;
    return (this.value > other.value) ? -1 : 1;
  }
}
