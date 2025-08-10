import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/icon_buttons/circular_icon_btn.dart';
import 'package:c_ri/common/widgets/products/cart/add_to_cart_btn.dart';
import 'package:c_ri/common/widgets/products/circle_avatar.dart';
import 'package:c_ri/common/widgets/shimmers/shimmer_effects.dart';
import 'package:c_ri/common/widgets/txt_widgets/product_price_txt.dart';
import 'package:c_ri/common/widgets/txt_widgets/product_title_txt.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/sync_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CProductCardVertical extends StatelessWidget {
  const CProductCardVertical({
    super.key,
    required this.itemName,
    required this.pCode,
    required this.pId,
    this.bp,
    this.lastModified,
    this.deleteAction,
    this.isSynced,
    this.itemAvatar,
    this.lowStockNotifierLimit,
    this.onAvatarIconTap,
    this.onTapAction,
    this.qtyAvailable,
    this.qtyRefunded,
    this.qtySold,
    this.syncAction,
    this.usp,
    required this.containerHeight,
  });

  final double containerHeight;
  final int? lowStockNotifierLimit;
  final int pId;
  final String? bp,
      lastModified,
      isSynced,
      itemAvatar,
      qtyAvailable,
      qtyRefunded,
      qtySold,
      syncAction,
      usp;
  final String itemName, pCode;

  final VoidCallback? onTapAction, deleteAction, onAvatarIconTap;

  @override
  Widget build(BuildContext context) {
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final syncController = Get.put(CSyncController());

    return GestureDetector(
      onDoubleTap: onTapAction,
      child: Container(
        width: 170,
        //height: 200.0,
        padding: EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          boxShadow: [],
          borderRadius: BorderRadius.circular(CSizes.borderRadiusSm * 4.0),
          color: CColors.transparent,
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: CSizes.spaceBtnInputFields / 5,
            ),
            CRoundedContainer(
              bgColor: isDarkTheme
                  ? CColors.rBrown.withValues(alpha: 0.3)
                  : CColors.lightGrey,
              borderRadius: CSizes.pImgRadius - 4,
              //height: 182.0,
              height: containerHeight,
              padding: const EdgeInsets.only(
                left: CSizes.sm / 4,
              ),
              width: CHelperFunctions.screenWidth() * 0.46,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CRoundedContainer(
                    width: CHelperFunctions.screenWidth() * 0.45,
                    height: 52.0,
                    bgColor: const Color.fromRGBO(0, 0, 0, 0),
                    boxShadow: [],
                    child: Obx(
                      () {
                        return Stack(
                          children: [
                            /// -- favorite item tag --
                            Positioned(
                              top: 0,
                              left: 0,
                              child: (invController.isLoading.value ||
                                          syncController
                                              .processingSync.value) &&
                                      invController.inventoryItems.isNotEmpty
                                  ? CShimmerEffect(
                                      width: 30,
                                      height: 30.0,
                                      radius: 30.0,
                                    )
                                  : CCircularIconBtn(
                                      bgColor: isDarkTheme
                                          ? CColors.transparent
                                          : CColors.white,
                                      color: isDarkTheme
                                          ? CColors.white
                                          : CColors.rBrown,
                                      icon: Iconsax.heart_add,
                                      iconSize: CSizes.md,
                                      height: 33.0,
                                      width: 33.0,
                                    ),
                            ),

                            /// -- delete item iconButton --
                            Positioned(
                              top: 0,
                              right: 0,
                              child: (invController.isLoading.value ||
                                          syncController
                                              .processingSync.value) &&
                                      invController.inventoryItems.isNotEmpty
                                  ? CShimmerEffect(
                                      width: 30,
                                      height: 30.0,
                                      radius: 30.0,
                                    )
                                  : CCircularIconBtn(
                                      color: isDarkTheme
                                          ? CColors.white
                                          : Colors.red,
                                      icon: Icons.delete,
                                      iconSize: CSizes.md,
                                      height: 33.0,
                                      width: 33.0,
                                      bgColor: isDarkTheme
                                          ? CColors.transparent
                                          : CColors.white,
                                      onPressed: deleteAction,
                                    ),
                            ),

                            /// -- avatar, date, and(or) edit iconButton --
                            Positioned(
                              top: 2,
                              left: (invController.isLoading.value ||
                                          syncController
                                              .processingSync.value) &&
                                      invController.inventoryItems.isNotEmpty
                                  ? 60.0
                                  : 40.0,
                              child: (invController.isLoading.value ||
                                          syncController
                                              .processingSync.value) &&
                                      invController.inventoryItems.isNotEmpty
                                  ? CShimmerEffect(
                                      width: 40,
                                      height: 40.0,
                                      radius: 40.0,
                                    )
                                  : Center(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          CCircleAvatar(
                                            avatarInitial: itemAvatar!,
                                            // bgColor: int.parse(qtyAvailable!) <
                                            //         lowStockNotifierLimit!
                                            //     ? Colors.red
                                            //     : CColors.rBrown,
                                            bgColor: int.parse(qtyAvailable!) <
                                                    lowStockNotifierLimit!
                                                ? Colors.red
                                                : CColors.transparent,
                                            includeEditBtn: true,
                                            onEdit: onAvatarIconTap,
                                            txtColor: isDarkTheme
                                                ? CColors.white
                                                : CColors.rBrown,
                                          ),
                                          const SizedBox(
                                            height: CSizes.spaceBtnInputFields /
                                                2.0,
                                          ),
                                          Text(
                                            lastModified!,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall!
                                                .apply(
                                                  color: isDarkTheme
                                                      ? CColors.grey
                                                      : CColors.darkGrey,
                                                  fontSizeFactor: 0.9,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 2.0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CProductTitleText(
                          //smallSize: true,
                          title:
                              "${itemName.toUpperCase()} ($qtyAvailable stocked, $qtySold sold)",
                          txtColor:
                              isDarkTheme ? CColors.white : CColors.rBrown,
                          maxLines: 2,
                        ),

                        Text(
                          '($qtyRefunded unit(s) refunded)',
                          style: Theme.of(context).textTheme.labelSmall!.apply(
                                color: isDarkTheme
                                    ? CColors.white
                                    : CColors.darkGrey,
                              ),
                        ),
                        Text(
                          'sku: $pCode',
                          style: Theme.of(context).textTheme.labelSmall!.apply(
                                color: isDarkTheme
                                    ? CColors.white
                                    : CColors.darkGrey,
                              ),
                        ),
                        Visibility(
                          visible: true,
                          child: Text(
                            'isSynced: $isSynced, syncAction: $syncAction',
                            style:
                                Theme.of(context).textTheme.labelSmall!.apply(
                                      color: isDarkTheme
                                          ? CColors.white
                                          : CColors.darkGrey,
                                    ),
                          ),
                        ),
                        CProductPriceTxt(
                          priceCategory: 'bp: ',
                          price: bp!,
                          maxLines: 1,
                          isLarge: true,
                          txtColor:
                              isDarkTheme ? CColors.white : CColors.darkGrey,
                          fSizeFactor: 0.7,
                        ),

                        SizedBox(
                          /// -- TODO:
                          // chora cart item usp * qtyInCart
                          // also catch socketexcption when syncing data
                          width: CHelperFunctions.screenWidth(),
                          height: 35.0,
                          child: Obx(
                            () {
                              return Stack(
                                children: [
                                  Positioned(
                                    bottom: 0,
                                    child: CProductPriceTxt(
                                      // priceCategory: 'price: ',
                                      priceCategory: '@',
                                      price: usp!,
                                      maxLines: 1,
                                      isLarge: true,
                                      txtColor: isDarkTheme
                                          ? CColors.white
                                          : CColors.rBrown,
                                      fSizeFactor: 0.9,
                                    ),
                                  ),

                                  /// -- button to edit inventory item's details --
                                  // Positioned(
                                  //   right: 0,
                                  //   bottom: 30.0,
                                  //   child: CSquareIconBtn(
                                  //     bgColor: CColors.transparent,
                                  //     onBtnTap: onEditBtnTapped,
                                  //   ),
                                  // ),

                                  /// -- add item to cart button --
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: (invController.isLoading.value ||
                                                syncController
                                                    .processingSync.value) &&
                                            invController
                                                .inventoryItems.isNotEmpty
                                        ? CShimmerEffect(
                                            width: 32.0,
                                            height: 32.0,
                                            radius: 8.0,
                                          )
                                        : CAddToCartBtn(
                                            pId: pId,
                                          ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
