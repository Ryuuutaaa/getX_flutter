import 'package:flutter/material.dart';
import 'package:get/get.dart';

extension PercentSized on double {
  double get hp => (Get.height * (this / 100));
  double get wp => (Get.width * (this / 100));
}

extension ResponsiveText on double {
  double get sp => (Get.width / 100 * (this / 3));
}

extension HexColor on Color {
  /// Mengonversi string warna HEX ke objek Color.
  /// Mendukung format: "#RRGGBB", "RRGGBB", "AARRGGBB", "0xAARRGGBB"
  static Color fromHex(String hexString) {
    hexString =
        hexString.toUpperCase().replaceAll("#", "").replaceAll("0X", "");

    if (hexString.length == 6) {
      hexString = "FF$hexString"; // tambahkan alpha default jika belum ada
    }

    return Color(int.parse(hexString, radix: 16));
  }

  /// Mengubah objek Color menjadi HEX string
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';
}
