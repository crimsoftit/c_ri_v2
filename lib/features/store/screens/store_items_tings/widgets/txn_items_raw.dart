import 'package:c_ri/common/widgets/divider/c_divider.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CTxnItemsListViewRaw extends StatelessWidget {
  const CTxnItemsListViewRaw({
    super.key,
    required this.space,
  });

  final String space;

  @override
  Widget build(BuildContext context) {
    final checkoutController = Get.put(CCheckoutController());
    //final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());
    final currency =
        CHelperFunctions.formatCurrency(userController.user.value.currencyCode);

    return Obx(
      () {
        var itemsCount = 0;
        switch (space) {
          case 'receipts':
            itemsCount = txnsController.receipts.length;
            break;
          case 'invoices':
            itemsCount = txnsController.invoices.length;
          default:
            itemsCount = 0;
            CPopupSnackBar.errorSnackBar(
              title: 'invalid tab space',
            );
        }
        if (!txnsController.isLoading.value &&
            txnsController.receipts.isEmpty) {
          txnsController.fetchTxns();
        }
        // if (!txnsController.isLoading.value && itemsCount == 0) {
        //   txnsController.fetchTxns();
        // }
        return SizedBox(
          height: CHelperFunctions.screenHeight() * 0.72,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: itemsCount,
            itemBuilder: (context, index) {
              var customerContacts = '';
              var customerName = '';
              //var itemQty = 0;

              var txnId = 0;
              var totalAmount = 0.0;
              //var usp = 0.0;

              switch (space) {
                case 'receipts':
                  customerContacts =
                      txnsController.receipts[index].customerContacts;
                  customerName = txnsController.receipts[index].customerName;
                  //itemQty = txnsController.receipts[index].quantity;
                  txnId = txnsController.receipts[index].txnId;
                  //usp = txnsController.receipts[index].unitSellingPrice;
                  totalAmount = txnsController.receipts[index].totalAmount;

                  break;
                case 'invoices':
                  customerContacts =
                      txnsController.invoices[index].customerContacts;
                  customerName = txnsController.invoices[index].customerName;
                  //itemQty = txnsController.invoices[index].quantity;
                  txnId = txnsController.invoices[index].txnId;
                  //usp = txnsController.invoices[index].unitSellingPrice;
                  totalAmount = txnsController.invoices[index].totalAmount;
                  break;
                default:
                  //itemQty = 0;
                  txnId = 0;
                  totalAmount = 0.0;
                //usp = 0.0;
              }
              return Card(
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(
                //     CSizes.borderRadiusSm,
                //   ),
                //   side: BorderSide(
                //     color: CColors.rBrown,
                //     width: 0.7,
                //   ),
                // ),
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
                          bottom: 0,
                          left: 14.0,
                          top: 0,
                        ),
                        // tilePadding: const EdgeInsets.all(
                        //   10.0,
                        // ),
                        initiallyExpanded: false,
                        showTrailingIcon: space == 'invoices' ? false : true,
                        title: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    'TXN #$txnId',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .apply(
                                          color: CColors.rBrown,
                                          fontWeightDelta: 2,
                                        ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '$currency.$totalAmount',
                                    //'${userController.user.value.currencyCode}.$totalAmount',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .apply(
                                          color: CColors.rBrown,
                                          fontWeightDelta: 2,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: CSizes.spaceBtnInputFields / 3,
                            ),
                            if (customerName != '' || customerContacts != '')
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      'sold to:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium!
                                          .apply(
                                            color: CColors.rBrown,
                                            //fontStyle: FontStyle.italic,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'name: $customerName',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .apply(
                                                color: CColors.darkerGrey,
                                                //fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                        Text(
                                          'contacts: ${customerContacts.isEmpty ? "N/A" : customerContacts}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .apply(
                                                color: CColors.darkerGrey,
                                                //fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        onExpansionChanged: (isExpanded) {
                          txnsController.transactionItems.clear();
                          if (isExpanded) {
                            if (txnsController.transactionItems.isEmpty) {
                              txnsController.fetchTxnItems(txnId);
                            }
                          }
                        },
                        children: [
                          CDivider(
                            startIndent: 0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'item(s):',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .apply(
                                        color: CColors.darkerGrey,
                                        //fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: ListView.separated(
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${txnsController.transactionItems[index].productName.toUpperCase()} (${txnsController.transactionItems[index].quantity} item(s) @ $currency.${txnsController.transactionItems[index].unitSellingPrice})',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelMedium!
                                              .apply(
                                                color: CColors.rBrown,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ],
                                    );
                                  },
                                  itemCount:
                                      txnsController.transactionItems.length,
                                  physics: ClampingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  separatorBuilder: (_, __) {
                                    return SizedBox(
                                      height: CSizes.spaceBtnItems / 4,
                                    );
                                  },
                                  shrinkWrap: true,
                                ),
                                // ListView.builder(
                                //   shrinkWrap: true,
                                //   physics: ClampingScrollPhysics(),
                                //   scrollDirection: Axis.vertical,
                                //   itemCount: txnsController.receiptItems.length,
                                //   itemBuilder: (context, index) {
                                //     return Column(
                                //       crossAxisAlignment:
                                //           CrossAxisAlignment.start,
                                //       children: [
                                //         Text(
                                //           '${txnsController.receiptItems[index].productName.toUpperCase()} (${txnsController.receiptItems[index].quantity} item(s) @ $currency.${(txnsController.receiptItems[index].quantity * txnsController.receiptItems[index].unitSellingPrice)})',
                                //           style: Theme.of(context)
                                //               .textTheme
                                //               .labelMedium!
                                //               .apply(
                                //                 color: CColors.rBrown,
                                //               ),
                                //           overflow: TextOverflow.ellipsis,
                                //           maxLines: 2,
                                //         ),
                                //       ],
                                //     );
                                //   },
                                // ),
                              ),
                            ],
                          ),
                          // SizedBox(
                          //   height: CSizes.spaceBtnInputFields / 4,
                          // ),

                          if (space == 'invoices')
                            Container(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                width: CHelperFunctions.screenWidth() * 0.45,
                                child: TextButton.icon(
                                  onPressed: () {
                                    if (txnsController
                                        .transactionItems.isNotEmpty) {
                                      checkoutController
                                          .confirmInvoicePaymentDialog(txnId);
                                    }
                                  },
                                  icon: Icon(
                                    Iconsax.empty_wallet_tick,
                                    color: CColors.white,
                                  ),
                                  label: Text(
                                    'complete txn',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!
                                        .apply(
                                          color: CColors.white,
                                          fontSizeFactor: 1.2,
                                        ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: CNetworkManager
                                            .instance.hasConnection.value
                                        ? CColors.rBrown
                                        : CColors.black,
                                    foregroundColor: CColors
                                        .white, // foreground (text) color
                                    // background color
                                  ),
                                ),
                              ),
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
    );
  }
}
