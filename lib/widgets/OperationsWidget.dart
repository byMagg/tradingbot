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
                                  NumberFormat.decimalPattern("eu")
                                      .format(_operations[index]["transaction"])
                                      .toString();

                              var widget;

                              if (transaction.contains("−")) {
                                widget = ListTile(
                                  trailing: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                            "${_operations[index]["date"].toString().substring(0, 10)}"),
                                        Text(
                                            "${_operations[index]["date"].toString().substring(10, 19)}")
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
                                        style: TextStyle(color: Colors.red),
                                      ),
                                      Text(
                                        " ${_operations[index]["symbol"]}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300),
                                      )
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
                                            "${_operations[index]["date"].toString().substring(0, 10)}"),
                                        Text(
                                            "${_operations[index]["date"].toString().substring(10, 19)}")
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
                                        style: TextStyle(color: Colors.green),
                                      ),
                                      Text(
                                        " ${_operations[index]["symbol"]}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300),
                                      )
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
                                            spreadRadius: 4,
                                            blurRadius: 5,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15))),
                                    child: widget),
                              );
                            }));
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
