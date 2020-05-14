import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:tradingbot/controllers/MainController.dart';
import 'package:tradingbot/models/Currency.dart';
import 'package:tradingbot/widgets/SimpleLineChart.dart';

class CurrencyView extends StatefulWidget {
  final Currency currency;

  CurrencyView({Key key, @required this.currency}) : super(key: key);

  @override
  _CurrencyViewState createState() => _CurrencyViewState();
}

class _CurrencyViewState extends State<CurrencyView> {
  MainController mainController;

  @override
  void initState() {
    super.initState();
    this.mainController = MainController();
  }

  _listOperations() {
    print(widget.currency.name);
    return Container(
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 270,
          ),
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Operations",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                StreamBuilder(
                    stream: this.mainController.initOperations(widget.currency),
                    builder: (context, snapshot) {
                      var _operations = snapshot.data.documents;

                      return _operations.isEmpty
                          ? Container(
                              height: 350,
                              child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "There are no operations for this currency",
                                    style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),
                                  )),
                            )
                          : Container(
                              color: Theme.of(context).primaryColor,
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  primary: false,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _operations.length,
                                  itemBuilder: (context, index) {
                                    var transaction =
                                        NumberFormat.decimalPattern("eu")
                                            .format(_operations[index]
                                                ['transaction'])
                                            .toString();

                                    var widget;

                                    var date =
                                        _operations[index]['date'].toDate();

                                    if (transaction.contains("−")) {
                                      widget = ListTile(
                                        trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  "${date.toString().substring(0, 10)}"),
                                              Text(
                                                  "${date.toString().substring(10, 19)}")
                                            ]),
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.red,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              "${transaction.toString().substring(1)}",
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                        onTap: () {},
                                      );
                                    } else {
                                      widget = ListTile(
                                        trailing: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                  "${date.toString().substring(0, 10)}"),
                                              Text(
                                                  "${date.toString().substring(10, 19)}")
                                            ]),
                                        title: Row(
                                          children: [
                                            Icon(
                                              Icons.keyboard_arrow_up,
                                              color: Colors.green,
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Text(
                                              "$transaction",
                                              style: TextStyle(
                                                  color: Colors.green),
                                            ),
                                          ],
                                        ),
                                        onTap: () {},
                                      );
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15))),
                                          child: widget),
                                    );
                                  }));
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 25,
              child: Image(
                image: AssetImage(
                    'lib/assets/currencies/${widget.currency.symbol.toLowerCase()}.png'),
              ),
            ),
            SizedBox(width: 10),
            Text(
              widget.currency.name,
              style: TextStyle(fontWeight: FontWeight.w400),
            )
          ],
        ),
      ),
      body: Stack(children: [
        Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                    height: 250, child: SimpleLineChart.withSampleData()),
              ),
            ),
            Container(
              height: 70,
              color: Colors.white,
            )
          ],
        ),
        _listOperations()
      ]),
    );
  }
}
