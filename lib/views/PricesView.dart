import 'package:flutter/material.dart';
import 'package:tradingbot/controllers/MainController.dart';

class PricesView extends StatefulWidget {
  @override
  _PricesViewState createState() => _PricesViewState();
}

class _PricesViewState extends State<PricesView> {
  MainController mainController;

  @override
  void initState() {
    super.initState();
    this.mainController = MainController();
  }

  @override
  Widget build(BuildContext context) {
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
          stream: this.mainController.initCurrencies(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var _wallets = snapshot.data.documents;
              return ListView.builder(
                  itemCount: _wallets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: SizedBox(
                        height: 50,
                        child: Image(
                          image: AssetImage(
                              'lib/assets/currencies/color/${_wallets[index]["symbol"].toLowerCase()}.png'),
                        ),
                      ),
                      title: Text(_wallets[index]["name"],
                          style:
                              TextStyle(color: Theme.of(context).primaryColor)),
                      subtitle: Text(_wallets[index]["symbol"]),
                      trailing: Text(
                        "\$ ${_wallets[index]["priceUSD"].toStringAsFixed(6)}",
                        style: TextStyle(color: Theme.of(context).primaryColor),
                      ),
                      onTap: () {},
                    );
                  });
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
