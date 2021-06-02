import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({
    Key key,
    @required this.child,
  }) : super(key: key);

  final Widget child;
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: widget.child,
    );
  }
}
