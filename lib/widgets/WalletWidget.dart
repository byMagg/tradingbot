import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/views/CurrencyView.dart';
import 'package:tradingbot/models/Currency.dart';

class WalletWidget extends StatefulWidget {
  final List<Currency> wallets;
  final List<Order> orders;

  WalletWidget({Key key, @required this.wallets, @required this.orders})
      : super(key: key);

  @override
  WalletWidgetState createState() => WalletWidgetState();
}

class WalletWidgetState extends State<WalletWidget> {
  @override
  Widget build(BuildContext context) {
    double cardMargin = 5;

    double cardWidth =
        MediaQuery.of(context).size.width * 0.2 - (cardMargin * 2);
    List<Currency> it = widget.wallets;

    return Expanded(
        child: (it.isEmpty)
            ? Center(
                child: Text(
                "We are loading your wallets...",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ))
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: it.length,
                itemBuilder: (context, index) {
                  String currency = it[index].currency;
                  String number = NumberFormat.compactCurrency(
                          decimalDigits: 2, symbol: '\$ ')
                      .format(it[index].value);

                  return Card(
                    margin: EdgeInsets.only(
                        left: cardMargin, right: cardMargin, bottom: 10),
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => CurrencyView(
                                  orders: widget.orders,
                                  symbol: currency,
                                )));
                      },
                      child: Container(
                        width: cardWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: 40,
                              child: Image(
                                image: AssetImage(
                                    'lib/assets/currencies/color/${currency.toLowerCase()}.png'),
                              ),
                            ),
                            Text(
                              "$number",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }));
  }
}
