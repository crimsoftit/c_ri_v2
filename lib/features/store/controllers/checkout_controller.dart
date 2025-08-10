import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:c_ri/common/widgets/success_screen/txn_success.dart';
import 'package:c_ri/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:c_ri/features/personalization/controllers/location_controller.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/features/store/controllers/sync_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/features/store/models/cart_item_model.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/features/store/models/payment_method_model.dart';
import 'package:c_ri/features/store/models/txns_model.dart';
import 'package:c_ri/features/store/screens/store_items_tings/checkout/checkout_screen.dart';
import 'package:c_ri/features/store/screens/store_items_tings/checkout/widgets/payment_methods/payment_methods_tile.dart';
import 'package:c_ri/features/store/screens/store_items_tings/inventory/inventory_details/widgets/add_to_cart_bottom_nav_bar.dart';
import 'package:c_ri/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:c_ri/nav_menu.dart';
import 'package:c_ri/services/location_services.dart';
import 'package:c_ri/services/pdf_services.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/db/sqflite/db_helper.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/full_screen_loader.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class CCheckoutController extends GetxController {
  static CCheckoutController get instance => Get.find();

  @override
  void onInit() async {
    await dbHelper.openDb();

    amtIssuedFieldController.text = '';
    setFocusOnAmtIssuedField.value = false;
    CLocationServices.instance
        .getUserLocation(locationController: locationController);

    super.onInit();
  }

  /// -- variables --
  AddUpdateItemDialog dialog = AddUpdateItemDialog();

  final Rx<CPaymentMethodModel> selectedPaymentMethod = CPaymentMethodModel(
    platformLogo: CImages.cash6,
    platformName: 'cash',
  ).obs;

  final pdfServices = CPdfServices.instance;

  RxList<CCartItemModel> itemsInCart = <CCartItemModel>[].obs;

  final CLocationController locationController =
      Get.put<CLocationController>(CLocationController());

  final RxString checkoutItemScanResults = ''.obs;

  final RxBool setFocusOnAmtIssuedField = false.obs;

  final invController = Get.put(CInventoryController());
  final navController = Get.put(CNavMenuController());
  final txnsController = Get.put(CTxnsController());
  final userController = Get.put(CUserController());

  TextEditingController amtIssuedFieldController = TextEditingController();

  TextEditingController customerNameFieldController = TextEditingController();

  final TextEditingController modalQtyFieldController = TextEditingController();

  DbHelper dbHelper = DbHelper.instance;

  final RxBool itemExists = false.obs;
  final RxBool isLoading = false.obs;

  final RxInt itemStockCount = 0.obs;
  final RxInt checkoutItemId = 0.obs;
  final RxInt checkoutItemSales = 0.obs;
  final RxInt txnId = 0.obs;

  final RxDouble customerBal = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;

  final RxString checkoutItemCode = ''.obs;
  final RxString checkoutItemLastModified = ''.obs;
  final RxString checkoutItemName = ''.obs;

  final Rx<FocusNode> customerNameFocusNode = FocusNode().obs;

  /// -- process txn --
  void processTxn() async {
    try {
      // -- start loader --
      CFullScreenLoader.openLoadingDialog(
        'processing txn...',
        CImages.docerAnimation,
      );

      txnsController.fetchSoldItems();

      final cartController = Get.put(CCartController());

      // -- fetch cart content --
      cartController.fetchCartItems();

      // -- txn details --

      if (cartController.cartItems.isNotEmpty) {
        for (var item in cartController.cartItems) {
          itemsInCart.add(item);
        }
      }

      if (itemsInCart.isNotEmpty) {
        txnId.value = CHelperFunctions.generateTxnId();

        var userCoordinates = '';

        if (locationController.userLocation.value!.latitude == null ||
            locationController.userLocation.value!.longitude == null) {
          userCoordinates = userController.user.value.locationCoordinates;
        } else {
          userCoordinates =
              'lat: ${locationController.userLocation.value!.latitude} long: ${locationController.userLocation.value!.longitude}';
        }

        for (var cartItem in itemsInCart) {
          var newTxnData = CTxnsModel(
            txnId.value,
            userController.user.value.id,
            userController.user.value.email,
            userController.user.value.fullName,
            cartItem.productId,
            cartItem.pCode,
            cartItem.pName,
            cartItem.quantity,
            0,
            '',
            cartController.totalCartPrice.value,
            selectedPaymentMethod.value.platformName == 'cash'
                ? double.parse(amtIssuedFieldController.text.trim())
                : 0.00,
            selectedPaymentMethod.value.platformName == 'cash'
                ? customerBal.value
                : 0.00,
            cartItem.price,
            0.00,
            selectedPaymentMethod.value.platformName,
            customerNameFieldController.text.trim(),
            '',
            locationController.uAddress.value != ''
                ? locationController.uAddress.value
                : userController.user.value.userAddress,
            userCoordinates,
            //'lat: ${locationController.userLocation.value!.latitude ?? ''} long: ${locationController.userLocation.value!.longitude ?? ''}',
            DateFormat('yyyy-MM-dd @ kk:mm').format(clock.now()),
            0,
            'append',
            'complete',
          );

          // save txn data into the db
          await dbHelper.addSoldItem(newTxnData).then((result) async {
            if (dbHelper.saleItemAddedToDb.value) {
              result = 'item added';

              // -- update stock count & total sales for this inventory item --
              final invController = Get.put(CInventoryController());
              invController.fetchUserInventoryItems();
              var invItem = invController.inventoryItems
                  .firstWhere((item) => item.productId == cartItem.productId);

              invItem.qtySold += cartItem.quantity;

              if (invItem.quantity == cartItem.quantity) {
                invItem.quantity = 0;
              } else {
                invItem.quantity -= cartItem.quantity;
              }

              await dbHelper.updateInventoryItem(invItem, cartItem.productId);

              if (kDebugMode) {
                print('** inventory stock update successful **');
              }

              // -- update sync status/action for this inventory item --
              var sAction = invItem.isSynced == 1 ? 'update' : 'append';
              dbHelper.updateInvOfflineSyncAfterStockUpdate(
                  sAction, cartItem.productId);

              invController.fetchUserInventoryItems();
            } else {
              result = 'ERROR ADDING SALE ITEM';
            }
          });
        }
        Get.offAll(
          () {
            final syncController = Get.put(CSyncController());
            return CTxnSuccessScreen(
              lottieImage: syncController.processingSync.value
                  ? CImages.loadingAnime
                  : CImages.paymentSuccessfulAnimation,
              title: 'txn success',
              subTitle: syncController.processingSync.value
                  ? 'processing cloud sync...'
                  : 'transaction successful',
              onContinueBtnPressed: () async {
                txnsController.fetchSoldItems();

                final internetIsConnected =
                    await CNetworkManager.instance.isConnected();

                if (internetIsConnected) {
                  await syncController.processSync();
                  if (await syncController.processSync()) {
                    if (txnsController.unsyncedTxnAppends.isNotEmpty) {
                      await syncController.processSync();
                    }
                  } else {
                    if (kDebugMode) {
                      print('error processing cloud sync');
                      CPopupSnackBar.errorSnackBar(
                        title: 'error processing cloud sync',
                        message: 'error processing cloud sync',
                      );
                    }
                  }
                } else {
                  if (kDebugMode) {
                    print('internet connection required for cloud sync!');
                    CPopupSnackBar.customToast(
                      message: 'internet connection required for cloud sync!',
                      forInternetConnectivityStatus: true,
                    );
                  }
                }
                refreshData();
              },
            );
          },
        );
      } else {
        CPopupSnackBar.errorSnackBar(
          title: 'empty cart...',
          message: 'your cart is empty',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'error processing txn..',
          message: '$e',
        );
      }

      throw e.toString();
    }
  }

  /// -- method to select payment method --
  Future<dynamic> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(
              CSizes.lg / 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CSectionHeading(
                  showActionBtn: false,
                  title: 'select payment method...',
                  btnTitle: '',
                  editFontSize: true,
                ),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 4,
                ),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.cash6,
                    platformName: 'cash',
                  ),
                ),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 4,
                ),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.mPesaLogo,
                    platformName: 'mPesa',
                  ),
                ),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 4,
                ),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.googlePayLogo,
                    platformName: 'google pay',
                  ),
                ),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 4,
                ),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.paypalLogo,
                    platformName: 'paypal',
                  ),
                ),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 4,
                ),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.masterCardLogo,
                    platformName: 'master card',
                  ),
                ),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 4,
                ),
                CPaymentMethodsTile(
                  paymentMethod: CPaymentMethodModel(
                    platformLogo: CImages.visaLogo,
                    platformName: 'visa',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// -- scan item for checkout --
  Future<void> scanItemForCheckout() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'cancel',
        true,
        ScanMode.BARCODE,
        3000,
        CameraFace.back.toString(),
        ScanFormat.ALL_FORMATS,
      );
      checkoutItemScanResults.value = barcodeScanRes;
      // -- set inventory item details to fields --
      if (checkoutItemScanResults.value != '' &&
          checkoutItemScanResults.value != '-1') {
        await invController.fetchUserInventoryItems();
        fetchForSaleItemByCode(checkoutItemScanResults.value);

        await fetchForSaleItemByCode(barcodeScanRes);
        if (itemExists.value) {
          nextActionAfterScanModal(Get.overlayContext!);
        } else {
          invController.resetInvFields();
          invController.txtCode.text = checkoutItemScanResults.value;
          showDialog(
            context: Get.overlayContext!,
            useRootNavigator: false,
            builder: (BuildContext context) => dialog.buildDialog(
              context,
              CInventoryModel('', '', '', '', '', 0, 0, 0, 0, 0.0, 0.0, 0.0, 0,
                  '', '', '', '', 0, ''),
              true,
            ),
          );
        }
      }
    } on PlatformException catch (platformException) {
      if (platformException.code == BarcodeScanner.cameraAccessDenied) {
        CPopupSnackBar.warningSnackBar(
            title: 'camera access denied',
            message: 'permission to use your camera is denied!!!');
      } else {
        CPopupSnackBar.errorSnackBar(
          title: 'platform exception error!',
          message: platformException.message,
        );
      }
    } on FormatException catch (formatException) {
      CPopupSnackBar.errorSnackBar(
        title: 'format exception error!!',
        message: formatException.message,
      );
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'scan error!',
        message: e.toString(),
      );
    }
  }

  /// -- modal for next action after successful item scan --
  Future<dynamic> nextActionAfterScanModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) {
        final invItem = invController.inventoryItems
            .firstWhere((item) => item.productId == checkoutItemId.value);
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(
              CSizes.lg / 3,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${checkoutItemLastModified.value} ',
                        style: Theme.of(context).textTheme.labelSmall!.apply(),
                      ),
                      TextSpan(
                        text: '(${itemStockCount.value} stocked)',
                        style: Theme.of(context).textTheme.labelSmall!.apply(),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  checkoutItemName.value.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium!.apply(),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'code: ${checkoutItemCode.value}',
                        style: Theme.of(context).textTheme.labelSmall!.apply(),
                      ),
                      TextSpan(
                        text: ' (${checkoutItemSales.value} sold)',
                        style: Theme.of(context).textTheme.labelSmall!.apply(),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Divider(
                  color: CHelperFunctions.isDarkMode(context)
                      ? CColors.white
                      : CColors.rBrown,
                ),
                CAddToCartBottomNavBar(
                  inventoryItem: invItem,
                  minusIconBtnColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.white.withValues(alpha: 0.5)
                      : CColors.rBrown.withValues(alpha: 0.5),
                  minusIconTxtColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.rBrown
                      : CColors.white,
                  addIconBtnColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.white
                      : CColors.rBrown,
                  addIconTxtColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.rBrown
                      : CColors.white,
                  add2CartBtnBorderColor: CHelperFunctions.isDarkMode(context)
                      ? CColors.white
                      : CColors.rBrown,
                  fromCheckoutScreen: true,
                ),
                const SizedBox(
                  height: CSizes.spaceBtnItems,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<CInventoryModel>> fetchForSaleItemByCode(String code) async {
    try {
      isLoading.value = true;

      // fetch scanned item from sqflite db
      final fetchedItem = await dbHelper.fetchInvItemByCodeAndEmail(
          code, userController.user.value.email);

      if (fetchedItem.isNotEmpty) {
        itemExists.value = true;
        checkoutItemId.value = fetchedItem.first.productId!;
        checkoutItemName.value = fetchedItem.first.name;
        checkoutItemCode.value = fetchedItem.first.pCode;
        checkoutItemSales.value = fetchedItem.first.qtySold;
        itemStockCount.value = fetchedItem.first.quantity;
        checkoutItemLastModified.value = fetchedItem.first.lastModified;
      } else {
        resetSalesFields();
        itemExists.value = false;
      }
      return fetchedItem;
    } catch (e) {
      isLoading.value = false;
      itemExists.value = false;
      if (kDebugMode) {
        print(e.toString());
        throw CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap! error fetching for sale item by code!',
          message: e.toString(),
        );
      }
      return [];
    }
  }

  computeCustomerBal(double cartTotals, double amtIssued) {
    customerBal.value = amtIssued - cartTotals;
  }

  resetSalesFields() {
    customerBal.value = 0.0;
    amtIssuedFieldController.text = '';
    itemExists.value = false;

    // clear cart
    //cartController.clearCart();

    setFocusOnAmtIssuedField.value = false;
  }

  /// -- calculate totals --
  computeTotals(String value, double usp) {
    if (value.isNotEmpty) {
      totalAmount.value = int.parse(value) * usp;

      txnsController.checkStockStatus(value);
    } else {
      totalAmount.value = 0.0;
    }
  }

  Future handleNavToCheckout() async {
    final cartController = Get.put(CCartController());
    Get.put(CCheckoutController());
    cartController.fetchCartItems().then(
      (_) async {
        if (await cartController.fetchCartItems()) {
          Get.to(() => const CCheckoutScreen());
        }
      },
    );
  }

  refreshData() {
    final cartController = Get.put(CCartController());
    txnsController.fetchSoldItems();
    customerBal.value = 0.0;

    // clear cart
    cartController.clearCart();
    itemsInCart.clear();

    resetSalesFields();

    navController.selectedIndex.value = 1;

    Get.offAll(() => NavMenu());
  }

  @override
  void dispose() {
    customerNameFocusNode.value.dispose();
    super.dispose();
  }
}
