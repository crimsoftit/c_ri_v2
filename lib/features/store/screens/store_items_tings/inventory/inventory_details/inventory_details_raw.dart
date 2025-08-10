import 'package:c_ri/common/widgets/appbar/app_bar.dart';
import 'package:c_ri/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:c_ri/common/widgets/list_tiles/menu_tile.dart';
import 'package:c_ri/common/widgets/products/cart/positioned_cart_counter_widget.dart';
import 'package:c_ri/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/features/store/screens/store_items_tings/inventory/inventory_details/widgets/add_to_cart_bottom_nav_bar.dart';
import 'package:c_ri/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CInventoryDetailsScreen extends StatefulWidget {
  const CInventoryDetailsScreen({
    super.key,
  });

  @override
  State<CInventoryDetailsScreen> createState() =>
      _CInventoryDetailsScreenState();
}

class _CInventoryDetailsScreenState extends State<CInventoryDetailsScreen> {
  var itemId = Get.arguments;
  var invController = Get.put(CInventoryController());
  final cartController = Get.put(CCartController());
  final userController = Get.put(CUserController());

  final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;

  // ignore: prefer_typing_uninitialized_variables
  var invItem;

  @override
  void initState() {
    super.initState();
  }

  var invList = [];

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(CUserController());

    final currency =
        CHelperFunctions.formatCurrency(userController.user.value.currencyCode);

    AddUpdateItemDialog dialog = AddUpdateItemDialog();

    invList = invController.inventoryItems.toList();

    invItem = invList.firstWhere((item) => item.productId == itemId);

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
                      'product details (#$itemId)',
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
                  ),

                  // product profile card
                  Obx(() {
                    invController = Get.put(CInventoryController());

                    invItem = invController.inventoryItems
                        .firstWhere((item) => item.productId == itemId);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.brown[300],
                        child: Text(
                          invItem.name[0].toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                                color: CColors.white,
                              ),
                        ),
                      ),
                      title: Text(
                        invItem.name,
                        style: Theme.of(context).textTheme.labelMedium!.apply(
                              color: CColors.grey,
                            ),
                      ),
                      subtitle: Text(
                        invItem.lastModified,
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
                    );
                  }),
                  const SizedBox(
                    height: CSizes.spaceBtnSections / 2,
                  ),
                ],
              ),
            ),

            // -- body --
            Obx(
              () {
                invController = Get.put(CInventoryController());

                invItem = invController.inventoryItems
                    .firstWhere((item) => item.productId == itemId);

                return Padding(
                  padding: const EdgeInsets.all(CSizes.defaultSpace / 3),
                  child: Column(
                    children: [
                      // --- account settings
                      const CSectionHeading(
                        showActionBtn: false,
                        title: 'details',
                        btnTitle: '',
                        editFontSize: false,
                      ),

                      CMenuTile(
                        icon: Iconsax.user,
                        title: invItem.userName,
                        subTitle: invItem.userEmail,
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.hashtag5,
                        title: invItem.productId.toString(),
                        subTitle: 'product/item id',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.barcode,
                        title: invItem.pCode,
                        subTitle: 'sku/code',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.barcode,
                        title: invItem.dateAdded,
                        subTitle: 'date added',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.shopping_cart,
                        title: '${(invItem.quantity)}',
                        subTitle: 'Qty/units available',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.shopping_cart,
                        title: '${(invItem.qtyRefunded)}',
                        subTitle: 'Qty/units refunded',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.bitcoin_card,
                        title:
                            '$currency.${(invItem.qtySold * invItem.unitSellingPrice).toStringAsFixed(2)} (${(invItem.qtySold)} units)',
                        subTitle: 'total sales',
                        onTap: () {},
                      ),

                      CMenuTile(
                        icon: Iconsax.bitcoin_card,
                        //title: '',
                        title: '$currency.${(invItem.buyingPrice)}',
                        subTitle: 'buying price',
                        onTap: () {
                          //Get.to(() => const UserAddressesScreen());
                        },
                      ),

                      CMenuTile(
                        icon: Iconsax.card_pos,
                        //title: '',
                        title: '$currency. ${(invItem.unitSellingPrice)}',
                        subTitle: 'unit selling price',
                        onTap: () {
                          //Get.to(() => const OrdersScreen());
                        },
                      ),

                      CMenuTile(
                        icon: Iconsax.card_pos,
                        //title: '',
                        title: '$currency.${(invItem.unitSellingPrice)}',
                        subTitle: '~ unit buying price',
                        onTap: () {
                          //Get.to(() => const OrdersScreen());
                        },
                      ),

                      CMenuTile(
                        icon: Iconsax.calendar,
                        title: invItem.lastModified,
                        subTitle: 'last modified',
                        onTap: () {},
                      ),
                      CMenuTile(
                        icon: Iconsax.card_tick,
                        title: invItem.qtySold.toString(),
                        subTitle: 'total units sold',
                        onTap: () {},
                      ),
                      CMenuTile(
                        icon: Iconsax.user,
                        title: invItem.supplierName,
                        subTitle: 'supplier name',
                        onTap: () {},
                      ),
                      CMenuTile(
                        icon: Icons.contact_mail,
                        title: invItem.supplierContacts,
                        subTitle: 'supplier contacts',
                        onTap: () {},
                      ),
                      CMenuTile(
                        icon: Iconsax.notification,
                        title: 'notifications',
                        subTitle: 'customize notification messages',
                        onTap: () {},
                      ),

                      const SizedBox(
                        height: CSizes.spaceBtnSections,
                      ),

                      // -- app settings
                      const CSectionHeading(
                        showActionBtn: false,
                        title: 'app settings',
                        btnTitle: '',
                        editFontSize: false,
                      ),
                      const SizedBox(
                        height: CSizes.spaceBtnItems,
                      ),
                      CMenuTile(
                        icon: Iconsax.document_upload,
                        title: 'upload data',
                        subTitle: 'upload data to your cloud firebase',
                        trailing: IconButton(
                          onPressed: () {},
                          icon: const Icon(Iconsax.arrow_right),
                        ),
                        onTap: () {},
                      ),
                      CMenuTile(
                        icon: Iconsax.location,
                        title: 'geolocation',
                        subTitle: 'set recommendation based on location',
                        trailing: Switch(
                          value: true,
                          activeColor: CColors.rBrown,
                          onChanged: (value) {},
                        ),
                      ),
                      CMenuTile(
                        icon: Iconsax.security_user,
                        title: 'safe mode',
                        subTitle:
                            'search result is safe for people of all ages',
                        trailing: Switch(
                          value: false,
                          activeColor: CColors.rBrown,
                          onChanged: (value) {},
                        ),
                      ),

                      const Divider(),
                      const SizedBox(
                        height: CSizes.spaceBtnItems,
                      ),

                      const Center(
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.logout,
                              size: 28.0,
                              color: CColors.primaryBrown,
                            ),
                            SizedBox(
                              width: CSizes.spaceBtnInputFields,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CAddToCartBottomNavBar(
        inventoryItem: invItem,
      ),
      floatingActionButton: Obx(
        () {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              cartController.countOfCartItems.value >= 1
                  ? Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        // FloatingActionButton.extended(
                        //   onPressed: () {
                        //     Get.to(() => const CCheckoutScreen());
                        //   },
                        //   label: const Text('checkout'),
                        //   backgroundColor: Colors.brown,
                        //   foregroundColor: Colors.white,
                        //   icon: const Icon(
                        //     Iconsax.wallet_check,
                        //   ),
                        //   heroTag: 'checkout',
                        // ),
                        FloatingActionButton(
                          onPressed: () {
                            //Get.to(() => const CCheckoutScreen());
                            final checkoutController =
                                Get.put(CCheckoutController());
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
                onPressed: () {
                  invController.itemExists.value = true;

                  setState(() {
                    itemId = invItem.productId;
                  });
                  showDialog(
                    context: context,
                    useRootNavigator: false,
                    builder: (BuildContext context) {
                      invController.currentItemId.value = invItem.productId;

                      return dialog.buildDialog(
                        context,
                        CInventoryModel.withID(
                          itemId,
                          userController.user.value.id,
                          userController.user.value.email,
                          userController.user.value.fullName,
                          invItem.pCode,
                          invItem.name,
                          invItem.markedAsFavorite,
                          invItem.quantity,
                          invItem.qtySold,
                          invItem.qtyRefunded,
                          invItem.buyingPrice,
                          invItem.unitBp,
                          invItem.unitSellingPrice,
                          invItem.lowStockNotifierLimit,
                          invItem.supplierName,
                          invItem.supplierContacts,
                          invItem.dateAdded,
                          invItem.lastModified,
                          invItem.isSynced,
                          invItem.syncAction,
                        ),
                        false,
                      );
                    },
                  );
                  invController.txtId.text = (invItem.productId).toString();
                  setState(() {});
                },
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
                child: const Icon(
                  Iconsax.edit,
                  color: CColors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
