import 'package:c_ri/common/widgets/appbar/app_bar.dart';
import 'package:c_ri/common/widgets/products/cart/positioned_cart_counter_widget.dart';
import 'package:c_ri/common/widgets/search_bar/animated_search_bar.dart';
import 'package:c_ri/common/widgets/tab_views/store_items_tabs.dart';
import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/search_bar_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/features/store/screens/store_items_tings/checkout/widgets/checkout_scan_fab.dart';
import 'package:c_ri/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CStoreItemsScreen extends StatelessWidget {
  const CStoreItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutController = Get.put(CCheckoutController());
    final invController = Get.put(CInventoryController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final txnsController = Get.put(CTxnsController());

    txnsController.fetchTxns();
    AddUpdateItemDialog dialog = AddUpdateItemDialog();

    invController.fetchUserInventoryItems();

    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final searchController = Get.put(CSearchBarController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
        body: SingleChildScrollView(
          child: Obx(
            () {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(
                      left: 10.0,
                      top: 10.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CAppBar(
                          leadingWidget: searchController.showSearchField.value
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 10.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Iconsax.menu,
                                        size: 30.0,
                                        color: CColors.rBrown,
                                      ),
                                      Expanded(
                                        child: searchController
                                                .showSearchField.value
                                            ? CAnimatedSearchBar(
                                                hintTxt:
                                                    'inventory, transactions',
                                                boxColor: searchController
                                                        .showSearchField.value
                                                    ? CColors.white
                                                    : Colors.transparent,
                                                controller: searchController
                                                    .txtSearchField,
                                              )
                                            : Container(),
                                      ),
                                      // Container(
                                      //   width: 30.0,
                                      //   height: 30.0,
                                      //   decoration: BoxDecoration(
                                      //     borderRadius:
                                      //         BorderRadius.circular(8.0),
                                      //     color: Colors.grey[500],
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                          horizontalPadding: 1.0,
                          showBackArrow: false,
                          backIconColor:
                              isDarkTheme ? CColors.white : CColors.rBrown,
                          title: CAnimatedSearchBar(
                            hintTxt: 'inventory, transactions',
                            boxColor: searchController.showSearchField.value
                                ? CColors.white
                                : Colors.transparent,
                            controller: searchController.txtSearchField,
                          ),
                          backIconAction: () {
                            // Navigator.pop(context, true);
                          },
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Text(
                            'Store',
                            style:
                                Theme.of(context).textTheme.labelLarge!.apply(
                                      color: CColors.rBrown,
                                      fontSizeFactor: 2.5,
                                      fontWeightDelta: -5,
                                    ),
                          ),
                        ),
                        SizedBox(
                          height: 1.0,
                        ),
                        Column(
                          children: [
                            SizedBox(
                              child: Align(
                                //alignment: Alignment.topLeft,
                                child: const CStoreItemsTabs(
                                  tab1Title: 'inventory',
                                  tab2Title: 'sales',
                                  tab3Title: 'refunds',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        /// -- floating action button to scan item for sale --
        floatingActionButton: Obx(
          () {
            final cartController = Get.put(CCartController());
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                cartController.countOfCartItems.value >= 1
                    ? Stack(
                        alignment: Alignment.centerRight,
                        children: [
                          FloatingActionButton(
                            onPressed: () {
                              checkoutController.handleNavToCheckout();
                            },
                            backgroundColor: isConnectedToInternet
                                ? Colors.brown
                                : CColors.black,
                            foregroundColor: Colors.white,
                            heroTag: 'checkout',
                            child: const Icon(
                              Iconsax.wallet_check,
                            ),
                          ),
                          CPositionedCartCounterWidget(
                            counterBgColor: CColors.white,
                            counterTxtColor: CColors.rBrown,
                            rightPosition: 10.0,
                            topPosition: 8.0,
                          ),
                        ],
                      )
                    : SizedBox(),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 8,
                ),
                FloatingActionButton(
                  elevation: 0,
                  onPressed: () {
                    //invController.runInvScanner();
                    showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (BuildContext context) => dialog.buildDialog(
                        context,
                        CInventoryModel('', '', '', '', '', 0, 0, 0, 0, 0.0,
                            0.0, 0.0, 0, '', '', '', '', 0, ''),
                        true,
                      ),
                    );
                  },
                  // backgroundColor:
                  //     isConnectedToInternet ? Colors.brown : CColors.black,
                  backgroundColor: CColors.transparent,
                  foregroundColor: isDarkTheme ? CColors.white : CColors.rBrown,
                  heroTag: 'add',
                  child: Icon(
                    // Iconsax.scan_barcode,
                    Iconsax.add,
                  ),
                ),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 8,
                ),
                CCheckoutScanFAB(),
              ],
            );
          },
        ),
      ),
    );
  }
}
