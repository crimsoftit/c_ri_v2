import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CAddToCartBtn extends StatelessWidget {
  const CAddToCartBtn({
    super.key,
    required this.pId,
  });

  final int pId;

  @override
  Widget build(BuildContext context) {
    final invController = Get.put(CInventoryController());

    return Obx(
      () {
        final cartController = CCartController.instance;
        final pQtyInCart = cartController.getItemQtyInCart(pId);
        return InkWell(
          onTap: () {
            cartController.fetchCartItems();
            var invItem = invController.inventoryItems.firstWhere((item) =>
                item.productId.toString() == pId.toString().toLowerCase());
            final cartItem = cartController.convertInvToCartItem(invItem, 1);
            cartController.addSingleItemToCart(cartItem, false, null);
          },
          child: Container(
            decoration: BoxDecoration(
              color: pQtyInCart > 0
                  ? Colors.orange
                  : CNetworkManager.instance.hasConnection.value
                      ? CColors.rBrown
                      : CColors.darkerGrey,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(CSizes.cardRadiusMd - 4),
                bottomRight: Radius.circular(CSizes.pImgRadius - 4),
              ),
            ),
            child: SizedBox(
              width: CSizes.iconLg,
              height: CSizes.iconLg,
              child: Center(
                child: pQtyInCart > 0
                    ? Text(
                        pQtyInCart.toString(),
                        style: Theme.of(context).textTheme.bodyLarge!.apply(
                              color: CColors.white,
                            ),
                      )
                    : const Icon(
                        Iconsax.add,
                        color: CColors.white,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
