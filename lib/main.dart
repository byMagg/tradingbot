import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:tradingbot/streams/BalanceStream.dart';
import 'package:tradingbot/streams/OrdersStream.dart';
import 'package:tradingbot/streams/ProductsStream.dart';

import 'views/WelcomeView.dart';

Future<void> main() async {
  await DotEnv.load(fileName: ".env");
  await balanceStream.fetchData();
  // await ordersStream.fetchData();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Map<int, Color> color = {
    50: Color.fromRGBO(100, 39, 49, .1),
    100: Color.fromRGBO(100, 39, 49, .2),
    200: Color.fromRGBO(100, 39, 49, .3),
    300: Color.fromRGBO(100, 39, 49, .4),
    400: Color.fromRGBO(100, 39, 49, .5),
    500: Color.fromRGBO(100, 39, 49, .6),
    600: Color.fromRGBO(100, 39, 49, .7),
    700: Color.fromRGBO(100, 39, 49, .8),
    800: Color.fromRGBO(100, 39, 49, .9),
    900: Color.fromRGBO(100, 39, 49, 1),
  };

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    ordersStream.fetchData();
    productsStream.fetchData();

    precacheImage(AssetImage('lib/assets/welcome.jpg'), context);

    return MaterialApp(
      title: 'TradingBOT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: MaterialColor(0xffFF637D, color),
          accentColor: Color(0xffFF637D)),
      home: WelcomeView(),
    );
  }
}
