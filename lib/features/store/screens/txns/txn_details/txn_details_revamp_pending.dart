import 'package:c_ri/common/widgets/appbar/app_bar.dart';
import 'package:c_ri/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:c_ri/common/widgets/list_tiles/menu_tile.dart';
import 'package:c_ri/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CTxnDetailsScreen extends StatefulWidget {
  const CTxnDetailsScreen({super.key});

  @override
  State<CTxnDetailsScreen> createState() => _CTxnDetailsScreenState();
}

class _CTxnDetailsScreenState extends State<CTxnDetailsScreen> {
  var txnId = Get.arguments;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final salesController = Get.put(CTxnsController());

    //salesList = .toList();

    var txnDetail = salesController.sales.firstWhere(
      (element) => element.txnId.toString() == txnId.toString(),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // -- header --
            CPrimaryHeaderContainer(
              child: Column(
                children: [
                  // app bar
                  CAppBar(
                    title: Text(
                      'transaction details ${txnDetail.txnId}',
                      style: Theme.of(context).textTheme.headlineSmall!.apply(
                            color: CColors.white,
                          ),
                    ),
                    backIconAction: () {
                      Navigator.pop(context, true);
                      //Get.back();
                    },
                    showBackArrow: true,
                    backIconColor: CColors.white,
                    showSubTitle: true,
                    horizontalPadding: 5.0,
                  ),

                  // product profile card
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.brown[300],
                      child: Text(
                        (txnDetail.productName[0].toUpperCase()).toString(),
                        style: Theme.of(context).textTheme.labelLarge!.apply(
                              color: CColors.white,
                            ),
                      ),
                    ),
                    title: Text(
                      txnDetail.productName,
                      style: Theme.of(context).textTheme.labelMedium!.apply(
                            color: CColors.grey,
                          ),
                    ),
                    subtitle: Text(
                      txnDetail.lastModified,
                      style: Theme.of(context).textTheme.headlineSmall!.apply(
                            color: CColors.white,
                            fontSizeFactor: 0.6,
                          ),
                    ),
                    trailing: IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Iconsax.notification,
                        color: CColors.white,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: CSizes.spaceBtnSections / 2,
                  ),
                ],
              ),
            ),

            /// -- body --
            Padding(
              padding: const EdgeInsets.all(
                CSizes.defaultSpace / 3,
              ),
              child: Column(
                children: [
                  const CSectionHeading(
                    showActionBtn: false,
                    title: 'details',
                    btnTitle: '',
                    editFontSize: false,
                  ),
                  CMenuTile(
                    icon: Iconsax.user,
                    title: txnDetail.userName,
                    subTitle: 'served by',
                    onTap: () {},
                  ),
                  CMenuTile(
                    icon: Iconsax.hashtag5,
                    title: txnDetail.productId.toString(),
                    subTitle: 'product/item id',
                    onTap: () {},
                  ),
                  CMenuTile(
                    icon: Iconsax.barcode,
                    title: txnDetail.productCode,
                    subTitle: 'sku/code',
                    onTap: () {},
                  ),
                  CMenuTile(
                    icon: Iconsax.shopping_cart,
                    title: '${txnDetail.quantity}',
                    subTitle: 'Qty/units sold',
                    onTap: () {},
                  ),
                  CMenuTile(
                    icon: Iconsax.card_pos,
                    title: 'Ksh. ${txnDetail.unitSellingPrice}',
                    subTitle: 'unit selling price',
                    onTap: () {},
                  ),
                  CMenuTile(
                    icon: Iconsax.calendar,
                    title: 'comming soon',
                    subTitle: 'last modified',
                    onTap: () {},
                  ),
                  CMenuTile(
                    icon: Iconsax.card_tick,
                    title: 'coming soon',
                    subTitle: 'total sales',
                    onTap: () {},
                  ),
                  CMenuTile(
                    icon: Iconsax.notification,
                    title: 'notifications',
                    subTitle: 'customize notification messages',
                    onTap: () {},
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
