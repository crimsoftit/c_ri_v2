import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/icon_buttons/circular_icon_btn.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CItemQtyWithAddRemoveBtns extends StatelessWidget {
  const CItemQtyWithAddRemoveBtns({
    super.key,
    this.addItemBtnAction,
    this.addToCartBtnAction,
    this.add2CartActionBtnTxt,
    this.add2CartBtnTxtColor,
    this.add2CartIconColor,
    this.bgColor,
    this.btnsLeftPadding = CSizes.sm,
    this.btnsRightPadding = CSizes.sm,
    this.displayBorder = true,
    this.horizontalSpacing,
    required this.qtyField,
    this.useSmallIcons = false,
    this.iconWidth = 32.0,
    this.iconHeight = 32.0,
    this.qty = 1,
    this.qtyWidget,
    this.removeItemBtnAction,
    this.useTxtFieldForQty = true,
    required this.includeAddToCartActionBtn,
  });

  final Widget? qtyField, qtyWidget;
  final int? qty;
  final VoidCallback? addItemBtnAction, removeItemBtnAction, addToCartBtnAction;
  final double? iconWidth,
      iconHeight,
      btnsRightPadding,
      btnsLeftPadding,
      horizontalSpacing;
  final Color? bgColor, add2CartBtnTxtColor, add2CartIconColor;
  final bool useTxtFieldForQty,
      useSmallIcons,
      includeAddToCartActionBtn,
      displayBorder;
  final String? add2CartActionBtnTxt;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return CRoundedContainer(
      showBorder: displayBorder,
      bgColor: bgColor.isBlank ?? isDarkTheme ? CColors.dark : CColors.white,
      padding: EdgeInsets.only(
        top: 0,
        bottom: 0,
        right: btnsRightPadding ?? CSizes.sm,
        left: btnsLeftPadding ?? CSizes.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CCircularIconBtn(
            icon: Iconsax.minus,
            width: iconWidth,
            height: iconHeight,
            iconBorderRadius: useSmallIcons ? 60 : 100,
            iconSize: CSizes.md,
            color: isDarkTheme ? CColors.white : CColors.rBrown,
            bgColor: isDarkTheme ? CColors.darkerGrey : CColors.light,
            onPressed: removeItemBtnAction,
          ),
          SizedBox(
            width: horizontalSpacing ?? CSizes.spaceBtnItems,
          ),

          // -- field to set quantity --
          useTxtFieldForQty ? qtyField! : qtyWidget!,
          // Text(
          //   '2',
          // ),
          SizedBox(
            width: useTxtFieldForQty
                ? 0
                : horizontalSpacing ?? CSizes.spaceBtnItems,
          ),
          CCircularIconBtn(
            icon: Iconsax.add,
            iconBorderRadius: useSmallIcons ? 60 : 100,
            width: iconWidth,
            height: iconHeight,
            iconSize: CSizes.md,
            color: CColors.white,
            bgColor: CColors.rBrown,
            onPressed: addItemBtnAction,
          ),
          SizedBox(
            width: includeAddToCartActionBtn
                ? horizontalSpacing ?? CSizes.spaceBtnItems
                : 0,
          ),
          includeAddToCartActionBtn
              ? TextButton.icon(
                  onPressed: addToCartBtnAction,
                  label: Text(
                    add2CartActionBtnTxt!,
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          color: add2CartBtnTxtColor,
                        ),
                  ),
                  icon: Icon(
                    Iconsax.shopping_cart,
                    color: add2CartIconColor ?? CColors.rBrown,
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
