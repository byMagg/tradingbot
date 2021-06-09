import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class Wallet extends Comparable {
  String id;
  String currency;
  String name;
  double amount;
  double value;
  double priceUSD;
  Color color;

  Wallet(String id, String currency, String name, double amount, double value,
      double priceUSD) {
    this.id = id;
    this.currency = currency;
    this.name = name;
    this.amount = amount;
    this.value = value;
    this.priceUSD = priceUSD;
  }

  @override
  int compareTo(other) {
    if (this.value == other.value) return 0;
    return (this.value > other.value) ? -1 : 1;
  }

  getImagePalette() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
      AssetImage(
          'lib/assets/currencies/color/${this.currency.toLowerCase()}.png'),
    );
    this.color = paletteGenerator.dominantColor.color;
  }
}
