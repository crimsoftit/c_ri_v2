import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CTxnItemsListView extends StatelessWidget {
  const CTxnItemsListView({
    super.key,
    required this.space,
  });

  final String space;

  @override
  Widget build(BuildContext context) {
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());
    final currency =
        CHelperFunctions.formatCurrency(userController.user.value.currencyCode);

    return Obx(
      () {
        if (!txnsController.isLoading.value &&
            txnsController.receipts.isEmpty) {
          txnsController.fetchTxns();
        }

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
        return SizedBox(
          height: CHelperFunctions.screenHeight() * 0.72,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: itemsCount,
            itemBuilder: (context, index) {
              var customerContacts = '';
              var customerName = '';
              var itemQty = 0;

              var txnId = 0;
              var totalAmount = 0.0;
              var usp = 0.0;

              switch (space) {
                case 'receipts':
                  customerContacts =
                      txnsController.receipts[index].customerContacts;
                  customerName = txnsController.receipts[index].customerName;
                  itemQty = txnsController.receipts[index].quantity;
                  txnId = txnsController.receipts[index].txnId;
                  usp = txnsController.receipts[index].unitSellingPrice;
                  //totalAmount = itemQty * usp;
                  break;
                case 'invoices':
                  customerContacts =
                      txnsController.invoices[index].customerContacts;
                  customerName = txnsController.invoices[index].customerName;
                  itemQty = txnsController.invoices[index].quantity;
                  txnId = txnsController.invoices[index].txnId;
                  usp = txnsController.invoices[index].unitSellingPrice;

                  break;
                default:
                  itemQty = 0;
                  txnId = 0;
                  totalAmount = 0.0;
                  usp = 0.0;
                  totalAmount = 0.0;
              }
              totalAmount = itemQty * usp;
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
                        title: Row(
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
                                    ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${userController.user.value.currencyCode}.$totalAmount',
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
                              txnsController.fetchTxnItems(txnId);
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
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: txnsController.receiptItems.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${txnsController.receiptItems[index].productName.toUpperCase()} (${txnsController.receiptItems[index].quantity} item(s) @ $currency.${(txnsController.receiptItems[index].quantity * txnsController.receiptItems[index].unitSellingPrice)})',
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
                                ),
                              ),
                            ],
                          ),
                          // Divider(
                          //   // color: isDarkTheme
                          //   //     ? CColors.grey
                          //   //    : CColors.rBrown,
                          //   color: CColors.grey,
                          // ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customerName != '' || customerContacts != '')
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        'sold to:',
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
                                      child: Text(
                                        '$customerName $customerContacts',
                                      ),
                                    ),
                                  ],
                                ),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: Text(
                                      'complete txn',
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
