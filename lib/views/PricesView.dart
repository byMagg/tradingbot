import 'package:flutter/material.dart';
import 'package:tradingbot/models/Currency.dart';

class PricesView extends StatefulWidget {
  final List<Currency> wallets;

  PricesView({Key key, @required this.wallets}) : super(key: key);

  @override
  _PricesViewState createState() => _PricesViewState();
}

class _PricesViewState extends State<PricesView> {
  @override
  Widget build(BuildContext context) {
    var _wallets = widget.wallets;
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.of(context).pop();
              }),
        ),
        body: ListView.builder(
            itemCount: _wallets.length,
            itemBuilder: (context, index) {
              var number = _wallets[index].value / _wallets[index].amount;

              return ListTile(
                leading: SizedBox(
                  height: 30,
                  child: Image(
                    image: AssetImage(
                        'lib/assets/currencies/color/${_wallets[index].currency.toLowerCase()}.png'),
                  ),
                ),
                title: Text(
                  _wallets[index].currency,
                  style: TextStyle(color: Colors.black45),
                ),
                trailing: Text(
                  "\$ ${number.toStringAsFixed(6)}",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onTap: () {},
              );
            }));
  }
}
