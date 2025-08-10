import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class CRoundedContainer extends StatelessWidget {
  const CRoundedContainer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = CSizes.cardRadiusLg,
    this.child,
    this.showBorder = false,
    this.borderColor = CColors.borderPrimary,
    this.bgColor = CColors.white,
    this.boxShadow,
    this.padding,
    this.margin,
  });

  final double? width;
  final double? height;
  final double borderRadius;
  final Widget? child;
  final bool showBorder;
  final Color borderColor;
  final Color bgColor;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        // boxShadow: boxShadow ?? [CShadowStyle.verticalProductShadow],
        boxShadow: boxShadow,
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: showBorder ? Border.all(color: borderColor) : null,
      ),
      child: child,
    );
  }
}
