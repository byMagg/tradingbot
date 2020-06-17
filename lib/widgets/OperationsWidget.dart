import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:tradingbot/views/OperationsView.dart';

class OperationsWidget extends StatefulWidget {
  final List orders;
  final bool everything;
  final bool fixed;

  OperationsWidget(
      {Key key,
      @required this.orders,
      @required this.everything,
      @required this.fixed})
      : super(key: key);

  @override
  _OperationsWidgetState createState() => _OperationsWidgetState();

  getItemListTile(context, index, _operations) {
    var currency1Number = NumberFormat.decimalPattern("eu")
        .format(double.parse(_operations[index]['currency1']))
        .toString();
    var currency2Number = NumberFormat.decimalPattern("eu")
        .format(double.parse(_operations[index]['currency2']))
        .toString();

    var splittedProduct = _operations[index]['product_id'].split("-");

    var currency1Name = splittedProduct[0];
    var currency2Name = splittedProduct[1];

    var widget = Row(
      children: <Widget>[
        Text(_operations[index]['product_id']),
        SizedBox(
          width: 10,
        ),
        Text(currency1Number),
        Text(" / " + currency2Number),
      ],
    );

    var date = _operations[index]['date'];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
              borderRadius: BorderRadius.all(Radius.circular(15))),
          child: ListTile(
              trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("${date.toString().substring(0, 10)}"),
                    Text("${date.toString().substring(11, 19)}")
                  ]),
              title: widget)),
    );
  }

  listOperations() {
    if (this.orders.isEmpty) return Text("WAITING");
    List _operations = this.orders.toList();

    return _operations.length == 0
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
        : everything && !fixed
            ? Expanded(
                child: ListView.builder(
                    itemCount: _operations.length,
                    itemBuilder: (context, index) {
                      return getItemListTile(context, index, _operations);
                    }))
            : Container(
                child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: everything ? _operations.length : 5,
                    itemBuilder: (context, index) {
                      return getItemListTile(context, index, _operations);
                    }));
  }
}

class _OperationsWidgetState extends State<OperationsWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          !widget.fixed
              ? Padding(
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
                )
              : Container(),
          widget.listOperations(),
          !widget.fixed
              ? MaterialButton(
                  height: 50,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: Text("View more")),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => OperationsView(
                              orders: widget.orders,
                            )));
                  },
                )
              : Container(),
        ],
      ),
    );
  }
}
