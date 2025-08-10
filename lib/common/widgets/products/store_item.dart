import 'package:c_ri/common/widgets/products/circle_avatar.dart';
import 'package:c_ri/common/widgets/txt_widgets/product_title_txt.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/models/cart_item_model.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CStoreItemWidget extends StatelessWidget {
  const CStoreItemWidget({
    super.key,
    required this.cartItem,
    required this.includeDate,
  });

  final CCartItemModel cartItem;
  final bool includeDate;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    final invController = Get.put(CInventoryController());

    var invItem = invController.inventoryItems
        .firstWhere((item) => item.productId == cartItem.productId);

    return Row(
      children: [
        CCircleAvatar(
          avatarInitial: cartItem.pName[0],
          txtColor: invItem.quantity < 5
              ? Colors.red
              : isDarkTheme
                  ? CColors.rBrown
                  : CColors.white,
          bgColor: isDarkTheme ? CColors.white : CColors.rBrown,
        ),
        SizedBox(
          width: CSizes.spaceBtnInputFields,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- item title, price, and stock count --
              includeDate
                  ? CProductTitleText(
                      title: invItem.lastModified,
                      smallSize: true,
                      txtColor: isDarkTheme ? CColors.white : CColors.rBrown,
                    )
                  : SizedBox(),

              CProductTitleText(
                title:
                    '${cartItem.pName.toUpperCase()} (${cartItem.availableStockQty} stocked)',
                maxLines: 2,
                smallSize: false,
                txtColor: invItem.quantity < 5
                    ? Colors.red
                    : isDarkTheme
                        ? CColors.white
                        : CColors.rBrown,
              ),

              // -- item attributes --
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${cartItem.availableStockQty} stocked ',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    TextSpan(
                      text: 'usp:${invItem.unitSellingPrice} ',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    TextSpan(
                      text: 'code:${invItem.pCode}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
