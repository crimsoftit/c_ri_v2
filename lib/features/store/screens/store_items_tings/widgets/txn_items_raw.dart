import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CTxnItemsListViewRaw extends StatelessWidget {
  const CTxnItemsListViewRaw({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());
    final currency =
        CHelperFunctions.formatCurrency(userController.user.value.currencyCode);

    return Obx(
      () {
        if (!txnsController.isLoading.value &&
            txnsController.receiptItems.isEmpty) {
          txnsController.fetchTxns();
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
                            style:
                                Theme.of(context).textTheme.labelMedium!.apply(
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
                            itemCount: txnsController.receiptItems.length,
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
                                                .receiptItems[index].soldItemId,
                                          );
                                        },
                                        icon: const Icon(
                                          Iconsax.information,
                                          size: CSizes.iconSm,
                                          color: CColors.rBrown,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: CSizes.spaceBtnInputFields,
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
                                              .apply(color: Colors.red),
                                        ),
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: Size(
                                            30,
                                            20,
                                          ),
                                          alignment: Alignment.centerLeft,
                                        ),
                                        onPressed: () {
                                          txnsController.refundItemActionModal(
                                              context,
                                              txnsController
                                                  .receiptItems[index]);
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
    );
  }
}
