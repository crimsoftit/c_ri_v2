import 'package:c_ri/common/widgets/loaders/animated_loader.dart';
import 'package:c_ri/common/widgets/products/cart/add_remove_btns.dart';
import 'package:c_ri/common/widgets/products/store_item.dart';
import 'package:c_ri/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:c_ri/common/widgets/txt_widgets/product_price_txt.dart';
import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/nav_menu.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CCartItems extends StatelessWidget {
  const CCartItems({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CCartController());
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final navController = Get.put(CNavMenuController());
    final scrollController = ScrollController();

    final txnsController = Get.put(CTxnsController());

    //cartController.fetchCartItems();
    return Obx(
      () {
        if (txnsController.isLoading.value ||
            invController.isLoading.value ||
            invController.syncIsLoading.value ||
            cartController.cartItemsLoading.value) {
          return const CVerticalProductShimmer(
            itemCount: 3,
          );
        }

        /// -- empty data widget --
        final noDataWidget = CAnimatedLoaderWidget(
          showActionBtn: true,
          text: 'whoops! cart is EMPTY!',
          actionBtnText: 'let\'s fill it',
          animation: CImages.noDataLottie,
          onActionBtnPressed: () {
            navController.selectedIndex.value = 1;
            Get.to(() => const NavMenu());
          },
        );
        if (cartController.cartItems.isEmpty &&
            !cartController.cartItemsLoading.value) {
          Get.put(CCheckoutController());
          cartController.fetchCartItems().then(
            (_) {
              if (cartController.cartItems.isEmpty &&
                  !cartController.cartItemsLoading.value) {
                return noDataWidget;
              }
            },
          );
        }
        return Scrollbar(
          thumbVisibility: true,
          controller: scrollController,
          child: ListView.separated(
            shrinkWrap: true,
            controller: scrollController,
            itemCount: cartController.cartItems.length,
            separatorBuilder: (_, __) {
              return SizedBox(
                height: CSizes.spaceBtnSections / 4,
              );
            },
            itemBuilder: (_, index) {
              cartController.qtyFieldControllers.add(TextEditingController(
                  text: cartController.cartItems[index].quantity.toString()));

              return Column(
                children: [
                  CStoreItemWidget(
                    includeDate: true,
                    cartItem: cartController.cartItems[index],
                  ),
                  SizedBox(
                    height: CSizes.spaceBtnItems / 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // -- some extra space --
                          SizedBox(
                            width: 45.0,
                          ),
                          // -- buttons to increment, decrement qty --
                          CItemQtyWithAddRemoveBtns(
                            includeAddToCartActionBtn: false,
                            // button to decrement item qty in the cart
                            removeItemBtnAction: () {
                              if (cartController
                                      .qtyFieldControllers[index].text !=
                                  '') {
                                invController.fetchUserInventoryItems();
                                cartController.fetchCartItems();
                                var invItem = invController.inventoryItems
                                    .firstWhere((item) =>
                                        item.productId.toString() ==
                                        cartController
                                            .cartItems[index].productId
                                            .toString()
                                            .toLowerCase());
                                final thisCartItem = cartController
                                    .convertInvToCartItem(invItem, 1);
                                cartController.removeSingleItemFromCart(
                                    thisCartItem, true);
                                cartController.fetchCartItems();

                                cartController.qtyFieldControllers[index].text =
                                    cartController.cartItems[index].quantity
                                        .toString();
                              }
                            },
                            qtyField: SizedBox(
                              width: 40.0,
                              child: TextFormField(
                                controller:
                                    cartController.qtyFieldControllers[index],
                                //initialValue: qtyFieldInitialValue,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                  disabledBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  hintText: 'qty',
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: false,
                                  signed: false,
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: TextStyle(
                                  color: CColors.rBrown,
                                ),

                                onChanged: (value) {
                                  invController.fetchUserInventoryItems();
                                  cartController.fetchCartItems();
                                  if (cartController
                                          .qtyFieldControllers[index].text !=
                                      '') {
                                    var invItem = invController.inventoryItems
                                        .firstWhere((item) =>
                                            item.productId.toString() ==
                                            cartController
                                                .cartItems[index].productId
                                                .toString()
                                                .toLowerCase());

                                    final thisCartItem =
                                        cartController.convertInvToCartItem(
                                            invItem, int.parse(value));

                                    cartController.addSingleItemToCart(
                                        thisCartItem, true, value);
                                  }
                                },
                              ),
                            ),

                            // button to increment item qty in the cart
                            addItemBtnAction: () {
                              if (cartController
                                      .qtyFieldControllers[index].text !=
                                  '') {
                                invController.fetchUserInventoryItems();
                                cartController.fetchCartItems();
                                var invItem = invController.inventoryItems
                                    .firstWhere((item) =>
                                        item.productId.toString() ==
                                        cartController
                                            .cartItems[index].productId
                                            .toString()
                                            .toLowerCase());
                                final thisCartItem = cartController
                                    .convertInvToCartItem(invItem, 1);
                                cartController.addSingleItemToCart(
                                    thisCartItem, false, null);
                                cartController.fetchCartItems();
                                // cartController.qtyFieldControllers[index].text =
                                //     cartItem.quantity.toString();
                                cartController.qtyFieldControllers[index].text =
                                    cartController.cartItems[index].quantity
                                        .toString();
                              }
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 8.0,
                        ),
                        child: CProductPriceTxt(
                          price: (cartController.cartItems[index].price *
                                  cartController.cartItems[index].quantity)
                              .toStringAsFixed(2),
                          isLarge: true,
                          txtColor:
                              isDarkTheme ? CColors.white : CColors.rBrown,
                        ),
                      ),
                      // SizedBox(
                      //   width: 10.0,
                      // ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
