import 'package:flutter/material.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/streams/BalanceStream.dart';
import 'package:tradingbot/views/DonutView.dart';

import 'package:tradingbot/views/SettingsView.dart';

class ProfileView extends StatelessWidget {
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
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SettingsView()));
              }),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 4,
                          offset: Offset(0, 0), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('lib/assets/user.jpg'),
                      )),
                ),
              ),
            ),
            Text(
              "Hi, Dani!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, right: 50, left: 50),
              child: Divider(
                color: Theme.of(context).primaryColor,
                thickness: 2,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  "Your Balance",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Theme.of(context).primaryColor),
                ),
              ),
            ),
            DonutView(),
            StreamBuilder(
                stream: balanceStream.stream,
                builder: (context, AsyncSnapshot<Balance> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data.wallets.length,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var actualWallet = snapshot.data.wallets[index];
                          return ListTile(
                            leading: SizedBox(
                              height: 40,
                              child: Image(
                                image: AssetImage(
                                    'lib/assets/currencies/color/${actualWallet.currency.toLowerCase()}.png'),
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    "${actualWallet.amount.toStringAsFixed(7)}"),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    "${actualWallet.currency}",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }
                  return CircularProgressIndicator();
                })
          ],
        ),
      ),
    );
  }
}
