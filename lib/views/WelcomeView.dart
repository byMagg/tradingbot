import 'package:flutter/material.dart';
import 'package:tradingbot/widgets/TitleWidget.dart';

import 'HomeView.dart';

class WelcomeView extends StatelessWidget {
  WelcomeView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                fit: BoxFit.fitHeight,
                image: AssetImage(
                  'lib/assets/welcome.jpg',
                ),
              ),
            ),
            height: MediaQuery.of(context).size.height,
          ),
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(1),
                      Colors.white70,
                    ],
                    stops: [
                      0.0,
                      1
                    ])),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TitleWidget(50),
              SizedBox(
                height: 20,
              ),
              MaterialButton(
                minWidth: 200,
                elevation: 0,
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(18.0),
                    side: BorderSide(color: Theme.of(context).primaryColor)),
                onPressed: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HomeView()));
                },
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Welcome".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
