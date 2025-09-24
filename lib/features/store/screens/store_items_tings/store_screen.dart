import 'package:c_ri/common/widgets/appbar/app_bar.dart';
import 'package:c_ri/common/widgets/appbar/tab_bar.dart';
import 'package:c_ri/common/widgets/products/cart/positioned_cart_counter_widget.dart';
import 'package:c_ri/common/widgets/search_bar/animated_search_bar.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/search_bar_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/features/store/screens/store_items_tings/widgets/inv_gridview_screen.dart';
import 'package:c_ri/features/store/screens/store_items_tings/widgets/store_screen_header.dart';
import 'package:c_ri/features/store/screens/store_items_tings/widgets/txn_items.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CStoreScreen extends StatelessWidget {
  const CStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final checkoutController = Get.put(CCheckoutController());
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final txnsController = Get.put(CTxnsController());

    final searchController = Get.put(CSearchBarController());

    txnsController.fetchTxns();
    //Get.put(CTxnsController());

    // if (!invController.isLoading.value &&
    //     !syncController.processingSync.value &&
    //     !txnsController.isLoading.value &&
    //     (invController.unSyncedAppends.isEmpty ||
    //         invController.unSyncedUpdates.isEmpty)) {
    //   invController.fetchUserInventoryItems();
    // }

    return DefaultTabController(
      animationDuration: Duration(
        milliseconds: 1500,
      ),
      length: 5,
      child: Obx(
        () {
          return Scaffold(
            backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
            appBar: CAppBar(
              leadingWidget: searchController.showSearchField.value
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(top: 5.0, left: 10.0),
                      child: Row(
                        children: [
                          Icon(
                            Iconsax.menu,
                            size: 25.0,
                            color: CColors.rBrown,
                          ),
                          Expanded(
                            child: searchController.showSearchField.value
                                ? CAnimatedSearchBar(
                                    hintTxt: 'inventory, transactions',
                                    boxColor:
                                        searchController.showSearchField.value
                                            ? CColors.white
                                            : Colors.transparent,
                                    controller: searchController.txtSearchField,
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
              horizontalPadding: 1.0,
              showBackArrow: false,
              backIconColor: isDarkTheme ? CColors.white : CColors.rBrown,
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
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrollable) {
                return [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    pinned: true,
                    floating: false,
                    backgroundColor: CColors.transparent,
                    expandedHeight: 50.0,
                    flexibleSpace: Padding(
                      padding: const EdgeInsets.only(
                        left: 10.0,
                        right: 10.0,
                      ),
                      child: ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          CStoreScreenHeader(
                            title: 'Store',
                          ),
                          SizedBox(
                            height: 1.0,
                          ),
                        ],
                      ),
                    ),

                    /// -- tabs --
                    bottom: const CTabBar(
                      tabs: [
                        Tab(
                          child: Text('inventory'),
                        ),
                        // Tab(
                        //   child: Text('sales_raw'),
                        // ),
                        Tab(
                          child: Text('sales (all)'),
                        ),
                        Tab(
                          child: Text('receipts'),
                        ),
                        Tab(
                          child: Text('invoices'),
                        ),
                        Tab(
                          child: Text('refunds'),
                        ),
                      ],
                    ),
                  ),
                ];
              },
              body: const TabBarView(
                physics: BouncingScrollPhysics(),
                children: [
                  /// -- inventory list items --
                  CInvGridviewScreen(
                    mainAxisExtent: 182.0,
                  ),

                  // -- almost obsolete --
                  // CItemsListView(
                  //   space: 'sales',
                  // ),

                  /// -- transactions list view --
                  CTxnItemsListView(
                    space: 'sales',
                  ),

                  CTxnItemsListView(
                    space: 'receipts',
                  ),

                  CTxnItemsListView(
                    space: 'invoices',
                  ),
                  CTxnItemsListView(
                    space: 'refunds',
                  ),
                  // CItemsListView(
                  //   space: 'refunds',
                  // ),
                ],
              ),
            ),

            /// -- floating action button to scan item for sale --
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    FloatingActionButton.extended(
                      label: Text(
                        'CHECKOUT',
                        style: Theme.of(context).textTheme.labelSmall!.apply(
                              color: CColors.white,
                              fontSizeDelta: 1.2,
                              fontWeightDelta: -1,
                            ),
                      ),
                      onPressed: () {
                        checkoutController.handleNavToCheckout();
                      },
                      backgroundColor: isConnectedToInternet
                          ? CColors.rBrown
                          : CColors.black,
                      foregroundColor: Colors.white,
                      heroTag: 'checkout',
                      icon: const Icon(
                        Iconsax.wallet_check,
                        size: CSizes.iconSm + 4,
                      ),
                    ),
                    CPositionedCartCounterWidget(
                      containerHeight: 14.0,
                      containerWidth: 14.0,
                      counterBgColor: CColors.white,
                      counterTxtColor: CColors.rBrown,
                      rightPosition: 75.0,
                      topPosition: 12.0,
                    ),
                  ],
                ),
              ],
            ),
            // Obx(
            //   () {
            //     final cartController = Get.put(CCartController());
            //     return Column(
            //       mainAxisAlignment: MainAxisAlignment.end,
            //       children: [
            //         cartController.countOfCartItems.value >= 1
            //             ? Stack(
            //                 alignment: Alignment.centerRight,
            //                 children: [
            //                   FloatingActionButton(
            //                     onPressed: () {
            //                       checkoutController.handleNavToCheckout();
            //                     },
            //                     backgroundColor: isConnectedToInternet
            //                         ? Colors.brown
            //                         : CColors.black,
            //                     foregroundColor: Colors.white,
            //                     heroTag: 'checkout',
            //                     child: const Icon(
            //                       Iconsax.wallet_check,
            //                     ),
            //                   ),
            //                   CPositionedCartCounterWidget(
            //                     counterBgColor: CColors.white,
            //                     counterTxtColor: CColors.rBrown,
            //                     rightPosition: 10.0,
            //                     topPosition: 8.0,
            //                   ),
            //                 ],
            //               )
            //             : SizedBox.shrink(),
            //         const SizedBox(
            //           height: CSizes.spaceBtnSections / 8,
            //         ),

            //       ],
            //     );
            //   },
            // ),
          );
        },
      ),
    );
  }
}
