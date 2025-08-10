import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CPositionedCartCounterWidget extends StatelessWidget {
  const CPositionedCartCounterWidget({
    super.key,
    required this.counterBgColor,
    required this.counterTxtColor,
    this.rightPosition,
    this.topPosition,
  });

  final Color? counterBgColor;
  final Color? counterTxtColor;

  final double? rightPosition, topPosition;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Positioned(
      right: rightPosition ?? 0,
      top: topPosition ?? 5.0,
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: counterBgColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Obx(() {
            final cartController = Get.put(CCartController());
            return Text(
              cartController.countOfCartItems.value.toString(),
              style: Theme.of(context).textTheme.labelSmall!.apply(
                    color: counterTxtColor ??
                        (isDarkTheme ? CColors.rBrown : CColors.white),
                    fontSizeFactor: 1.0,
                  ),
            );
          }),
        ),
      ),
    );
  }
}
