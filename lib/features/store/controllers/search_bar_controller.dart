import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CSearchBarController extends GetxController {
  static CSearchBarController get instance {
    return Get.find();
  }

  /// -- variables --
  RxBool showSearchField = false.obs;
  //RxBool salesShowSearchField = false.obs;
  RxBool showAnimatedTypeAheadField = false.obs;

  // final txtInvSearchField = TextEditingController();
  final txtSearchField = TextEditingController();
  final txtTypeAheadFieldController = TextEditingController();

  final cartController = Get.put(CCartController());
  @override
  void onInit() {
    showSearchField.value = false;
    //salesShowSearchField.value = false;
    showAnimatedTypeAheadField.value = false;
    txtSearchField.text = '';
    // txtSalesSearch.text = '';
    super.onInit();
  }

  // onSearchBtnPressed(String searchSpace) {
  //   if (searchSpace == 'inventory') {
  //     invShowSearchField.value = !invShowSearchField.value;
  //   } else if (searchSpace == 'inventory, transactions') {
  //     salesShowSearchField.value = !salesShowSearchField.value;
  //   }
  // }

  toggleSearchFieldVisibility() {
    showSearchField.value = !showSearchField.value;
    if (!showSearchField.value) {
      txtSearchField.text = '';
    }
  }

  onTypeAheadSearchIconTap() {
    showAnimatedTypeAheadField.value = !showAnimatedTypeAheadField.value;
    cartController.itemQtyInCart.value = 0;
  }
}
