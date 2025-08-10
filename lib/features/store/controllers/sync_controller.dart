import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CSyncController extends GetxController {
  static CSyncController get instance => Get.find();

  /// -- variables --
  final invController = Get.put(CInventoryController());
  final RxBool processingSync = false.obs;
  final txnsController = Get.put(CTxnsController());

  @override
  void onInit() {
    processingSync.value = false;
    super.onInit();
  }

  Future<bool> processSync() async {
    try {
      processingSync.value = true;
      await invController.cloudSyncInventory();
      //await invController.cloudSyncInventory();

      if (await invController.cloudSyncInventory()) {
        await txnsController.addSalesDataToCloud().then(
          (_) async {
            if (await txnsController.addSalesDataToCloud()) {
              if (invController.syncIsLoading.value &&
                  txnsController.txnsSyncIsLoading.value) {
                processingSync.value = true;
              } else {
                processingSync.value = false;
              }
            }
          },
        );
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
        CPopupSnackBar.errorSnackBar(
          title: 'error processing sync',
          message: e.toString(),
        );
      }
      return false;
    }
  }
}
