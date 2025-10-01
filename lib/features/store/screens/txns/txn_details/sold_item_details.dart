import 'package:c_ri/common/widgets/divider/c_divider.dart';
import 'package:c_ri/common/widgets/list_tiles/menu_tile.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CSoldItemDetails extends StatelessWidget {
  const CSoldItemDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());
    final userCurrency =
        CHelperFunctions.formatCurrency(userController.user.value.currencyCode);

    var itemId = Get.arguments;

    Future.delayed(
      Duration.zero,
      () {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            txnsController.fetchSoldItems();
          },
        );
      },
    );

    return Container(
      color: isDarkTheme ? CColors.transparent : CColors.white,
      child: Obx(
        () {
          var saleItem = txnsController.sales
              .firstWhere((item) => item.soldItemId == itemId);
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              iconTheme: IconThemeData(
                color: isDarkTheme ? CColors.white : CColors.rBrown,
              ),
              title: Text(
                'TXN #${saleItem.txnId}',
                style: Theme.of(context).textTheme.labelMedium!.apply(
                      color: isDarkTheme ? CColors.grey : CColors.rBrown,
                    ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Iconsax.notification,
                    color: isDarkTheme ? CColors.white : CColors.rBrown,
                  ),
                )
              ],
            ),
            backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown[300],
                      child: Text(
                        saleItem.productName[0].toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge!.apply(
                              color: CColors.white,
                            ),
                      ),
                    ),
                    title: Text(
                      saleItem.productName.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium!.apply(
                            color: isDarkTheme ? CColors.grey : CColors.rBrown,
                          ),
                    ),
                    subtitle: Text(
                      saleItem.lastModified,
                      style: Theme.of(context).textTheme.headlineSmall!.apply(
                            color: CColors.darkGrey,
                            fontSizeFactor: 0.6,
                          ),
                    ),
                    // trailing: IconButton(
                    //   onPressed: () {},
                    //   icon: Icon(
                    //     Iconsax.notification,
                    //     color: isDarkTheme ? CColors.white : CColors.rBrown,
                    //   ),
                    // ),
                  ),
                  CDivider(),
                  Padding(
                    padding: const EdgeInsets.all(
                      CSizes.defaultSpace / 3,
                    ),
                    child: Column(
                      children: [
                        CMenuTile(
                          icon: Iconsax.user,
                          title: saleItem.userName.split(" ").elementAt(0),
                          // subTitle: invItem.userEmail,
                          subTitle: 'served by',
                          onTap: () {},
                        ),
                        CMenuTile(
                          icon: Iconsax.hashtag5,
                          title: saleItem.productId.toString(),
                          subTitle: 'product/item id',
                          onTap: () {},
                        ),
                        CMenuTile(
                          icon: Iconsax.barcode,
                          title: saleItem.productCode,
                          subTitle: 'sku/code',
                          onTap: () {},
                        ),
                        CMenuTile(
                          icon: Iconsax.bitcoin_card,
                          title:
                              '$userCurrency.${(saleItem.quantity * saleItem.unitSellingPrice).toStringAsFixed(2)} (${(saleItem.quantity)} units)',
                          subTitle: 'total amount',
                          onTap: () {},
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            // bottomNavigationBar: SizedBox(
            //   width: CHelperFunctions.screenWidth() * .55,
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       var soldItem = txnsController.sales
            //           .firstWhere((item) => item.soldItemId == itemId);
            //       txnsController.refundItemActionModal(context, soldItem);
            //     },
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.all(
            //         CSizes.md,
            //       ),
            //       backgroundColor: CNetworkManager.instance.hasConnection.value
            //           ? CColors.rBrown
            //           : CColors.black,
            //       side: BorderSide(
            //         color: CColors.rBrown,
            //       ),
            //     ),
            //     label: Text(
            //       'refund'.toUpperCase(),
            //       style: Theme.of(context).textTheme.labelMedium?.apply(
            //             color: CColors.white,
            //           ),
            //     ),
            //     icon: Icon(
            //       CAppIcons.refundIcon,
            //       color: CColors.white,
            //     ),
            //   ),
            // ),
          );
        },
      ),
    );
  }
}
