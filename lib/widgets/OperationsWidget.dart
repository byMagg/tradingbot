import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/MainController.dart';
import 'package:tradingbot/views/OperationsView.dart';

class OperationsWidget extends StatefulWidget {
  @override
  _OperationsWidgetState createState() => _OperationsWidgetState();
}

class _OperationsWidgetState extends State<OperationsWidget> {
  MainController mainController;

  @override
  void initState() {
    super.initState();
    this.mainController = MainController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Recent operations",
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          StreamBuilder(
              stream: this.mainController.initAllOperations(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
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
                          child: ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.all(0),
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                var transaction =
                                    NumberFormat.decimalPattern("eu").format(
                                        double.parse(
                                            _operations[index]["transaction"]));

                                var widget;

                                var date = _operations[index]['date'].toDate();

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
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                            height: 25,
                                            child: Image(
                                              image: AssetImage(
                                                  'lib/assets/currencies/black/${_operations[index]["symbol"].toLowerCase()}.png'),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "${transaction.toString().substring(1)}",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ],
                                    ),
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
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Container(
                                            height: 25,
                                            child: Image(
                                              image: AssetImage(
                                                  'lib/assets/currencies/black/${_operations[index]["symbol"].toLowerCase()}.png'),
                                            ),
                                          ),
                                        ),
                                        Text(
                                          "$transaction",
                                          style: TextStyle(color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(0.3),
                                              spreadRadius: 2,
                                              blurRadius: 4,
                                              offset: Offset(0,
                                                  4), // changes position of shadow
                                            ),
                                          ],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      child: widget),
                                );
                              }));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              }),
          MaterialButton(
            height: 50,
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Center(child: Text("View more")),
            ),
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => OperationsView()));
            },
          ),
        ],
      ),
    );
  }
}
