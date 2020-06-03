import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/MainController.dart';
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
    double cardMargin = 5;

    return Expanded(
        child: StreamBuilder(
      stream: this.mainController.initCurrencies(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          var _wallet = snapshot.data.documents;

          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _wallet.length,
              itemBuilder: (context, index) {
                var number = NumberFormat.compactCurrency(
                        decimalDigits: 2, symbol: '\$ ')
                    .format(_wallet[index]["totalUSD"]);
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
                          builder: (context) => CurrencyView(symbol: _wallet[index].documentID,
                                  )
                                  ));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.2 -
                          (cardMargin * 2),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            height: 40,
                            child: Image(
                              image: AssetImage(
                                  'lib/assets/currencies/color/${_wallet[index].documentID.toLowerCase()}.png'),
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
