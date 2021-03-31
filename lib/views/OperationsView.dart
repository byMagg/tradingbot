import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tradingbot/models/Order.dart';
import 'package:tradingbot/streams/OrdersStream.dart';

import 'package:tradingbot/widgets/OperationsWidget.dart';

class OperationsView extends StatefulWidget {
  final List orders;

  OperationsView({
    Key key,
    @required this.orders,
  }) : super(key: key);

  @override
  _OperationsViewState createState() => _OperationsViewState();
}

class _OperationsViewState extends State<OperationsView> {
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
      body: StreamBuilder(
          stream: ordersStream.stream,
          builder: (context, AsyncSnapshot<List<Order>> snapshot) {
            if (snapshot.hasData) {
              return OperationsWidget(
                orders: snapshot.data,
                everything: true,
                fixed: false,
              );
            }
            return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
