import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/local_storage/storage_utility.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CGeneralBindings extends Bindings {
  @override
  void dependencies() async {
    Get.put(CNetworkManager());
    Get.put(CTxnsController());

    /// -- todo: init local storage (GetX Local Storage) --
    GetStorage.init().then((_) async {
      Get.put(CLocalStorage.instance());

      Get.put(CCheckoutController());
    });
  }
}
