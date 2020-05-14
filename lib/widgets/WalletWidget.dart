import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/MainController.dart';
import 'package:tradingbot/models/Currency.dart';
import 'package:tradingbot/views/CurrencyView.dart';

class WalletWidget extends StatefulWidget {
  WalletWidget({Key key}) : super(key: key);

  @override
  WalletWidgetState createState() => WalletWidgetState();
}

class WalletWidgetState extends State<WalletWidget> {
  MainController mainController;

  @override
  void initState() {
    super.initState();
    this.mainController = MainController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 120,
        child: StreamBuilder(
          stream: this.mainController.initWallets(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var _wallet = snapshot.data.documents;
              return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _wallet.length,
                  itemBuilder: (context, index) {
                    var number = NumberFormat.compactCurrency(
                            decimalDigits: 2, symbol: '\$ ')
                        .format(_wallet[index]["priceUSD"] *
                            _wallet[index]["balance"]);
                    return Card(
                      margin: EdgeInsets.only(left: 8, right: 8, bottom: 10),
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => CurrencyView(
                                  currency: new Currency(
                                      _wallet[index]['name'],
                                      _wallet[index]['symbol'],
                                      _wallet[index]['balance'],
                                      _wallet[index]['priceUSD']))));
                        },
                        child: Container(
                          width: 82,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 40,
                                child: Image(
                                  image: AssetImage(
                                      'lib/assets/currencies/${_wallet[index]["symbol"].toLowerCase()}.png'),
                                ),
                              ),
                              SizedBox(
                                height: 25,
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
                  });
            } else {
              return Center(
                  child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ));
            }
          },
        ));
  }
}
