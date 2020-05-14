class Currency extends Comparable {
  final String name;
  final String symbol;
  final double balance;
  final double priceUSD;

  Currency({this.name, this.symbol, this.balance, this.priceUSD});

  @override
  int compareTo(other) {
    if ((this.priceUSD * this.balance) == (other.priceUSD * other.balance))
      return 0;
    return ((this.priceUSD * this.balance) > (other.priceUSD * other.balance))
        ? -1
        : 1;
  }
}
