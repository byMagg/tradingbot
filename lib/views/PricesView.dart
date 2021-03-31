import 'package:flutter/material.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/streams/BalanceStream.dart';

class PricesView extends StatefulWidget {
  @override
  _PricesViewState createState() => _PricesViewState();
}

class _PricesViewState extends State<PricesView> {
  @override
  Widget build(BuildContext context) {
    balanceStream.fetchData();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: StreamBuilder(
          stream: balanceStream.stream,
          builder: (context, AsyncSnapshot<Balance> snapshot) {
            if (snapshot.hasData) {
              List<Wallet> _wallets = snapshot.data.wallets;
              return ListView.builder(
                  itemCount: _wallets.length,
                  itemBuilder: (context, index) {
                    var number = _wallets[index].priceUSD;

                    return ListTile(
                      leading: SizedBox(
                        height: 30,
                        child: Image(
                          image: AssetImage(
                              'lib/assets/currencies/color/${_wallets[index].currency.toLowerCase()}.png'),
                        ),
                      ),
                      title: Text(
                        _wallets[index].name,
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      subtitle: Text(
                        _wallets[index].currency,
                        style: TextStyle(color: Colors.black45),
                      ),
                      trailing: Text(
                        "\$ ${number.toStringAsFixed(6)}",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onTap: () {},
                    );
                  });
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
