import 'package:c_ri/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class CDivider extends StatelessWidget {
  const CDivider({
    super.key,
    this.endIndent = 20.0,
    this.startIndent = 20.0,
  });

  final double? endIndent, startIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: CColors.rBrown,
      endIndent: endIndent,
      indent: startIndent,
      thickness: 0.2,
    );
  }
}
