import 'package:flutter/material.dart';
import 'package:finance_tracker/utils/constants.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool useScaffoldBackground;

  const LoadingIndicator({
    this.size = 24,
    this.strokeWidth = 3,
    this.color,
    this.useScaffoldBackground = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicator = Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
        ),
      ),
    );

    return useScaffoldBackground
        ? Scaffold(backgroundColor: AppColors.background, body: indicator)
        : indicator;
  }
}
