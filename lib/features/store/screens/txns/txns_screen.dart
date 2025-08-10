import 'package:c_ri/common/widgets/appbar/app_bar.dart';
import 'package:c_ri/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:c_ri/common/widgets/products/cart/positioned_cart_counter_widget.dart';
import 'package:c_ri/common/widgets/search_bar/animated_search_bar.dart';
import 'package:c_ri/common/widgets/shimmers/shimmer_effects.dart';
import 'package:c_ri/common/widgets/tab_views/store_items_tabs.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/personalization/screens/no_data/no_data_screen.dart';
import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/features/store/controllers/search_bar_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CTxnsScreen extends StatelessWidget {
  const CTxnsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CCartController());
    final checkoutController = Get.put(CCheckoutController());
    final invController = Get.put(CInventoryController());

    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final searchController = Get.put(CSearchBarController());
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());

    Get.put(CInventoryController());
    txnsController.fetchTxns();

    final currency =
        CHelperFunctions.formatCurrency(userController.user.value.currencyCode);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        /// -- body --
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              CPrimaryHeaderContainer(
                child: Column(
                  children: [
                    /// -- app bar --
                    Obx(
                      () {
                        return CAppBar(
                          leadingWidget: searchController.showSearchField.value
                              ? null
                              : Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'transactions',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .apply(
                                              color: CColors.white,
                                            ),
                                      ),
                                      const SizedBox(
                                        width: CSizes.spaceBtnSections,
                                      ),

                                      /// -- scan item for sale --
                                      IconButton(
                                        onPressed: () {
                                          invController
                                              .fetchUserInventoryItems();
                                          txnsController.scanItemForSale();
                                        },
                                        icon: const Icon(
                                          Iconsax.scan,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: CSizes.spaceBtnSections / 4,
                                      ),

                                      /// -- track unsynced txns --
                                      // txnsController.isLoading.value ||
                                      //         invController.isLoading.value
                                      txnsController.isLoading.value ||
                                              txnsController
                                                  .txnsSyncIsLoading.value
                                          ? const CShimmerEffect(
                                              width: 40.0,
                                              height: 40.0,
                                              radius: 40.0,
                                            )
                                          : txnsController.unsyncedTxnAppends
                                                      .isEmpty &&
                                                  txnsController
                                                      .unsyncedTxnUpdates
                                                      .isEmpty
                                              ? const Icon(
                                                  Iconsax.cloud_add,
                                                )
                                              : IconButton(
                                                  onPressed: () async {
                                                    // -- check internet connectivity --
                                                    final internetIsConnected =
                                                        await CNetworkManager
                                                            .instance
                                                            .isConnected();
                                                    if (internetIsConnected) {
                                                      await txnsController
                                                          .addSalesDataToCloud();
                                                    } else {
                                                      CPopupSnackBar
                                                          .customToast(
                                                        message:
                                                            'internet connection required for cloud sync!',
                                                        forInternetConnectivityStatus:
                                                            true,
                                                      );
                                                    }
                                                  },
                                                  icon: const Icon(
                                                    Iconsax.cloud_change,
                                                  ),
                                                ),
                                    ],
                                  ),
                                ),
                          horizontalPadding: 1.0,
                          showBackArrow: false,
                          backIconColor:
                              isDarkTheme ? CColors.white : CColors.rBrown,
                          title: CAnimatedSearchBar(
                            hintTxt: 'transactions',
                            boxColor: searchController.showSearchField.value
                                ? CColors.white
                                : Colors.transparent,
                            controller: searchController.txtSearchField,
                          ),
                          backIconAction: () {},
                        );
                      },
                    ),

                    const SizedBox(
                      height: CSizes.spaceBtnSections,
                    ),
                  ],
                ),
              ),

              /// -- tab bars for inventory & transactions lists --
              Obx(
                () {
                  if (searchController.showSearchField.value) {
                    //invController.fetchInventoryItems();
                    return const CStoreItemsTabs(
                      tab1Title: 'inventory',
                      tab2Title: 'transactions',
                      tab3Title: 'refunds',
                    );
                  }

                  // run loader --
                  // if (txnsController.isLoading.value ||
                  //     invController.isLoading.value ||
                  //     txnsController.txnsSyncIsLoading.value) {
                  //   return const CVerticalProductShimmer(
                  //     itemCount: 7,
                  //   );
                  // }

                  // -- no data widget --
                  if (invController.inventoryItems.isEmpty ||
                      txnsController.txns.isEmpty &&
                          (!txnsController.isLoading.value ||
                              !invController.isLoading.value)) {
                    return const Center(
                      child: NoDataScreen(
                        lottieImage: CImages.noDataLottie,
                        txt: 'no data found!',
                      ),
                    );
                  }

                  return SizedBox(
                    height: CHelperFunctions.screenHeight() * 0.72,
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: txnsController.txns.length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              CSizes.borderRadiusSm,
                            ),
                            side: BorderSide(
                              color: CColors.rBrown,
                              width: 0.7,
                            ),
                          ),
                          color: CColors.lightGrey,
                          elevation: 0.3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              CSizes.borderRadiusSm,
                            ),
                            child: SingleChildScrollView(
                              //physics: BouncingScrollPhysics(),
                              physics: ClampingScrollPhysics(),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  childrenPadding: EdgeInsets.all(8.0).copyWith(
                                    top: 0,
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Text(
                                          'reciept #: ${txnsController.txns[index].txnId}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .apply(
                                                color: CColors.rBrown,
                                              ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          '${userController.user.value.currencyCode}.${txnsController.txns[index].totalAmount}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .apply(
                                                color: CColors.rBrown,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onExpansionChanged: (isExpanded) {
                                    txnsController.receiptItems.clear();
                                    if (isExpanded) {
                                      if (txnsController.receiptItems.isEmpty) {
                                        txnsController.fetchTxnItems(
                                            txnsController.txns[index].txnId);
                                      }
                                    }
                                    // if (isExpanded) {
                                    //   if (txnsController.receiptItems.isEmpty) {
                                    //     txnsController.fetchTxnItems(
                                    //         txnsController.txns[index].txnId);
                                    //   }
                                    // } else {
                                    //   txnsController.receiptItems.clear();
                                    // }
                                  },
                                  children: [
                                    Text(
                                      'receipt items',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .apply(
                                            color: CColors.rBrown,
                                          ),
                                    ),
                                    Divider(
                                      // color: isDarkTheme
                                      //     ? CColors.grey
                                      //    : CColors.rBrown,
                                      color: CColors.grey,
                                    ),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount:
                                          txnsController.receiptItems.length,
                                      itemBuilder: (context, index) {
                                        return ExpansionTile(
                                          title: Text(
                                            '${txnsController.receiptItems[index].productName} ${txnsController.receiptItems[index].quantity} items @ $currency.${(txnsController.receiptItems[index].quantity * txnsController.receiptItems[index].unitSellingPrice)} usp:${txnsController.receiptItems[index].unitSellingPrice}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .apply(
                                                  color: CColors.rBrown,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                          onExpansionChanged: (isExpanded) {
                                            // txnsController.receiptItems.clear();
                                            // if (isExpanded) {
                                            //   txnsController.fetchTxnItems(
                                            //       txnsController
                                            //           .txns[index].txnId);
                                            // }
                                          },
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    Get.toNamed(
                                                      '/sales/sold_item_details',
                                                      arguments: txnsController
                                                          .receiptItems[index]
                                                          .soldItemId,
                                                    );
                                                  },
                                                  icon: const Icon(
                                                    Iconsax.information,
                                                    size: CSizes.iconSm,
                                                    color: CColors.rBrown,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: CSizes
                                                      .spaceBtnInputFields,
                                                ),
                                                TextButton.icon(
                                                  icon: const Icon(
                                                    Iconsax.undo,
                                                    size: CSizes.iconSm,
                                                    color: CColors.rBrown,
                                                  ),
                                                  label: Text(
                                                    'refund',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium!
                                                        .apply(
                                                            color: Colors.red),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: Size(
                                                      30,
                                                      20,
                                                    ),
                                                    alignment:
                                                        Alignment.centerLeft,
                                                  ),
                                                  onPressed: () {
                                                    txnsController
                                                        .refundItemActionModal(
                                                            context,
                                                            txnsController
                                                                    .receiptItems[
                                                                index]);
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        /// -- floating action button to scan item for sale --
        floatingActionButton: Obx(
          () {
            final isConnectedToInternet =
                CNetworkManager.instance.hasConnection.value;
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
                                ? CColors.rBrown
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
                  backgroundColor:
                      isConnectedToInternet ? Colors.brown : CColors.black,
                  foregroundColor: Colors.white,
                  heroTag: 'transact',
                  onPressed: () {
                    invController.fetchUserInventoryItems();
                    checkoutController.scanItemForCheckout();
                  },
                  child: const Icon(
                    Iconsax.scan,
                    size: CSizes.iconMd,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
