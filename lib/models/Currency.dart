class Currency extends Comparable {
  String name;
  String symbol;
  double balance;
  double priceUSD;
  double totalUSD;

  Currency(String name, String symbol, double balance, double priceUSD,
      double totalUSD) {
    this.name = name;
    this.symbol = symbol;
    this.balance = balance;
    this.priceUSD = priceUSD;
    this.totalUSD = totalUSD;
  }

  @override
  int compareTo(other) {
    if ((this.priceUSD * this.balance) == (other.priceUSD * other.balance))
      return 0;
    return ((this.priceUSD * this.balance) > (other.priceUSD * other.balance))
        ? -1
        : 1;
  }
}
