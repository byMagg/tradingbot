class Currency extends Comparable {
  String currency;
  String name;
  double amount;
  double value;
  double priceUSD;

  Currency(String currency, String name, double amount, double value,
      double priceUSD) {
    this.currency = currency;
    this.name = name;
    this.amount = amount;
    this.value = value;
    this.priceUSD = priceUSD;
  }

  @override
  int compareTo(other) {
    if (this.value == other.value) return 0;
    return (this.value > other.value) ? -1 : 1;
  }
}
