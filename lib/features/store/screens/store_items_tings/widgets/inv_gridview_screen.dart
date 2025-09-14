import 'package:c_ri/common/widgets/loaders/animated_loader.dart';
import 'package:c_ri/common/widgets/products/product_cards/p_card_vertical.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/search_bar_controller.dart';
import 'package:c_ri/features/store/controllers/sync_controller.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/features/store/screens/search/widgets/no_results_screen.dart';
import 'package:c_ri/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CInvGridviewScreen extends StatelessWidget {
  const CInvGridviewScreen({
    super.key,
    this.mainAxisExtent = 165.0,
  });

  final double? mainAxisExtent;

  @override
  Widget build(BuildContext context) {
    final invController = Get.put(CInventoryController());
    final searchController = Get.put(CSearchBarController());
    final syncController = Get.put(CSyncController());
    final userController = Get.put(CUserController());

    AddUpdateItemDialog dialog = AddUpdateItemDialog();

    return Obx(
      () {
        //invController.onInit();

        /// -- empty data widget --
        final noDataWidget = SizedBox(
          height: 200.0,
          child: CAnimatedLoaderWidget(
            actionBtnWidth: 180.0,
            actionBtnText: 'let\'s fill it!',
            animation: CImages.noDataLottie,
            lottieAssetWidth: CHelperFunctions.screenWidth() * 0.42,
            onActionBtnPressed: () {
              showDialog(
                context: context,
                useRootNavigator: false,
                builder: (BuildContext context) => dialog.buildDialog(
                  context,
                  CInventoryModel('', '', '', '', '', 0, 0, 0, 0, 0.0, 0.0, 0.0,
                      0, '', '', '', '', 0, ''),
                  true,
                ),
              );
            },
            showActionBtn: true,
            text: 'whoops! store is EMPTY!',
          ),
        );

        if (invController.foundInventoryItems.isEmpty &&
            searchController.showSearchField.value &&
            !invController.isLoading.value) {
          return const NoSearchResultsScreen();
        }

        if (invController.inventoryItems.isEmpty) {
          return noDataWidget;
        }

        return ListView(
          padding: const EdgeInsets.only(
            left: 5.0,
            right: 5.0,
          ),
          shrinkWrap: true,
          children: [
            GridView.builder(
              itemCount: searchController.showSearchField.value
                  ? invController.foundInventoryItems.length
                  : invController.inventoryItems.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: CSizes.gridViewSpacing / 12,
                crossAxisSpacing: CSizes.gridViewSpacing / 12,
                mainAxisExtent: mainAxisExtent,
              ),
              itemBuilder: (context, index) {
                var avatarTxt = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].name[0]
                        .toUpperCase()
                    : invController.inventoryItems[index].name[0].toUpperCase();

                var bp = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].buyingPrice
                    : invController.inventoryItems[index].buyingPrice;

                var dateAdded = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].dateAdded
                    : invController.inventoryItems[index].dateAdded;

                var isFavorite = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].markedAsFavorite
                    : invController.inventoryItems[index].markedAsFavorite;

                var isSynced = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].isSynced
                    : invController.inventoryItems[index].isSynced;

                var lastModified = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].lastModified
                    : invController.inventoryItems[index].lastModified;

                var lowStockNotifierLimit = searchController
                            .showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController
                        .foundInventoryItems[index].lowStockNotifierLimit
                    : invController.inventoryItems[index].lowStockNotifierLimit;

                var productId = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].productId
                    : invController.inventoryItems[index].productId;

                var pName = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].name
                    : invController.inventoryItems[index].name;

                var qtyAvailable = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].quantity
                    : invController.inventoryItems[index].quantity;

                var qtyRefunded = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].qtyRefunded
                    : invController.inventoryItems[index].qtyRefunded;

                var qtySold = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].qtySold
                    : invController.inventoryItems[index].qtySold;

                var sku = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].pCode
                    : invController.inventoryItems[index].pCode;

                var supplierContacts = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].supplierContacts
                    : invController.inventoryItems[index].supplierContacts;

                var supplierName = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].supplierName
                    : invController.inventoryItems[index].supplierName;

                var syncAction = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].syncAction
                    : invController.inventoryItems[index].syncAction;

                var unitBp = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].unitBp
                    : invController.inventoryItems[index].unitBp;

                var usp = searchController.showSearchField.value &&
                        invController.foundInventoryItems.isNotEmpty
                    ? invController.foundInventoryItems[index].unitSellingPrice
                    : invController.inventoryItems[index].unitSellingPrice;

                return CProductCardVertical(
                  bp: bp.toString(),
                  containerHeight: 176.0,
                  deleteAction: syncController.processingSync.value
                      ? null
                      : () {
                          CInventoryModel itemId;
                          if (invController.foundInventoryItems.isNotEmpty &&
                              searchController.showSearchField.value) {
                            itemId = invController.foundInventoryItems[index];
                          } else {
                            itemId = invController.inventoryItems[index];
                          }
                          invController.deleteInventoryWarningPopup(itemId);
                        },
                  isSynced: isSynced.toString(),
                  itemAvatar: avatarTxt,
                  itemName: pName,
                  lastModified: lastModified,
                  lowStockNotifierLimit: lowStockNotifierLimit,
                  onAvatarIconTap: syncController.processingSync.value
                      ? null
                      : () {
                          invController.itemExists.value = true;
                          showDialog(
                            context: context,
                            useRootNavigator: true,
                            builder: (BuildContext context) {
                              invController.currentItemId.value = productId!;
                              return dialog.buildDialog(
                                context,
                                CInventoryModel.withID(
                                  invController.currentItemId.value,
                                  userController.user.value.id,
                                  userController.user.value.email,
                                  userController.user.value.fullName,
                                  sku,
                                  pName,
                                  isFavorite,
                                  qtyAvailable,
                                  qtySold,
                                  qtyRefunded,
                                  bp,
                                  unitBp,
                                  usp,
                                  lowStockNotifierLimit,
                                  supplierName,
                                  supplierContacts,
                                  dateAdded,
                                  lastModified,
                                  isSynced,
                                  syncAction,
                                ),
                                false,
                              );
                            },
                          );
                        },
                  onDoubleTapAction: () {
                    Get.toNamed(
                      '/inventory/item_details/',
                      arguments: invController.inventoryItems[index].productId,
                    );
                  },
                  onTapAction: () {
                    CPopupSnackBar.customToast(
                      message: 'double tap on item to see details!!',
                      forInternetConnectivityStatus: false,
                    );
                  },
                  pCode: sku,
                  pId: productId!,
                  qtyAvailable: qtyAvailable.toString(),
                  qtyRefunded: qtyRefunded.toString(),
                  qtySold: qtySold.toString(),
                  syncAction: syncAction,
                  usp: usp.toString(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
