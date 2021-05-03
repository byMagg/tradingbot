import 'package:flutter/material.dart';
import 'package:tradingbot/models/Balance.dart';
import 'package:tradingbot/models/Wallet.dart';
import 'package:tradingbot/streams/BalanceStream.dart';
import 'package:tradingbot/widgets/SimpleTimeSeriesChart.dart';

class PricesView extends StatefulWidget {
  @override
  _PricesViewState createState() => _PricesViewState();
}

class _PricesViewState extends State<PricesView> {
  @override
  Widget build(BuildContext context) {
    balanceStream.fetchData();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            "Market Prices",
            style: TextStyle(
                fontSize: 25,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold),
          ),
        ),
        StreamBuilder(
            stream: balanceStream.stream,
            builder: (context, AsyncSnapshot<Balance> snapshot) {
              if (snapshot.hasData) {
                List<Wallet> _wallets = snapshot.data.wallets;
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                          style:
                              TextStyle(color: Theme.of(context).primaryColor),
                        ),
                        subtitle: Text(
                          _wallets[index].currency,
                          style: TextStyle(color: Colors.black45),
                        ),

                        trailing: Container(
                          width: 240,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    width: 150,
                                    child: AbsorbPointer(
                                        child: SimpleTimeSeriesChart
                                            .withSampleData(false))),
                                Text(
                                  "\$ ${number.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor),
                                )
                              ]),
                        ),
                        // trailing: Text(
                        //   "\$ ${number.toStringAsFixed(2)}",
                        //   style: TextStyle(color: Theme.of(context).primaryColor),
                        // ),
                        onTap: () {},
                      );
                    });
              }
              return Center(child: CircularProgressIndicator());
            }),
      ],
    );
  }
}
