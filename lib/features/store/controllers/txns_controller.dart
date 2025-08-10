import 'dart:async';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:c_ri/api/sheets/store_sheets_api.dart';
import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/icon_buttons/circular_icon_btn.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/search_bar_controller.dart';
import 'package:c_ri/features/store/controllers/sync_controller.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/features/store/models/txns_model.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/db/sqflite/db_helper.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/flutter_barcode_scanner.dart';

class CTxnsController extends GetxController {
  static CTxnsController get instance {
    return Get.find();
  }

  @override
  void onInit() async {
    await dbHelper.openDb();

    await fetchSoldItems();
    await fetchTxns();
    await initTxnsSync();

    showAmountIssuedField.value = true;
    refundQty.value = 0;
    super.onInit();
  }

  /// -- initialize cloud sync --
  Future initTxnsSync() async {
    if (localStorage.read('SyncTxnsDataWithCloud') == true) {
      await importTxnsFromCloud();
      if (await importTxnsFromCloud()) {
        localStorage.write('SyncTxnsDataWithCloud', false);
      }

      await fetchSoldItems();
    }
  }

  /// -- variables --
  final localStorage = GetStorage();

  DbHelper dbHelper = DbHelper.instance;

  final RxList<CTxnsModel> sales = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> foundSales = <CTxnsModel>[].obs;

  final RxList<CTxnsModel> txns = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> foundTxns = <CTxnsModel>[].obs;
  RxList<CTxnsModel> receiptItems = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> refunds = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> foundRefunds = <CTxnsModel>[].obs;

  final RxList<CTxnsModel> allGsheetTxnsData = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> unsyncedTxnAppends = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> unsyncedTxnUpdates = <CTxnsModel>[].obs;
  final RxList<CTxnsModel> userGsheetTxnsData = <CTxnsModel>[].obs;

  RxList txnDets = [].obs;

  final RxString sellItemScanResults = ''.obs;
  final RxString selectedPaymentMethod = 'Cash'.obs;
  final RxString stockUnavailableErrorMsg = ''.obs;
  final RxString customerBalErrorMsg = ''.obs;
  final RxString amtIssuedFieldError = ''.obs;

  final RxBool isImportingTxnsFromCloud = false.obs;
  final RxBool itemExists = false.obs;
  final RxBool showAmountIssuedField = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool txnItemsLoading = false.obs;
  final RxBool txnsSyncIsLoading = false.obs;
  final RxBool includeCustomerDetails = false.obs;
  final RxBool txnSuccesfull = false.obs;
  final RxBool txnsFetched = false.obs;
  final RxBool soldItemsFetched = false.obs;
  final RxBool updatesOnRefundDone = false.obs;
  final RxBool refundDataUpdated = false.obs;

  final txtAmountIssued = TextEditingController();
  final txtCustomerName = TextEditingController();
  final txtCustomerContacts = TextEditingController();
  final txtRefundReason = TextEditingController();
  final txtSaleItemQty = TextEditingController();
  final txtTxnAddress = TextEditingController();

  final RxInt sellItemId = 0.obs;
  final RxInt qtyAvailable = 0.obs;
  final RxInt totalSales = 0.obs;
  final RxInt refundQty = 0.obs;

  final RxString saleItemName = ''.obs;
  final RxString saleItemCode = ''.obs;

  final RxDouble saleItemBp = 0.0.obs;
  final RxDouble saleItemUsp = 0.0.obs;
  final RxDouble deposit = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxDouble customerBal = 0.0.obs;

  final userController = Get.put(CUserController());
  final searchController = Get.put(CSearchBarController());
  final invController = Get.put(CInventoryController());

  final txnsFormKey = GlobalKey<FormState>();

  /// -- fetch sold items from sqflite db --
  Future<List<CTxnsModel>> fetchSoldItems() async {
    try {
      // start loader while txns are fetched
      isLoading.value = true;
      foundSales.clear();
      foundRefunds.clear();
      await dbHelper.openDb();

      // fetch
      final soldItems =
          await dbHelper.fetchAllSoldItems(userController.user.value.email);

      // assign txns to sales list
      sales.assignAll(soldItems);

      // assign values for unsynced txn appends
      unsyncedTxnAppends.value = sales
          .where((unAppendedTxn) =>
              unAppendedTxn.syncAction.toLowerCase().contains('append'))
          .toList();

      // assign values for unsynced txn updates
      var txnsForUpdates = sales
          .where((unUpdatedTxn) =>
              unUpdatedTxn.syncAction.toLowerCase().contains('update') &&
              unUpdatedTxn.isSynced == 1)
          .toList();
      unsyncedTxnUpdates.assignAll(txnsForUpdates);

      // assign values for refunded items
      var refundedItems =
          sales.where((refundedItem) => refundedItem.qtyRefunded >= 1).toList();
      refunds.assignAll(refundedItems);

      if (searchController.showSearchField.isTrue &&
          searchController.txtSearchField.text == '') {
        foundSales.assignAll(soldItems);
        foundRefunds.assignAll(refundedItems);
      }

      // stop loader
      isLoading.value = false;
      soldItemsFetched.value = true;

      return sales;
    } catch (e) {
      isLoading.value = false;
      soldItemsFetched.value = false;

      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap!',
          message: e.toString(),
        );
      }
      throw e.toString();
    }
  }

  /// -- fetch sold items from sqflite db --
  Future<List<CTxnsModel>> fetchTxns() async {
    try {
      // start loader while txns are fetched
      isLoading.value = true;
      await dbHelper.openDb();
      await fetchSoldItems();

      // fetch txns from sqflite db
      final transactions = await dbHelper
          .fetchSoldItemsGroupedByTxnId(userController.user.value.email);

      // assign txns to soldItemsList
      txns.assignAll(transactions);

      foundTxns.value = txns;

      txnsFetched.value = true;

      // stop loader
      isLoading.value = false;

      return txns;
    } catch (e) {
      txnsFetched.value = false;
      isLoading.value = false;

      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap!',
          message: e.toString(),
        );
      }
      throw e.toString();
    }
  }

  /// -- fetch txn items by txn id --
  Future<List<CTxnsModel>> fetchTxnItems(int txnId) async {
    try {
      // start loader while txns are fetched
      txnItemsLoading.value = true;
      isLoading.value = true;

      receiptItems.clear();
      fetchTxns().then(
        (_) {
          if (txns.isNotEmpty &&
              sales.isNotEmpty &&
              soldItemsFetched.value &&
              txnsFetched.value) {
            var txnItems = sales
                .where((soldItem) =>
                    soldItem.txnId.toString().contains(txnId.toString()))
                .toList();

            receiptItems.assignAll(txnItems);
          } else {
            // stop loader
            txnItemsLoading.value = false;
            isLoading.value = false;
            receiptItems.clear();
            return CPopupSnackBar.warningSnackBar(
              title: 'items not found',
              message: 'items NOT found for this txn',
            );
          }
        },
      );

      txnItemsLoading.value = false;
      isLoading.value = false;

      return receiptItems;
    } catch (e) {
      txnItemsLoading.value = false;
      isLoading.value = false;
      receiptItems.clear();
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap! error fetching txn items',
          message: e.toString(),
        );
      }
      throw e.toString();
    }
  }

  /// -- barcode scanner using flutter_barcode_scanner package --
  Future<void> scanItemForSale() async {
    try {
      String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666',
          'cancel',
          true,
          ScanMode.BARCODE,
          3000,
          CameraFace.back.toString(),
          ScanFormat.ALL_FORMATS);

      sellItemScanResults.value = barcodeScanRes;

      // -- set inventory item details to fields --
      if (sellItemScanResults.value != '' &&
          sellItemScanResults.value != '-1') {
        //fetchForSaleItemByCode(sellItemScanResults.value);
        await fetchSoldItems();
        await fetchForSaleItemByCode(barcodeScanRes);
      }

      if (itemExists.value && !isLoading.value) {
        Get.toNamed(
          '/sales/sell_item/',
        );
      } else {
        CPopupSnackBar.customToast(
          message: 'item not found! please scan again or search inventory',
          forInternetConnectivityStatus: false,
        );
        await fetchSoldItems();
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
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'sell item scan error!',
          message: e.toString(),
        );
      }
      throw e.toString();
    }
  }

  /// -- fetch inventory item by code --
  Future<List<CInventoryModel>> fetchForSaleItemByCode(String code) async {
    try {
      // start loader while products are fetched
      isLoading.value = true;

      // fetch scanned item from sqflite db
      final fetchedItem = await dbHelper.fetchInvItemByCodeAndEmail(
          code, userController.user.value.email);

      //fetchInventoryItems();
      updatesOnRefundDone.value = false;
      refundDataUpdated.value = false;

      if (fetchedItem.isNotEmpty) {
        itemExists.value = true;
        sellItemId.value = fetchedItem.first.productId!;
        saleItemCode.value = fetchedItem.first.pCode;
        saleItemName.value = fetchedItem.first.name;
        saleItemBp.value = fetchedItem.first.buyingPrice;
        saleItemUsp.value = fetchedItem.first.unitSellingPrice;

        qtyAvailable.value = fetchedItem.first.quantity;
        totalSales.value = fetchedItem.first.qtySold;
      } else {
        itemExists.value = false;
        txtSaleItemQty.text = '';
        totalSales.value = 0;
      }

      isLoading.value = false;

      return fetchedItem;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('****');
        print(e.toString());
        print('****');
        CPopupSnackBar.errorSnackBar(
          title: 'error fetching scan item!',
          message: 'error fetching scan item for sale: $e',
        );
      }

      throw e.toString();
    }
  }

  searchSales(String value) {
    try {
      fetchSoldItems();
      var salesFound = sales
          .where((soldItem) =>
              soldItem.productName
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              soldItem.txnId
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              soldItem.productCode
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              soldItem.productId
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
      foundSales.assignAll(salesFound);
      var refundsFound = refunds
          .where((refundedItem) =>
              refundedItem.productName
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              refundedItem.txnId
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              refundedItem.productCode
                  .toLowerCase()
                  .contains(value.toLowerCase()) ||
              refundedItem.productId
                  .toString()
                  .toLowerCase()
                  .contains(value.toLowerCase()))
          .toList();
      foundRefunds.assignAll(refundsFound);
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'error searching sales',
        message: '$e',
      );
      throw e.toString();
    }
  }

  /// -- when search result item is selected --
  onSellItemBtnAction(CInventoryModel foundItem) {
    //onInit();
    selectedPaymentMethod.value == "Cash";
    showAmountIssuedField.value == true;
    setTransactionDetails(foundItem);
    Get.toNamed(
      '/sales/sell_item/',
    );
  }

  /// -- calculate totals --
  computeTotals(String value, double usp) {
    if (value.isNotEmpty) {
      totalAmount.value = int.parse(value) * usp;

      checkStockStatus(value);
    } else {
      totalAmount.value = 0.0;
    }
  }

  /// -- check if stock is available for sale --
  checkStockStatus(String value) {
    if (value != '') {
      if (int.parse(value) > qtyAvailable.value) {
        stockUnavailableErrorMsg.value = 'insufficient stock!!';
      } else {
        //qtyAvailable.value -= int.parse(value);
        stockUnavailableErrorMsg.value = '';
      }
    }
  }

  /// -- calculate customer balance --
  computeCustomerBal(double amountIsued, double totals) {
    if (txtAmountIssued.text.isNotEmpty && txtSaleItemQty.text.isNotEmpty) {
      customerBal.value = amountIsued - totals;
    } else {
      customerBal.value = 0.0;
    }
  }

  /// -- set payment method --
  setPaymentMethod(String value) {
    selectedPaymentMethod.value = value;
    if (selectedPaymentMethod.value == 'Cash') {
      showAmountIssuedField.value = true;
    } else {
      showAmountIssuedField.value = false;
    }

    // CPopupSnackBar.customToast(
    //   message: selectedPaymentMethod.value,
    // );
  }

  /// -- set sale details --
  setTransactionDetails(CInventoryModel foundItem) {
    sellItemId.value = foundItem.productId!;
    saleItemCode.value = foundItem.pCode;
    saleItemName.value = foundItem.name;
    saleItemBp.value = foundItem.buyingPrice;
    saleItemUsp.value = foundItem.unitSellingPrice;
    qtyAvailable.value = foundItem.quantity;
    totalSales.value = foundItem.qtySold;
    showAmountIssuedField.value = true;
    selectedPaymentMethod.value == 'Cash';
    if (selectedPaymentMethod.value == 'Cash') {
      showAmountIssuedField.value = true;
    } else {
      showAmountIssuedField.value = false;
    }
  }

  /// -- reset sales --
  resetSalesFields() {
    sellItemScanResults.value = '';
    selectedPaymentMethod.value == 'Cash';
    itemExists.value = false;
    showAmountIssuedField.value = true;
    updatesOnRefundDone.value = false;
    refundDataUpdated.value = false;
    isLoading.value = false;

    saleItemName.value = '';
    saleItemCode.value = '';
    qtyAvailable.value = 0;
    totalSales.value = 0;
    saleItemBp.value = 0.0;
    saleItemUsp.value = 0.0;
    deposit.value = 0.0;
    totalAmount.value = 0.0;
    customerBal.value = 0.0;

    txtSaleItemQty.text = '';
    txtAmountIssued.text = '';
    txtCustomerName.text = '';
    txtCustomerContacts.text = '';
    txtTxnAddress.text = '';
  }

  /// -- add unsynced txns to the cloud --
  Future<bool> addSalesDataToCloud() async {
    try {
      isLoading.value = true;
      txnsSyncIsLoading.value = true;
      fetchSoldItems().then(
        (result) {
          if (result.isNotEmpty) {
            final unsyncedTxnsForAppends = sales.where((unsyncedTxn) =>
                unsyncedTxn.syncAction.toLowerCase() ==
                    'append'.toLowerCase() &&
                unsyncedTxn.isSynced == 0);

            // -- update refunds data
            if (unsyncedTxnUpdates.isNotEmpty) {
              for (var updateItem in unsyncedTxnUpdates) {
                updateItem.syncAction = 'none';
                updateItem.txnStatus = 'complete';

                // -- update sales data on the cloud
                updateReceiptItemCloudData(updateItem.soldItemId!, updateItem);

                // -- update sales data locally
                dbHelper.updateReceiptItem(updateItem, updateItem.soldItemId!);
              }
            }

            if (unsyncedTxnsForAppends.isNotEmpty) {
              var gSheetTxnAppends = unsyncedTxnsForAppends
                  .map(
                    (sale) => {
                      'soldItemId': sale.soldItemId,
                      'txnId': sale.txnId,
                      'userId': sale.userId,
                      'userEmail': sale.userEmail,
                      'userName': sale.userName,
                      'productId': sale.productId,
                      'productCode': sale.productCode,
                      'productName': sale.productName,
                      'quantity': sale.quantity,
                      'qtyRefunded': sale.qtyRefunded,
                      'refundReason': sale.refundReason,
                      'totalAmount': sale.totalAmount,
                      'amountIssued': sale.amountIssued,
                      'customerBalance': sale.customerBalance,
                      'unitSellingPrice': sale.unitSellingPrice,
                      'deposit': sale.deposit,
                      'paymentMethod': sale.paymentMethod,
                      'customerName': sale.customerName,
                      'customerContacts': sale.customerContacts,
                      'txnAddress': sale.txnAddress,
                      'txnAddressCoordinates': sale.txnAddressCoordinates,
                      'lastModified': sale.lastModified,
                      'isSynced': 1,
                      'syncAction': 'none',
                      'txnStatus': sale.txnStatus,
                    },
                  )
                  .toList();

              // -- save sales data to cloud --
              //StoreSheetsApi.initSpreadSheets();
              StoreSheetsApi.saveTxnsToGSheets(gSheetTxnAppends)
                  .then((result) async {
                if (result) {
                  // -- update txns status locally --
                  fetchSoldItems();
                  for (var forSyncItem in unsyncedTxnsForAppends) {
                    await dbHelper.updateTxnItemsSyncStatus(
                        1, 'none', forSyncItem.soldItemId!);
                  }
                  isLoading.value = false;
                  txnsSyncIsLoading.value = false;
                } else {
                  txnsSyncIsLoading.value = false;
                  CPopupSnackBar.errorSnackBar(
                    title: 'ERROR SYNCING TXNS TO CLOUD...',
                    message: 'an error occurred while uploading txns to cloud',
                  );
                }
              });
            } else {
              txnsSyncIsLoading.value = false;
              isLoading.value = false;
              if (kDebugMode) {
                print('***** ALL TXNS RADA SAFI *****');
                CPopupSnackBar.customToast(
                  message: '***** ALL TXNS RADA SAFI *****',
                  forInternetConnectivityStatus: false,
                );
              }
            }
          } else {
            txnsSyncIsLoading.value = false;
            isLoading.value = false;
            // CPopupSnackBar.customToast(
            //   message: 'NO SALES/TXNS FOUND!',
            //   forInternetConnectivityStatus: false,
            // );
          }
        },
      );
      fetchSoldItems();
      return true;
    } catch (e) {
      txnsSyncIsLoading.value = false;
      isLoading.value = false;
      if (kDebugMode) {
        print('***');
        print('* an error occurred while uploading txns to cloud: $e *');
        print('***');
        CPopupSnackBar.errorSnackBar(
          title: 'ERROR SYNCING TXNS TO CLOUD...',
          message: 'an error occurred while uploading txns to cloud: $e',
        );
      }

      //throw e.toString();
      return false;
    }
    // finally {
    //   txnsSyncIsLoading.value = false;
    //   isLoading.value = false;
    // }
  }

  /// -- fetch txns from google sheets by userEmail --
  Future fetchUserTxnsSheetData() async {
    try {
      isLoading.value = true;

      var gSheetTxnsList = await StoreSheetsApi.fetchAllTxnsFromCloud();

      allGsheetTxnsData.assignAll(gSheetTxnsList!);

      userGsheetTxnsData.value = allGsheetTxnsData
          .where((element) => element.userEmail
              .toLowerCase()
              .contains(userController.user.value.email.toLowerCase()))
          .toList();

      return userGsheetTxnsData;
    } catch (e) {
      isLoading.value = false;

      if (kDebugMode) {
        print('***');
        print(
            '* an error occurred while fetching user\'s cloud txn data: $e *');
        print('***');
        CPopupSnackBar.errorSnackBar(
          title: 'Oh Snap!',
          message: e.toString(),
        );
      }

      return CPopupSnackBar.errorSnackBar(
        title: 'Oh Snap!',
        message: 'an error occurred while fetching user\'s cloud txn data',
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// -- import transactions from cloud --
  Future<bool> importTxnsFromCloud() async {
    try {
      isImportingTxnsFromCloud.value = true;

      await fetchSoldItems();

      await fetchUserTxnsSheetData();

      if (userGsheetTxnsData.isNotEmpty) {
        if (sales.isEmpty) {
          for (var element in userGsheetTxnsData) {
            var dbTxnImports = CTxnsModel.withId(
              element.soldItemId,
              element.txnId,
              element.userId,
              element.userEmail,
              element.userName,
              element.productId,
              element.productCode,
              element.productName,
              element.quantity,
              element.qtyRefunded,
              element.refundReason,
              element.totalAmount,
              element.amountIssued,
              element.customerBalance,
              element.unitSellingPrice,
              element.deposit,
              element.paymentMethod,
              element.customerName,
              element.customerContacts,
              element.txnAddress,
              element.txnAddressCoordinates,
              element.lastModified,
              element.isSynced,
              element.syncAction,
              element.txnStatus,
            );

            await dbHelper.addSoldItem(dbTxnImports);
            await fetchSoldItems();
            isImportingTxnsFromCloud.value = false;
            isLoading.value = false;

            if (kDebugMode) {
              print(
                  "----------\n ===SYNCED TXNS=== \n ${userGsheetTxnsData.iterator} \n\n ----------");
            }
          }
        }
      }
      isImportingTxnsFromCloud.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('ERROR IMPORTING USER TXNS DATA FROM CLOUD!: $e');
        CPopupSnackBar.errorSnackBar(
          title: 'ERROR IMPORTING USER DATA FROM CLOUD!',
          message: e.toString(),
        );
      }
      return false;
    }
  }

  /// -- popup for item refund --
  void refundItemWarningPopup(CTxnsModel soldItem) {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(CSizes.sm),
      title: 'refund ${soldItem.productName}?',
      // middleText:
      //     'Are you certain you want to refund ${soldItem.productName} for $userCurrency.${soldItem.unitSellingPrice * soldItem.quantity}? This action can\'t be undone!',
      middleText: 'Are you certain you want to refund ${soldItem.productName}?',
      confirm: ElevatedButton(
        onPressed: () async {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(
            color: Colors.red,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: CSizes.sm),
          child: Text('confirm refund'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () {
          Navigator.of(Get.overlayContext!).pop();
        },
        child: const Text('cancel'),
      ),
    );
  }

  Future<dynamic> refundItemActionModal(
      BuildContext context, CTxnsModel soldItem) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      //transitionAnimationController: ,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: CRoundedContainer(
            height: CHelperFunctions.screenHeight() * 0.35,
            padding: const EdgeInsets.all(
              CSizes.lg / 3,
            ),
            bgColor: isDarkTheme ? CColors.rBrown : CColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'refund ${soldItem.productName.toUpperCase()}?',
                  style: Theme.of(context).textTheme.labelMedium!.apply(
                        color: isDarkTheme ? CColors.white : CColors.rBrown,
                      ),
                ),
                Text(
                  '${soldItem.quantity} sold (${soldItem.qtyRefunded} refunded)',
                  style: Theme.of(context).textTheme.labelMedium!.apply(
                        color: isDarkTheme ? CColors.white : CColors.rBrown,
                      ),
                ),
                Divider(
                  color: isDarkTheme ? CColors.white : CColors.rBrown,
                  endIndent: 100.0,
                  indent: 100.0,
                  thickness: 0.2,
                ),
                const SizedBox(
                  height: CSizes.spaceBtnInputFields / 4,
                ),
                Obx(
                  () {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('qty'),
                        const SizedBox(
                          width: CSizes.spaceBtnInputFields,
                        ),
                        CCircularIconBtn(
                          icon: Iconsax.minus,
                          iconBorderRadius: 100,
                          bgColor: CColors.black.withValues(alpha: 0.5),
                          width: 45.0,
                          height: 45.0,
                          color: CColors.white,
                          onPressed: () {
                            if (refundQty.value > 0 &&
                                refundQty.value <= soldItem.quantity) {
                              refundQty.value -= 1;
                            }
                          },
                        ),
                        //const CFavoriteIcon(),
                        const SizedBox(
                          width: CSizes.spaceBtnItems,
                        ),
                        Text(
                          refundQty.value > soldItem.quantity
                              ? soldItem.quantity.toString()
                              : refundQty.value.toString(),
                          style: Theme.of(context).textTheme.titleSmall!.apply(
                                color: isDarkTheme
                                    ? CColors.white
                                    : CColors.rBrown,
                              ),
                        ),
                        const SizedBox(
                          width: CSizes.spaceBtnItems,
                        ),

                        CCircularIconBtn(
                          iconBorderRadius: 100,
                          // bgColor: (CNetworkManager.instance.hasConnection.value
                          //     ? CColors.rBrown
                          //     : CColors.black),
                          bgColor: CColors.black,
                          icon: Iconsax.add,
                          color: CColors.white,
                          width: 45.0,
                          height: 45.0,
                          onPressed: () {
                            if (refundQty.value < soldItem.quantity) {
                              refundQty.value += 1;
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(
                  height: CSizes.spaceBtnInputFields,
                ),

                // -- textarea for reason of refund --
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextFormField(
                    controller: txtRefundReason,
                    decoration: InputDecoration(
                      labelText: 'reason for refund(optional)',
                      //labelStyle: textStyle,
                      suffixIcon: const Icon(
                        Iconsax.message,
                      ),
                    ),
                    maxLines: 1, // marked for observation - could be a textarea
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                // Divider(
                //   color: isDarkTheme ? CColors.white : CColors.rBrown,
                // ),
                const SizedBox(
                  height: CSizes.spaceBtnInputFields,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: CHelperFunctions.screenWidth() * 0.45,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // refund item actions - inventory & txn item updates;

                          await fetchSoldItems().then((result) async {
                            if (result.isNotEmpty) {
                              invController.fetchUserInventoryItems();
                              var inventoryItem = invController.inventoryItems
                                  .firstWhere((item) =>
                                      item.productId == soldItem.productId);

                              // -- update stock count & total sales for this inventory item --
                              if (inventoryItem.productId! > 100) {
                                inventoryItem.quantity += refundQty.value;
                                inventoryItem.qtyRefunded += refundQty.value;
                                inventoryItem.qtySold -= refundQty.value;
                                inventoryItem.lastModified =
                                    DateFormat('yyyy-MM-dd @ kk:mm')
                                        .format(clock.now());
                                inventoryItem.syncAction =
                                    inventoryItem.isSynced == 1
                                        ? 'update'
                                        : 'append';

                                await dbHelper
                                    .updateInventoryItem(
                                        inventoryItem, inventoryItem.productId!)
                                    .then((result) async {
                                  /// -- update receipt item --
                                  var txnItem = sales.firstWhere((txnItem) =>
                                      txnItem.productId == soldItem.productId);

                                  txnItem.refundReason =
                                      txtRefundReason.text.trim();
                                  txnItem.quantity -= refundQty.value;
                                  txnItem.qtyRefunded += refundQty.value;
                                  txnItem.totalAmount -= refundQty.value *
                                      txnItem.unitSellingPrice;
                                  txnItem.lastModified =
                                      DateFormat('yyyy-MM-dd @ kk:mm')
                                          .format(clock.now());
                                  txnItem.syncAction = txnItem.isSynced == 0
                                      ? 'append'
                                      : 'update';

                                  dbHelper
                                      .updateReceiptItem(
                                          txnItem, txnItem.soldItemId!)
                                      .then(
                                    (_) {
                                      fetchSoldItems();
                                      refundDataUpdated.value = true;
                                    },
                                  );
                                  // updateTxnDataOnRefund(txnItem);
                                  // if (await updateTxnDataOnRefund(txnItem)) {
                                  //   if (kDebugMode) {
                                  //     print("** ========== **\n");
                                  //     print(
                                  //         "*** inventory refund updates successful ***");
                                  //     print("** ========== **\n");
                                  //   }
                                  // }
                                  Navigator.of(Get.overlayContext!).pop(true);
                                });
                              } else {
                                if (kDebugMode) {
                                  print('ERROR: INVENTORY ITEM IS NULL');
                                  CPopupSnackBar.errorSnackBar(
                                    title: 'inv item error!!',
                                    message:
                                        'ERROR: INVENTORY ITEM productId IS NULL!!',
                                  );
                                }
                              }
                            } else {
                              if (kDebugMode) {
                                print("** ========== **\n");
                                print("ERROR UPDATING DATA AFTER REFUND");
                                print("** ========== **\n");
                              }
                            }
                          });
                        },
                        label: Text(
                          'REFUND',
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: Colors.red,
                              ),
                        ),
                        icon: Icon(
                          Iconsax.wallet_check,
                          color: Colors.red,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CColors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: CSizes.spaceBtnInputFields,
                    ),
                    SizedBox(
                      width: CHelperFunctions.screenWidth() * 0.45,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          resetSalesFields();
                          Navigator.of(context).pop(true);
                        },
                        label: Text(
                          'cancel',
                          style: Theme.of(context).textTheme.bodyMedium!.apply(
                                color: CColors.white,
                              ),
                        ),
                        icon: Icon(
                          Iconsax.undo,
                          color: CColors.rBrown,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CColors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      onBottomSheetClosed();
    });
  }

  /// -- reset refundQty to 0 when bottomSheetModal dismisses --
  void onBottomSheetClosed() async {
    final syncController = Get.put(CSyncController());

    final internetIsConnected = await CNetworkManager.instance.isConnected();

    if (refundDataUpdated.value) {
      if (internetIsConnected) {
        await syncController.processSync();
        if (await syncController.processSync()) {
          if (unsyncedTxnAppends.isNotEmpty) {
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
    }

    refundQty.value = 0;
    updatesOnRefundDone.value = false;
    resetSalesFields();

    if (kDebugMode) {
      print('------------------\n');
      print('refundQty: ${refundQty.value} \n');
      print('------------------\n');
      print('bottomSheet closed');
    }
  }

  /// -- update stock count and qtySold on refund --
  Future<bool> updateTxnDataOnRefundMaybeObsolet(CTxnsModel receiptItem) async {
    try {
      final currency = CHelperFunctions.formatCurrency(
          userController.user.value.currencyCode);

      // -- update stock count & total sales for this inventory item --
      // inventoryItem.quantity += refundQty.value;
      // inventoryItem.qtyRefunded += refundQty.value;
      // inventoryItem.qtySold -= refundQty.value;
      // inventoryItem.lastModified =
      //     DateFormat('yyyy-MM-dd @ kk:mm').format(clock.now());
      // inventoryItem.syncAction =
      //     inventoryItem.isSynced == 1 ? 'update' : 'append';

      //dbHelper.updateInventoryItem(inventoryItem, inventoryItem.productId!);

      // -- update sync status/action for this inventory item --

      // await dbHelper.updateInvOfflineSyncAfterStockUpdate(
      //     sAction, inventoryItem.productId!);

      // -- update txn data for this receipt item --
      // receiptItem.quantity -= refundQty.value;
      // receiptItem.qtyRefunded += refundQty.value;
      // receiptItem.totalAmount -= refundQty.value * receiptItem.unitSellingPrice;
      // receiptItem.lastModified =
      //     DateFormat('yyyy-MM-dd @ kk:mm').format(clock.now());
      // receiptItem.syncAction = receiptItem.isSynced == 0 ? 'append' : 'update';

      // dbHelper
      //     .updateReceiptItem(receiptItem, receiptItem.soldItemId!)
      //     .then((_) {
      //   fetchSoldItems();
      // });

      updatesOnRefundDone.value = true;
      CPopupSnackBar.successSnackBar(
        title: 'success',
        message:
            'refund of ${receiptItem.productName} (${refundQty.value} item(s)@$currency.${(receiptItem.unitSellingPrice * refundQty.value)}) SUCCESSFUL!!',
      );

      return true;
    } catch (e) {
      updatesOnRefundDone.value = false;
      CPopupSnackBar.errorSnackBar(
        title: 'Oh Snap! refund inventory updates failed',
        message: e.toString(),
      );
      return false;
    }
  }

  Future updateReceiptItemCloudData(int itemId, CTxnsModel itemModel) async {
    try {
      await StoreSheetsApi.updateReceiptItem(itemId, itemModel.toMap());
    } catch (e) {
      CPopupSnackBar.errorSnackBar(
        title: 'error updating sheet data',
        message: e.toString(),
      );

      throw e.toString();
    }
  }
}
