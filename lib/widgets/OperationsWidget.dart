import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:tradingbot/models/Order.dart';

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

  getItemListTile(context, index, Order order) {
    var currency1Number =
        NumberFormat.decimalPattern("eu").format(order.price).toString();

    var widget = Row(
      children: <Widget>[
        Text(order.productId),
        SizedBox(
          width: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: order.side == "buy"
              ? Text(
                  "BUY",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                )
              : Text("SELL",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
        ),
        Text(currency1Number),
      ],
    );

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
                    Text("${order.date.toString().substring(0, 10)}"),
                    Text("${order.date.toString().substring(11, 19)}")
                  ]),
              title: widget)),
    );
  }

  listOperations(context) {
    if (this.orders.isEmpty)
      return Container(
        height: 350,
        child: Align(
            alignment: Alignment.center,
            child: Text(
              "There are no operations for this currency",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w400),
            )),
      );
    List _operations = this.orders.toList();

    return everything && !fixed
        ? Expanded(
            child: ListView.builder(
                itemCount: _operations.length,
                itemBuilder: (context, index) {
                  return getItemListTile(context, index, _operations[index]);
                }))
        : Container(
            child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: everything
                    ? _operations.length
                    : (_operations.length < 5)
                        ? _operations.length
                        : 5,
                itemBuilder: (context, index) {
                  return getItemListTile(context, index, _operations[index]);
                }));
  }
}

class _OperationsWidgetState extends State<OperationsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          widget.listOperations(context),
        ],
      ),
    );
  }
}
