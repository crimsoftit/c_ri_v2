import 'package:c_ri/common/widgets/icon_buttons/circular_icon_btn.dart';
import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CAddToCartBottomNavBar extends StatelessWidget {
  const CAddToCartBottomNavBar({
    super.key,
    required this.inventoryItem,
    this.addIconBtnColor,
    this.addIconTxtColor,
    this.minusIconBtnColor,
    this.minusIconTxtColor,
    this.add2CartBtnBorderColor,
    this.fromCheckoutScreen = false,
  });

  final CInventoryModel inventoryItem;
  final Color? addIconBtnColor,
      addIconTxtColor,
      minusIconBtnColor,
      minusIconTxtColor,
      add2CartBtnBorderColor;
  final bool fromCheckoutScreen;

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CCartController());
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    //final txnsController = Get.put(CTxnsController());

    cartController.initializeItemCountInCart(inventoryItem);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: CSizes.defaultSpace,
        vertical: CSizes.defaultSpace / 2,
      ),
      decoration: BoxDecoration(
        color:
            isDarkTheme ? CColors.rBrown.withValues(alpha: 0.4) : CColors.light,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(CSizes.cardRadiusLg),
          topRight: Radius.circular(CSizes.cardRadiusLg),
        ),
      ),
      child: Obx(
        () {
          // if (txnsController.isLoading.value ||
          //     invController.isLoading.value ||
          //     invController.syncIsLoading.value ||
          //     cartController.cartItemsLoading.value) {
          //   return const CVerticalProductShimmer(
          //     itemCount: 3,
          //   );
          //   //return const DefaultLoaderScreen();
          // }
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CCircularIconBtn(
                    icon: Iconsax.minus,
                    iconBorderRadius: 100,
                    // bgColor: addIconBtnColor ??
                    //     (CNetworkManager.instance.hasConnection.value
                    //         ? CColors.rBrown
                    //         : CColors.black),
                    bgColor: minusIconBtnColor ??
                        (CNetworkManager.instance.hasConnection.value
                            ? CColors.rBrown.withValues(alpha: 0.5)
                            : CColors.black.withValues(alpha: 0.5)),
                    width: 40.0,
                    height: 40.0,
                    color: minusIconBtnColor ?? CColors.white,
                    onPressed: () => cartController.itemQtyInCart.value < 1
                        ? null
                        : cartController.itemQtyInCart.value -= 1,
                  ),
                  //const CFavoriteIcon(),
                  const SizedBox(
                    width: CSizes.spaceBtnItems,
                  ),
                  Text(
                    cartController.itemQtyInCart.value.toString(),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),

                  const SizedBox(
                    width: CSizes.spaceBtnItems,
                  ),

                  CCircularIconBtn(
                    iconBorderRadius: 100,
                    bgColor: addIconBtnColor ??
                        (CNetworkManager.instance.hasConnection.value
                            ? CColors.rBrown
                            : CColors.black),
                    icon: Iconsax.add,
                    color: addIconTxtColor ?? CColors.white,
                    width: 40.0,
                    height: 40.0,
                    onPressed: () {
                      if (cartController.itemQtyInCart.value <
                          inventoryItem.quantity) {
                        cartController.itemQtyInCart.value += 1;
                      } else {
                        CPopupSnackBar.warningSnackBar(
                            title:
                                'only ${inventoryItem.quantity} of ${inventoryItem.name} are stocked',
                            message:
                                'you can only add up to ${inventoryItem.quantity} ${inventoryItem.name} items to the cart');
                      }
                    },
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: cartController.itemQtyInCart.value < 1
                    ? null
                    : () {
                        invController.fetchUserInventoryItems();
                        cartController.fetchCartItems();
                        cartController.addToCart(inventoryItem);
                        cartController.fetchCartItems();
                        if (fromCheckoutScreen) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(
                    CSizes.md,
                  ),
                  backgroundColor: CNetworkManager.instance.hasConnection.value
                      ? CColors.rBrown
                      : CColors.black,
                  side: BorderSide(
                    color: add2CartBtnBorderColor ?? CColors.rBrown,
                  ),
                ),
                label: Text(
                  'add to cart'.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium?.apply(
                        color: CColors.white,
                      ),
                ),
                icon: Icon(
                  Iconsax.shopping_cart,
                  color: CColors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
