import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/divider/c_divider.dart';
import 'package:c_ri/common/widgets/icon_buttons/circular_icon_btn.dart';
import 'package:c_ri/common/widgets/loaders/animated_loader.dart';
import 'package:c_ri/common/widgets/products/store_item.dart';
import 'package:c_ri/common/widgets/search_bar/animated_typeahead_field.dart';
import 'package:c_ri/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:c_ri/common/widgets/txt_widgets/product_price_txt.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/features/store/controllers/search_bar_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/features/store/screens/store_items_tings/checkout/widgets/billing_amount_section.dart';
import 'package:c_ri/features/store/screens/store_items_tings/checkout/widgets/checkout_scan_fab.dart';
import 'package:c_ri/features/store/screens/store_items_tings/checkout/widgets/payment_methods/payment_method_section.dart';
import 'package:c_ri/nav_menu.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CCheckoutScreen extends StatelessWidget {
  const CCheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CCartController());
    final checkoutController = Get.put(CCheckoutController());
    final invController = Get.put(CInventoryController());
    //final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final navController = Get.put(CNavMenuController());
    final scrollController = ScrollController();
    final searchBarController = Get.put(CSearchBarController());
    final txnsController = Get.put(CTxnsController());
    final userController = Get.put(CUserController());

    final currencySymbol =
        CHelperFunctions.formatCurrency(userController.user.value.currencyCode);

    return Container(
      color: isDarkTheme ? CColors.transparent : CColors.white,
      child: Scaffold(
        /// -- app bar --
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(
            color: CColors.rBrown,
          ),
          leading: IconButton(
            icon: Icon(
              Iconsax.arrow_left,
              size: CSizes.iconMd,
              color: CColors.rBrown,
            ),
            onPressed: () {
              //Get.back();
              Navigator.pop(context);
            },
          ),
          leadingWidth: 20.0,
          title: Padding(
            padding: const EdgeInsets.only(
              top: 1.0,
              left: 0,
            ),
            child: Obx(
              () {
                return searchBarController.showAnimatedTypeAheadField.value
                    ? CAnimatedTypeaheadField(
                        boxColor: CColors.white,
                        searchBarWidth: CHelperFunctions.screenWidth() * .87,
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // IconButton(
                          //   icon: Icon(
                          //     Iconsax.arrow_left,
                          //     size: CSizes.iconMd,
                          //     color: CColors.rBrown,
                          //   ),
                          //   onPressed: () {
                          //     searchBarController
                          //         .showAnimatedTypeAheadField.value = false;
                          //     //Get.back();
                          //     Navigator.pop(context);
                          //   },
                          // ),
                          SizedBox(
                            width: CHelperFunctions.screenWidth() * 0.72,
                          ),
                          CAnimatedTypeaheadField(
                            boxColor: CColors.transparent,
                            searchBarWidth: 30.0,
                          ),
                        ],
                      );
              },
            ),
          ),
          // title: Padding(
          //   // padding: const EdgeInsets.only(top: 10.0, bottom: 8.0, left: 0,),
          //   padding: const EdgeInsets.only(
          //     top: 10.0,
          //     left: 0,
          //   ),
          //   //child: const CTypeAheadSearchField(),
          //   child: Obx(
          //     () {
          //       //final screenWidth = CHelperFunctions.screenWidth();
          //       return searchBarController.showAnimatedTypeAheadField.value
          //           ? CAnimatedTypeaheadField(
          //               boxColor: CColors.white,
          //             )
          //           : Row(
          //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //               children: [
          //                 SizedBox(
          //                   width: CHelperFunctions.screenWidth() * 0.62,
          //                 ),
          //                 CAnimatedTypeaheadField(
          //                   boxColor: CColors.transparent,
          //                 ),
          //               ],
          //             );
          //     },
          //   ),
          // ),
        ),
        backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
        body: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(
              top: CSizes.defaultSpace / 4,
              left: CSizes.defaultSpace / 1.8,
              right: CSizes.defaultSpace / 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'chekout',
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                                color:
                                    CNetworkManager.instance.hasConnection.value
                                        ? CColors.rBrown
                                        : CColors.darkGrey,
                                fontSizeFactor: 2.5,
                                fontWeightDelta: -7,
                              ),
                        ),
                        CCheckoutScanFAB(
                          bgColor: CColors.transparent,
                          elevation: 0, // -- remove shadow --
                          foregroundColor:
                              CNetworkManager.instance.hasConnection.value
                                  ? CColors.rBrown
                                  : CColors.darkGrey,
                        ),
                      ],
                    );
                  },
                ),
                CDivider(),
                Obx(
                  () {
                    /// -- empty data widget --
                    final noDataWidget = CAnimatedLoaderWidget(
                      showActionBtn: true,
                      text: 'whoops! cart is EMPTY!',
                      actionBtnText: 'let\'s fill it',
                      animation: CImages.emptyCartLottie,
                      onActionBtnPressed: () {
                        navController.selectedIndex.value = 1;
                        Get.to(() => const NavMenu());
                      },
                    );

                    if (txnsController.isLoading.value ||
                        invController.isLoading.value ||
                        invController.syncIsLoading.value) {
                      //return const DefaultLoaderScreen();
                      return const CVerticalProductShimmer(
                        itemCount: 7,
                      );
                    }

                    if (cartController.cartItems.isEmpty &&
                        !cartController.cartItemsLoading.value) {
                      cartController.fetchCartItems();
                    }

                    if (cartController.cartItems.isEmpty &&
                        !cartController.cartItemsLoading.value) {
                      return noDataWidget;
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: CSizes.defaultSpace / 4,
                            right: CSizes.defaultSpace / 4,
                          ),
                          child: Column(
                            children: [
                              // -- list of items in the cart --
                              SizedBox(
                                height: cartController.cartItems.length <= 2
                                    ? CHelperFunctions.screenHeight() * 0.30
                                    : CHelperFunctions.screenHeight() * 0.38,
                                child: CRoundedContainer(
                                  padding: EdgeInsets.all(
                                    CSizes.defaultSpace / 12.0,
                                  ),
                                  // bgColor: CColors.rBrown.withValues(
                                  //   alpha: 0.2,
                                  // ),
                                  bgColor: CColors.transparent,
                                  child: Scrollbar(
                                    thumbVisibility: true,
                                    controller: scrollController,
                                    child: ListView.separated(
                                      shrinkWrap: true,
                                      controller: scrollController,
                                      itemCount:
                                          cartController.cartItems.length,
                                      separatorBuilder: (_, __) {
                                        return SizedBox(
                                          height: CSizes.spaceBtnSections / 4,
                                        );
                                      },
                                      itemBuilder: (_, index) {
                                        cartController.qtyFieldControllers.add(
                                          TextEditingController(
                                            text: cartController
                                                .getItemQtyInCart(cartController
                                                    .cartItems[index].productId)
                                                .toString(),
                                          ),
                                        );

                                        return Column(
                                          children: [
                                            CStoreItemWidget(
                                              cartItem: cartController
                                                  .cartItems[index],
                                              includeDate: false,
                                            ),
                                            SizedBox(
                                              height: CSizes.spaceBtnItems / 4,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    // -- some extra space --
                                                    SizedBox(
                                                      width: 45.0,
                                                    ),
                                                    // -- buttons to increment, decrement qty --
                                                    CRoundedContainer(
                                                      showBorder: isDarkTheme
                                                          ? false
                                                          : true,
                                                      // bgColor: bgColor.isBlank ?? isDarkTheme ? CColors.dark : CColors.white,
                                                      bgColor: isDarkTheme
                                                          ? CColors.dark
                                                          : CColors.white,
                                                      padding: EdgeInsets.only(
                                                        top: 0,
                                                        bottom: 0,
                                                        right: CSizes.sm,
                                                        left: CSizes.sm,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          CCircularIconBtn(
                                                            icon: Iconsax.minus,
                                                            width: 32.0,
                                                            height: 32.0,
                                                            iconBorderRadius:
                                                                100,
                                                            iconSize: CSizes.md,
                                                            color: isDarkTheme
                                                                ? CColors.white
                                                                : CColors
                                                                    .rBrown,
                                                            bgColor: isDarkTheme
                                                                ? CColors
                                                                    .darkerGrey
                                                                : CColors.light,
                                                            onPressed: () {
                                                              if (cartController
                                                                      .qtyFieldControllers[
                                                                          index]
                                                                      .text !=
                                                                  '') {
                                                                invController
                                                                    .fetchUserInventoryItems();
                                                                cartController
                                                                    .fetchCartItems();
                                                                var invItem = invController.inventoryItems.firstWhere((item) =>
                                                                    item.productId
                                                                        .toString() ==
                                                                    cartController
                                                                        .cartItems[
                                                                            index]
                                                                        .productId
                                                                        .toString()
                                                                        .toLowerCase());
                                                                final thisCartItem =
                                                                    cartController
                                                                        .convertInvToCartItem(
                                                                            invItem,
                                                                            1);
                                                                cartController
                                                                    .removeSingleItemFromCart(
                                                                        thisCartItem,
                                                                        true);
                                                                cartController
                                                                    .fetchCartItems();

                                                                cartController
                                                                        .qtyFieldControllers[
                                                                            index]
                                                                        .text =
                                                                    cartController
                                                                        .cartItems[
                                                                            index]
                                                                        .quantity
                                                                        .toString();
                                                                if (checkoutController
                                                                        .amtIssuedFieldController
                                                                        .text !=
                                                                    '') {
                                                                  checkoutController
                                                                      .computeCustomerBal(
                                                                    cartController
                                                                        .totalCartPrice
                                                                        .value,
                                                                    double.parse(checkoutController
                                                                        .amtIssuedFieldController
                                                                        .text
                                                                        .trim()),
                                                                  );
                                                                }
                                                              }
                                                            },
                                                          ),
                                                          SizedBox(
                                                            width: CSizes
                                                                .spaceBtnItems,
                                                          ),

                                                          // -- field to set quantity --
                                                          SizedBox(
                                                            width: 40.0,
                                                            child:
                                                                TextFormField(
                                                              controller:
                                                                  cartController
                                                                          .qtyFieldControllers[
                                                                      index],
                                                              //initialValue: qtyFieldInitialValue,
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                disabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                enabledBorder:
                                                                    InputBorder
                                                                        .none,
                                                                errorBorder:
                                                                    InputBorder
                                                                        .none,
                                                                focusedBorder:
                                                                    InputBorder
                                                                        .none,
                                                                hintText: 'qty',
                                                              ),
                                                              keyboardType:
                                                                  const TextInputType
                                                                      .numberWithOptions(
                                                                decimal: false,
                                                                signed: false,
                                                              ),
                                                              inputFormatters: <TextInputFormatter>[
                                                                FilteringTextInputFormatter
                                                                    .digitsOnly
                                                              ],
                                                              style: TextStyle(
                                                                color: isDarkTheme
                                                                    ? CColors
                                                                        .white
                                                                    : CColors
                                                                        .rBrown,
                                                              ),

                                                              onChanged:
                                                                  (value) {
                                                                invController
                                                                    .fetchUserInventoryItems();
                                                                cartController
                                                                    .fetchCartItems();
                                                                if (cartController
                                                                        .qtyFieldControllers[
                                                                            index]
                                                                        .text !=
                                                                    '') {
                                                                  var invItem = invController.inventoryItems.firstWhere((item) =>
                                                                      item.productId
                                                                          .toString() ==
                                                                      cartController
                                                                          .cartItems[
                                                                              index]
                                                                          .productId
                                                                          .toString()
                                                                          .toLowerCase());

                                                                  final thisCartItem =
                                                                      cartController.convertInvToCartItem(
                                                                          invItem,
                                                                          int.parse(
                                                                              value));

                                                                  cartController
                                                                      .addSingleItemToCart(
                                                                          thisCartItem,
                                                                          true,
                                                                          value);
                                                                  if (checkoutController
                                                                          .amtIssuedFieldController
                                                                          .text !=
                                                                      '') {
                                                                    checkoutController
                                                                        .computeCustomerBal(
                                                                      cartController
                                                                          .totalCartPrice
                                                                          .value,
                                                                      double.parse(checkoutController
                                                                          .amtIssuedFieldController
                                                                          .text),
                                                                    );
                                                                  }
                                                                }
                                                              },
                                                            ),
                                                          ),

                                                          CCircularIconBtn(
                                                            icon: Iconsax.add,
                                                            iconBorderRadius:
                                                                100,
                                                            width: 32.0,
                                                            height: 32.0,
                                                            iconSize: CSizes.md,
                                                            color:
                                                                CColors.white,
                                                            bgColor:
                                                                CColors.rBrown,
                                                            onPressed: () {
                                                              if (cartController
                                                                      .qtyFieldControllers[
                                                                          index]
                                                                      .text !=
                                                                  '') {
                                                                invController
                                                                    .fetchUserInventoryItems();
                                                                cartController
                                                                    .fetchCartItems();
                                                                var invItem = invController.inventoryItems.firstWhere((item) =>
                                                                    item.productId
                                                                        .toString() ==
                                                                    cartController
                                                                        .cartItems[
                                                                            index]
                                                                        .productId
                                                                        .toString()
                                                                        .toLowerCase());
                                                                final thisCartItem =
                                                                    cartController
                                                                        .convertInvToCartItem(
                                                                            invItem,
                                                                            1);
                                                                cartController
                                                                    .addSingleItemToCart(
                                                                        thisCartItem,
                                                                        false,
                                                                        null);
                                                                cartController
                                                                    .fetchCartItems();
                                                                cartController
                                                                        .qtyFieldControllers[
                                                                            index]
                                                                        .text =
                                                                    cartController
                                                                        .cartItems[
                                                                            index]
                                                                        .quantity
                                                                        .toString();
                                                                if (checkoutController
                                                                        .amtIssuedFieldController
                                                                        .text !=
                                                                    '') {
                                                                  checkoutController
                                                                      .computeCustomerBal(
                                                                    cartController
                                                                        .totalCartPrice
                                                                        .value,
                                                                    double.parse(
                                                                        checkoutController
                                                                            .amtIssuedFieldController
                                                                            .text),
                                                                  );
                                                                }
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 8.0,
                                                  ),
                                                  child: CProductPriceTxt(
                                                    price: (cartController
                                                                .cartItems[
                                                                    index]
                                                                .price *
                                                            cartController
                                                                .cartItems[
                                                                    index]
                                                                .quantity)
                                                        .toStringAsFixed(2),
                                                    isLarge: true,
                                                    txtColor: isDarkTheme
                                                        ? CColors.white
                                                        : CColors.rBrown,
                                                  ),
                                                ),
                                                // SizedBox(
                                                //   width: 10.0,
                                                // ),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              //Divider(),
                              SizedBox(
                                height: CSizes.defaultSpace / 4,
                              ),
                              // -- billing section --
                              CRoundedContainer(
                                padding: const EdgeInsets.all(CSizes.md),
                                showBorder: true,
                                bgColor:
                                    isDarkTheme ? CColors.black : CColors.white,
                                child: Column(
                                  children: [
                                    // pricing
                                    CBillingAmountSection(),
                                    //const SizedBox(height: CSizes.spaceBtnItems),

                                    // divider
                                    Divider(),
                                    //const SizedBox(height: CSizes.spaceBtnItems),
                                    // payment methods
                                    CPaymentMethodSection(
                                      platformName: checkoutController
                                                      .selectedPaymentMethod
                                                      .value
                                                      .platformName ==
                                                  'cash' ||
                                              checkoutController
                                                      .selectedPaymentMethod
                                                      .value
                                                      .platformName ==
                                                  'mPesa'
                                          ? checkoutController
                                              .selectedPaymentMethod
                                              .value
                                              .platformName
                                          : '',
                                      platformLogo: checkoutController
                                          .selectedPaymentMethod
                                          .value
                                          .platformLogo,
                                      txtFieldSpace: checkoutController
                                                  .selectedPaymentMethod
                                                  .value
                                                  .platformName ==
                                              'cash'
                                          ? Row(
                                              children: [
                                                const SizedBox(
                                                  width: CSizes.spaceBtnItems *
                                                      1.3,
                                                  height: 38.0,
                                                ),
                                                CRoundedContainer(
                                                  width: CHelperFunctions
                                                          .screenWidth() *
                                                      0.5,
                                                  bgColor: isDarkTheme
                                                      ? CColors.rBrown
                                                          .withValues(
                                                              alpha: 0.3)
                                                      : CColors.white,
                                                  child: TextFormField(
                                                    // keyboardType:
                                                    //     const TextInputType
                                                    //         .numberWithOptions(
                                                    //   decimal: true,
                                                    //   signed: false,
                                                    // ),
                                                    inputFormatters: <TextInputFormatter>[
                                                      FilteringTextInputFormatter
                                                          .allow(RegExp(
                                                              r'^\d+(\.\d*)?')),
                                                    ],
                                                    // autofocus: checkoutController
                                                    //     .setFocusOnAmtIssuedField
                                                    //     .value,
                                                    autofocus: false,
                                                    controller: checkoutController
                                                        .amtIssuedFieldController,
                                                    decoration: InputDecoration(
                                                      focusColor: CColors.rBrown
                                                          .withValues(
                                                        alpha: 0.3,
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          CSizes.cardRadiusLg,
                                                        ),
                                                        borderSide: BorderSide(
                                                          color: CColors.grey,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: CColors.rBrown
                                                              .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          CSizes.cardRadiusLg,
                                                        ),
                                                      ),
                                                      //border: InputBorder.none,
                                                      labelText:
                                                          'amount issued by customer',
                                                    ),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    onChanged: (value) {
                                                      if (value != '') {
                                                        checkoutController
                                                            .computeCustomerBal(
                                                          cartController
                                                              .totalCartPrice
                                                              .value,
                                                          double.parse(value),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                const SizedBox(
                                                  width: CSizes.spaceBtnItems *
                                                      1.1,
                                                  height: 38.0,
                                                ),
                                                CRoundedContainer(
                                                  width: CHelperFunctions
                                                          .screenWidth() *
                                                      0.5,
                                                  bgColor: isDarkTheme
                                                      ? CColors.rBrown
                                                          .withValues(
                                                              alpha: 0.3)
                                                      : CColors.white,
                                                  child: TextFormField(
                                                    keyboardType:
                                                        TextInputType.text,
                                                    // focusNode: checkoutController
                                                    //     .customerNameFocusNode
                                                    //     .value,
                                                    autofocus: false,

                                                    controller: checkoutController
                                                        .customerNameFieldController,
                                                    decoration: InputDecoration(
                                                      focusColor: CColors.rBrown
                                                          .withValues(
                                                        alpha: 0.3,
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          CSizes.cardRadiusLg,
                                                        ),
                                                        borderSide: BorderSide(
                                                          color: CColors.grey,
                                                        ),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          color: CColors.rBrown
                                                              .withValues(
                                                            alpha: 0.3,
                                                          ),
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          CSizes.cardRadiusLg,
                                                        ),
                                                      ),
                                                      labelText: checkoutController
                                                                  .selectedPaymentMethod
                                                                  .value
                                                                  .platformName ==
                                                              'mPesa'
                                                          ? 'customer name'
                                                          : 'customer name(optional)',
                                                    ),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: isDarkTheme
                                                          ? CColors.white
                                                          : CColors.rBrown,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                    // addresses
                                    //CBillingAddressSection(),
                                    // Visibility(
                                    //   visible: true,
                                    //   child: Column(
                                    //     children: [
                                    //       Text(
                                    //         'latitude: ${locationController.userLocation.value!.latitude}',
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //       Text(
                                    //         'longitude: ${locationController.userLocation.value!.longitude}',
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //       Text(
                                    //         'user Address: ${locationController.uAddress.value}',
                                    //         overflow: TextOverflow.ellipsis,
                                    //       ),
                                    //     ],
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: CSizes.spaceBtnSections,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        // floatingActionButton: Obx(
        //   () {
        //     return CCheckoutScanFAB(
        //       bgColor: CNetworkManager.instance.hasConnection.value
        //           ? CColors.rBrown
        //           : CColors.black,
        //     );
        //   },
        // ),

        /// -- bottom navigation bar --
        bottomNavigationBar: Obx(
          () {
            if (cartController.cartItems.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child:

                    /// -- button to complete txn --
                    SizedBox(
                  width: CHelperFunctions.screenWidth() * 0.98,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (checkoutController
                              .selectedPaymentMethod.value.platformName ==
                          'cash') {
                        if (checkoutController.amtIssuedFieldController.text ==
                            '') {
                          CPopupSnackBar.customToast(
                            message:
                                'please enter the amount issued by customer!!',
                            forInternetConnectivityStatus: false,
                          );
                          checkoutController.setFocusOnAmtIssuedField.value =
                              true;
                          return;
                        }
                        if (double.parse(checkoutController
                                .amtIssuedFieldController.text
                                .trim()) <
                            cartController.totalCartPrice.value) {
                          CPopupSnackBar.errorSnackBar(
                            title: 'customer still owes you!!',
                            message: 'the amount issued is not enough',
                          );
                          return;
                        }
                      }
                      if (checkoutController
                                  .selectedPaymentMethod.value.platformName ==
                              'mPesa' &&
                          checkoutController.customerNameFieldController.text ==
                              '') {
                        checkoutController.customerNameFocusNode.value
                            .requestFocus();
                        CPopupSnackBar.warningSnackBar(
                          title: 'customer details required!',
                          message:
                              'please provide customer\'s name for ${checkoutController.selectedPaymentMethod.value.platformName} payment verification',
                        );
                        return;
                      }
                      checkoutController.processTxn();
                    },
                    label: SizedBox(
                      height: 34.1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'CHECKOUT',
                            style:
                                Theme.of(context).textTheme.bodyMedium!.apply(
                                      color: CColors.white,
                                      fontSizeFactor: 0.88,
                                      fontWeightDelta: 1,
                                    ),
                          ),
                          Text(
                            '$currencySymbol.${cartController.totalCartPrice.value.toStringAsFixed(2)}',
                            style:
                                Theme.of(context).textTheme.bodyMedium!.apply(
                                      color: CColors.white,
                                      fontSizeFactor: 1.10,
                                      fontWeightDelta: 2,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    icon: Icon(
                      Iconsax.wallet_check,
                      color: CColors.white,
                    ),
                  ),
                ),
                // TODO: IMPLEMENT ABILITY TO SUSPEND TXN USING THIS BUTTON BELOW
                // Row(
                //   children: [

                //     const SizedBox(
                //       width: CSizes.spaceBtnInputFields,
                //     ),

                //     /// -- button to mark txn as pending --
                //     SizedBox(
                //       width: CHelperFunctions.screenWidth() * 0.45,
                //       child: ElevatedButton.icon(
                //         onPressed: () {
                //           //checkoutController.suspendTxn();
                //         },
                //         label: SizedBox(
                //           height: 34.1,
                //           child: Column(
                //             crossAxisAlignment: CrossAxisAlignment.center,
                //             mainAxisAlignment: MainAxisAlignment.end,
                //             children: [
                //               Text(
                //                 'SUSPEND',
                //                 style:
                //                     Theme.of(context).textTheme.bodyMedium!.apply(
                //                           color: CColors.white,
                //                           fontSizeFactor: 0.88,
                //                           fontWeightDelta: 1,
                //                         ),
                //               ),
                //               Text(
                //                 '$currencySymbol.${cartController.totalCartPrice.value.toStringAsFixed(2)}',
                //                 style:
                //                     Theme.of(context).textTheme.bodyMedium!.apply(
                //                           color: CColors.white,
                //                           fontSizeFactor: 1.10,
                //                           fontWeightDelta: 2,
                //                         ),
                //               ),
                //             ],
                //           ),
                //         ),
                //         icon: Icon(
                //           Iconsax.money_time,
                //           color: CColors.white,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              );
            } else {
              CPopupSnackBar.errorSnackBar(
                title: 'no cart items',
                message: 'no cart items found for checkout',
              );
              return SizedBox();
            }
          },
        ),
      ),
    );
  }
}
