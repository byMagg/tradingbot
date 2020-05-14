import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tradingbot/controllers/MainController.dart';

class OperationsView extends StatefulWidget {
  @override
  _OperationsViewState createState() => _OperationsViewState();
}

class _OperationsViewState extends State<OperationsView> {
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
        title: Text("Operations"),
        centerTitle: true,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: Column(
        children: <Widget>[
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
                      : Expanded(
                          child: ListView.builder(
                              itemCount: _operations.length,
                              itemBuilder: (context, index) {
                                var transaction =
                                    NumberFormat.decimalPattern("eu")
                                        .format(double.tryParse(
                                            _operations[index]['transaction']))
                                        .toString();

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
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              })
        ],
      ),
    );
  }
}
