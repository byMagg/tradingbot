class Currency extends Comparable {
  String symbol;
  double balance;
  double priceUSD;
  double totalUSD;

  Currency(String symbol, double balance, double priceUSD,
      double totalUSD) {
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
