import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tradingbot/controllers/MainController.dart';
import 'package:tradingbot/widgets/OperationsWidget.dart';

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
          OperationsWidget.listOperations(
              this.mainController.initAllOperations(), true)
        ],
      ),
    );
  }
}
