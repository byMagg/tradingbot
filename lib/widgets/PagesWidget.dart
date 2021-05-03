import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tradingbot/widgets/BarChartWidget.dart';
import 'package:tradingbot/widgets/LineChartWidget.dart';

class PagesWidget extends StatelessWidget {
  Widget page(Widget widget) {
    return Container(
      child: Padding(
        padding: EdgeInsets.only(bottom: 35, left: 12, right: 12),
        child: Column(children: [Expanded(child: widget)]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = PageController();
    final expandedHeight = MediaQuery.of(context).size.height * 0.24;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final appBarHeight = 50;
    return Container(
      height: MediaQuery.of(context).size.height -
          expandedHeight -
          statusBarHeight -
          appBarHeight,
      alignment: Alignment.center,
      child: Stack(
        children: [
          PageView(
            controller: controller,
            children: <Widget>[
              page(LineChartWidget()),
              page(BarChartWidget()),
              page(LineChartWidget()),
              page(BarChartWidget()),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: SmoothPageIndicator(
                controller: controller,
                count: 4,
                effect: ExpandingDotsEffect(
                    dotHeight: 5,
                    dotWidth: 15,
                    expansionFactor: 3,
                    activeDotColor: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
