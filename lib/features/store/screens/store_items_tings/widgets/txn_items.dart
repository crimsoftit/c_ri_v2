import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/divider/c_divider.dart';
import 'package:c_ri/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/personalization/screens/no_data/no_data_screen.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/search_bar_controller.dart';
import 'package:c_ri/features/store/controllers/sync_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/features/store/screens/search/widgets/no_results_screen.dart';
import 'package:c_ri/utils/constants/app_icons.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CTxnItemsListView extends StatelessWidget {
  const CTxnItemsListView({
    super.key,
    required this.space,
  });

  final String space;

  Widget buildSalesDetails(
    BuildContext context,
    String title,
    String subTitle,
    String date,
  ) {
    return CRoundedContainer(
      bgColor: CColors.transparent,
      showBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: CColors.darkGrey,
                  //fontSizeFactor: .8,
                ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: subTitle,
                  style: Theme.of(context).textTheme.labelMedium!.apply(
                        color: CColors.darkGrey,
                        fontSizeFactor: .8,
                      ),
                ),
              ],
            ),
          ),
          CRoundedContainer(
            child: Text(
              date,
              style: Theme.of(context).textTheme.labelSmall!.apply(
                    color: CColors.rBrown,
                    //fontSizeFactor: .8,
                  ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRefundDetails(BuildContext context, String msg) {
    return CRoundedContainer(
      bgColor: CColors.transparent,
      showBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            msg,
            style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: CColors.darkGrey,
                  //fontSizeFactor: .8,
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkoutController = Get.put(CCheckoutController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final invController = Get.put(CInventoryController());
    final searchController = Get.put(CSearchBarController());
    final syncController = Get.put(CSyncController());
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());
    final userCurrency =
        CHelperFunctions.formatCurrency(userController.user.value.currencyCode);

    return SingleChildScrollView(
      child: Obx(
        () {
          var demItems = [];
          switch (space) {
            case 'invoices':
              demItems.assignAll(searchController.showSearchField.value &&
                      searchController.txtSearchField.text != '' &&
                      !txnsController.isLoading.value
                  ? txnsController.foundInvoices
                  : txnsController.invoices);
              break;
            case 'receipts':
              demItems.assignAll(searchController.showSearchField.value &&
                      searchController.txtSearchField.text != '' &&
                      !txnsController.isLoading.value
                  ? txnsController.foundReceipts
                  : txnsController.receipts);
              break;

            case 'sales':
              demItems.assignAll(searchController.showSearchField.value &&
                      searchController.txtSearchField.text != '' &&
                      !txnsController.isLoading.value
                  ? txnsController.foundSales
                  : txnsController.sales);
              break;

            case 'refunds':
              demItems.assignAll(searchController.showSearchField.value &&
                      searchController.txtSearchField.text != '' &&
                      !txnsController.isLoading.value
                  ? txnsController.foundRefunds
                  : txnsController.refunds);
              break;

            default:
              demItems.clear();
              CPopupSnackBar.errorSnackBar(
                title: 'invalid tab space',
              );
          }

          if (searchController.showSearchField.value &&
              !txnsController.isLoading.value &&
              demItems.isEmpty) {
            return const NoSearchResultsScreen();
          }

          if (!searchController.showSearchField.value && demItems.isEmpty) {
            return const Center(
              child: NoDataScreen(
                lottieImage: CImages.noDataLottie,
                txt: 'No data found!',
              ),
            );
          }

          if (invController.isLoading.value ||
              syncController.processingSync.value) {
            return const CVerticalProductShimmer(
              itemCount: 5,
            );
          }

          return Padding(
            padding: const EdgeInsets.only(
              left: 2.0,
              right: 2.0,
            ),
            child: Card(
              color: isDarkTheme
                  ? CColors.rBrown.withValues(alpha: 0.3)
                  : CColors.lightGrey,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  CSizes.borderRadiusLg,
                ),
                child: ExpansionPanelList.radio(
                  animationDuration: const Duration(milliseconds: 400),
                  elevation: 3,
                  expandedHeaderPadding: EdgeInsets.all(
                    2.0,
                  ),
                  expandIconColor: CNetworkManager.instance.hasConnection.value
                      ? CColors.rBrown
                      : CColors.darkGrey,
                  expansionCallback: (panelIndex, isExpanded) {
                    if (isExpanded &&
                        !txnsController.isLoading.value &&
                        space != 'sales' &&
                        space != 'refunds') {
                      txnsController.fetchTxnItems(demItems[panelIndex].txnId);
                      // Perform an action when the panel is expanded
                      if (kDebugMode) {
                        print('Panel at index $panelIndex is now expanded');
                      }
                    } else {
                      // Perform an action when the panel is collapsed
                      if (kDebugMode) {
                        print('Panel at index $panelIndex is now collapsed');
                      }
                    }
                  },
                  materialGapSize: 3.0,
                  children: demItems
                      .map(
                        (item) => ExpansionPanelRadio(
                          backgroundColor: isDarkTheme
                              ? CColors.rBrown.withValues(
                                  alpha: 0.3,
                                )
                              : CColors.lightGrey,
                          value: space == 'sales' || space == 'refunds'
                              ? item.soldItemId
                              : item.txnId,
                          canTapOnHeader: true,
                          headerBuilder: (_, isExpanded) {
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 8.0,
                              ),
                              //selectedColor:  Colors.amber,
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        // space == 'sales' || space == 'refunds'
                                        //     ? item.productName
                                        //     : 'TXN #${item.txnId}',
                                        'TXN #${item.txnId}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .apply(
                                              color: isDarkTheme
                                                  ? CColors.white
                                                  : CColors.rBrown,
                                              fontWeightDelta: 2,
                                            ),
                                      ),
                                      Text(
                                        'txn Amt: $userCurrency.${item.totalAmount}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .apply(
                                              color: isDarkTheme
                                                  ? CColors.softGrey
                                                  : CColors.rBrown,
                                              fontWeightDelta: 1,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const SizedBox(
                                        height: CSizes.spaceBtnInputFields / 4,
                                      ),
                                      space == 'receipts' || space == 'invoices'
                                          ? Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              //mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'sold to:',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .apply(
                                                        color: isDarkTheme
                                                            ? CColors.darkGrey
                                                            : CColors.rBrown,
                                                        //fontStyle: FontStyle.italic,
                                                      ),
                                                ),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'name: ${item.customerName.isEmpty ? 'N/A' : item.customerName}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium!
                                                          .apply(
                                                            color: isDarkTheme
                                                                ? CColors
                                                                    .darkGrey
                                                                : CColors
                                                                    .rBrown,
                                                            //fontStyle: FontStyle.italic,
                                                          ),
                                                    ),
                                                    Text(
                                                      'contacts: ${item.customerContacts.isEmpty ? "N/A" : item.customerContacts}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium!
                                                          .apply(
                                                            color: isDarkTheme
                                                                ? CColors
                                                                    .darkGrey
                                                                : CColors
                                                                    .rBrown,
                                                            //fontStyle: FontStyle.italic,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : buildSalesDetails(
                                              context,
                                              '${item.productName.toUpperCase()}',
                                              '${item.quantity} sold; ${item.qtyRefunded} refunded @: $userCurrency.${item.unitSellingPrice} #${item.productId}',
                                              '${item.lastModified.replaceAll(' @', '')}'),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                          body: Padding(
                            padding: const EdgeInsets.only(
                              bottom: 4.0,
                              left: 16.0,
                              right: 8.0,
                            ),
                            child: Column(
                              children: [
                                CDivider(
                                  color: isDarkTheme
                                      ? CColors.softGrey
                                      : CColors.rBrown,
                                  startIndent: 0,
                                ),
                                space == 'receipts' || space == 'invoices'
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'item(s):',
                                              //'${userController.user.value.currencyCode}.$totalAmount',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium!
                                                  .apply(
                                                    color: isDarkTheme
                                                        ? CColors.softGrey
                                                        : CColors.rBrown,
                                                    fontWeightDelta: -1,
                                                  ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: ListView.separated(
                                              itemBuilder: (context, index) {
                                                return Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${txnsController.transactionItems[index].productName.toUpperCase()} (${txnsController.transactionItems[index].quantity} item(s) @ $userCurrency.${txnsController.transactionItems[index].unitSellingPrice})',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium!
                                                          .apply(
                                                            color: isDarkTheme
                                                                ? CColors
                                                                    .softGrey
                                                                : CColors
                                                                    .rBrown,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                  ],
                                                );
                                              },
                                              itemCount: txnsController
                                                  .transactionItems.length,
                                              physics: ClampingScrollPhysics(),
                                              separatorBuilder: (_, __) {
                                                return SizedBox(
                                                  height:
                                                      CSizes.spaceBtnItems / 4,
                                                );
                                              },
                                              scrollDirection: Axis.vertical,
                                              shrinkWrap: true,
                                            ),
                                          ),
                                        ],
                                      )
                                    : space == 'refunds'
                                        ? buildRefundDetails(
                                            context,
                                            item.refundReason,
                                          )
                                        : SizedBox.shrink(),
                                if (space == 'invoices' || space == 'sales')
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: SizedBox(
                                      width: space == 'invoices'
                                          ? CHelperFunctions.screenWidth() *
                                              0.45
                                          : CHelperFunctions.screenWidth() *
                                              0.30,
                                      child: TextButton.icon(
                                        onPressed: () {
                                          switch (space) {
                                            case 'invoices':
                                              if (txnsController
                                                  .transactionItems
                                                  .isNotEmpty) {
                                                checkoutController
                                                    .confirmInvoicePaymentDialog(
                                                        item.txnId);
                                              }
                                              break;
                                            case 'sales':
                                              txnsController
                                                  .refundItemActionModal(
                                                      context, item);
                                              break;
                                            default:
                                          }
                                        },
                                        icon: Icon(
                                          space == 'invoices'
                                              ? Iconsax.empty_wallet_tick
                                              : CAppIcons.refundIcon,
                                          color: CColors.white,
                                        ),
                                        label: Text(
                                          space == 'invoices'
                                              ? 'complete txn'
                                              : 'refund',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .apply(
                                                color: CColors.white,
                                                fontSizeFactor: 1.2,
                                              ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: space == 'sales'
                                              ? Colors.redAccent
                                              : CNetworkManager.instance
                                                      .hasConnection.value
                                                  ? CColors.rBrown
                                                  : CColors.black,
                                          foregroundColor: CColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ), // Set the desired radius here
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
