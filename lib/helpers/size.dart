import 'package:flutter/material.dart';

class HelperSize {
  static const minScreenWidth = 200;
  static const minScreenHeight = 415;

  static bool hasScreenSafeArea(BuildContext context) {
    final EdgeInsets viewInsets = MediaQuery.of(context).viewInsets;
    final EdgeInsets viewPadding = MediaQuery.of(context).viewPadding;

    // ? SafeArea is effective if any of these is non-zero
    return viewInsets.top > 0 ||
        viewInsets.bottom > 0 ||
        viewInsets.left > 0 ||
        viewInsets.right > 0 ||
        viewPadding.top > 0 ||
        viewPadding.bottom > 0 ||
        viewPadding.left > 0 ||
        viewPadding.right > 0;
  }

  static bool isLessThanMinimumScreen(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return screenSize.width < minScreenWidth ||
        screenSize.height < minScreenHeight;
  }

  static bool isNearMinimumScreen(BuildContext context) {
    const nearMinWidth = minScreenWidth + 100;
    const nearMinHeight = minScreenHeight + 100;
    final Size screenSize = MediaQuery.of(context).size;

    return screenSize.width <= nearMinWidth ||
        screenSize.height <= nearMinHeight;
  }
}
