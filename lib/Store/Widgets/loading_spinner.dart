import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class SmallLoadingSpinner extends StatelessWidget {
  final double height;
  final double width;
  final List<Color> colors;

  const SmallLoadingSpinner({
    super.key,
    this.height = 20,
    this.width = 20,
    this.colors = const [ Color(0xFF2c425c)],
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: LoadingIndicator(
        indicatorType: Indicator.lineSpinFadeLoader,
        colors: colors,
        strokeWidth: 2,
      ),
    );
  }
}
