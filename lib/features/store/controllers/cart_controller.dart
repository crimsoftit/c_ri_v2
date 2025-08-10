import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/models/cart_item_model.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/utils/local_storage/storage_utility.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CCartController extends GetxController {
  static CCartController get instance => Get.find();

  /// -- variables --
  RxDouble discount = 0.0.obs;
  RxDouble taxFee = 0.0.obs;
  //RxDouble txnTotals = 0.0.obs;
  RxDouble totalCartPrice = 0.0.obs;

  final RxBool cartItemsLoading = false.obs;
  final userController = Get.put(CUserController());

  final RxInt countOfCartItems = 0.obs;
  RxInt itemQtyInCart = 0.obs;

  RxList<CCartItemModel> cartItems = <CCartItemModel>[].obs;

  RxList<TextEditingController> qtyFieldControllers =
      <TextEditingController>[].obs;

  CCartController() {
    fetchCartItems();
  }

  @override
  void onInit() async {
    cartItemsLoading.value = false;
    await fetchCartItems();

    super.onInit();
  }

  /// -- fetch cart items from device storage --
  Future<bool> fetchCartItems() async {
    try {
      cartItemsLoading.value = true;

      final cartItemsStrings =
          CLocalStorage.instance().readData<List<dynamic>>('cartItems');

      if (cartItemsStrings != null) {
        cartItems.assignAll(cartItemsStrings.map(
            (item) => CCartItemModel.fromJson(item as Map<String, dynamic>)));

        updateCartTotals();
      }
      cartItemsLoading.value = false;
      return true;
    } catch (e) {
      final cartItemsStrings =
          CLocalStorage.instance().readData<List<dynamic>>('cartItems');
      if (cartItemsStrings != null) {
        cartItems.assignAll(cartItemsStrings.map(
            (item) => CCartItemModel.fromJson(item as Map<String, dynamic>)));

        updateCartTotals();
        cartItemsLoading.value = false;
        return true;
      } else {
        //cartItemsLoading.value = false;
        if (kDebugMode) {
          print('$e');
          CPopupSnackBar.errorSnackBar(
            title: 'error loading cart items',
            message: 'an unknown error occurred while fetching cart items: $e',
          );
        }
        //throw e.toString();
        cartItemsLoading.value = false;
        return false;
      }
    }
    // finally {
    //   cartItemsLoading.value = false;
    // }
  }

  /// -- add items to cart --
  void addToCart(CInventoryModel item) {
    // qty check
    if (itemQtyInCart.value < 1) {
      CPopupSnackBar.customToast(
        message: 'select quantity',
        forInternetConnectivityStatus: false,
      );
      return;
    }
    if (item.quantity < 1) {
      CPopupSnackBar.warningSnackBar(
        title: 'oh snap!',
        message: '${item.name} is out of stock!!',
      );
      return;
    }
    if (itemQtyInCart > item.quantity) {
      CPopupSnackBar.warningSnackBar(
        title: 'oh snap!',
        message: 'only ${item.quantity} items are stocked!',
      );
      return;
    }

    // convert the CInventoryModel to a CCartItemModel
    final selectedCartItem = convertInvToCartItem(item, itemQtyInCart.value);

    // check if selected cart item already exists in the cart
    // int index = deviceCartItems.indexWhere(
    //     (cartItem) => cartItem.productId == selectedCartItem.productId);
    int userCartItemIndex = cartItems.indexWhere(
        (uCartItem) => uCartItem.productId == selectedCartItem.productId);

    if (userCartItemIndex >= 0) {
      // item already added to cart
      // deviceCartItems[userCartItemIndex].quantity = selectedCartItem.quantity;
      cartItems[userCartItemIndex].quantity = selectedCartItem.quantity;
      qtyFieldControllers[userCartItemIndex].text =
          cartItems[userCartItemIndex].quantity.toString();
    } else {
      cartItems.add(selectedCartItem);
      qtyFieldControllers.add(
        TextEditingController(
          text: selectedCartItem.quantity.toString(),
        ),
      );
      updateCart();
    }

    // update cart for specific user
    updateCart();
    CPopupSnackBar.customToast(
      message: 'item successfully added to cart',
      forInternetConnectivityStatus: false,
    );
  }

  /// -- add a single item to cart --
  void addSingleItemToCart(
      CCartItemModel item, bool fromQtyTxtField, String? qtyValue) {
    int itemIndex = cartItems
        .indexWhere((cartItem) => cartItem.productId == item.productId);

    // -- check stock qty --
    final invController = Get.put(CInventoryController());
    final inventoryItem = invController.inventoryItems
        .firstWhere((invItem) => invItem.productId == item.productId);

    if (inventoryItem.quantity > 0) {
      if (itemIndex >= 0) {
        if (fromQtyTxtField && qtyValue != '') {
          if (int.parse(qtyValue!) > inventoryItem.quantity) {
            CPopupSnackBar.warningSnackBar(
              title: 'oh snap!',
              message: 'only ${inventoryItem.quantity} items are stocked!',
            );
            qtyFieldControllers[itemIndex].text =
                inventoryItem.quantity.toString();
            qtyValue = qtyFieldControllers[itemIndex].text;
            return;
          }
          cartItems[itemIndex].quantity = int.parse(qtyValue);

          qtyFieldControllers[itemIndex].text =
              cartItems[itemIndex].quantity.toString();
        } else {
          if (cartItems[itemIndex].quantity >= inventoryItem.quantity) {
            CPopupSnackBar.warningSnackBar(
              title: 'oh snap!',
              message: 'only ${inventoryItem.quantity} items are stocked!',
            );
            qtyFieldControllers[itemIndex].text =
                inventoryItem.quantity.toString();
            return;
          } else {
            if (fromQtyTxtField) {
              cartItems[itemIndex].quantity = int.parse(qtyValue!);
              qtyFieldControllers[itemIndex].text =
                  cartItems[itemIndex].quantity.toString();
            } else {
              cartItems[itemIndex].quantity += 1;
              //var itemQty = cartItems[itemIndex].quantity;
              qtyFieldControllers[itemIndex].text =
                  cartItems[itemIndex].quantity.toString();
              updateCart();
            }
          }
        }
      } else {
        cartItems.add(item);

        updateCart();
        qtyFieldControllers.add(TextEditingController(
          text: item.quantity.toString(),
        ));
      }

      updateCart();
    } else {
      CPopupSnackBar.warningSnackBar(
        title: 'oh snap!',
        message: '${cartItems[itemIndex].pName} is out of stock!',
      );
    }
  }

  /// -- decrement cart item qty/remove a single item from the cart --
  void removeSingleItemFromCart(CCartItemModel item, bool showConfirmDialog) {
    int removeItemIndex = cartItems.indexWhere(
      (itemToRemove) {
        return itemToRemove.productId == item.productId;
      },
    );

    if (removeItemIndex >= 0) {
      if (cartItems[removeItemIndex].quantity > 1) {
        cartItems[removeItemIndex].quantity -= 1;
      } else {
        if (showConfirmDialog) {
          // show confirm dialog before entirely removing
          cartItems[removeItemIndex].quantity == 1
              ? removeItemFromCartDialog(removeItemIndex, item.pName)
              : cartItems.removeAt(removeItemIndex);
        } else {
          // perform action to entirely remove this item from the cart
          cartItems.removeAt(removeItemIndex);
          updateCart();
          // CPopupSnackBar.customToast(
          //   message: '$itemToRemove removed from the cart...',
          //   forInternetConnectivityStatus: false,
          // );
        }
      }
      updateCart();
      qtyFieldControllers[removeItemIndex].text =
          cartItems[removeItemIndex].quantity.toString();
    }
  }

  /// -- confirm dialog before entirely removing item from cart --
  void removeItemFromCartDialog(int itemIndex, String itemToRemove) {
    Get.defaultDialog(
      title: 'remove item?',
      middleText: 'are you certain you wish to remove this item from the cart?',
      onConfirm: () {
        // perform action to entirely remove this item from the cart
        cartItems.removeAt(itemIndex);
        qtyFieldControllers.removeAt(itemIndex);
        updateCart();

        CPopupSnackBar.customToast(
          message: '$itemToRemove removed from the cart...',
          forInternetConnectivityStatus: false,
        );
        //Get.back();
        Navigator.of(Get.overlayContext!).pop();
      },
      onCancel: () {
        Navigator.of(Get.overlayContext!).pop();
        //Get.back();
      },
    );
  }

  /// -- convert a CInventoryModel to a CCartItemModel --
  CCartItemModel convertInvToCartItem(CInventoryModel item, int quantity) {
    return CCartItemModel(
      email: item.userEmail,
      productId: item.productId!,
      pCode: item.pCode,
      pName: item.name,
      quantity: quantity,
      availableStockQty: item.quantity,
      price: item.unitSellingPrice,
    );
  }

  /// -- update cart content --
  Future updateCart() async {
    updateCartTotals();
    saveCartItems();
    cartItems.refresh();
    fetchCartItems();
  }

  /// -- update cart totals --
  void updateCartTotals() {
    double computedTotalCartPrice = 0.0;
    int computedCartItemsCount = 0;

    if (cartItems.isNotEmpty) {
      for (var item in cartItems) {
        computedTotalCartPrice += (item.price) * item.quantity.toDouble();
        computedCartItemsCount += item.quantity;
      }

      countOfCartItems.value = computedCartItemsCount;
      totalCartPrice.value = computedTotalCartPrice;
      //txnTotals.value = totalCartPrice.value;
    } else {
      countOfCartItems.value = 0;
      totalCartPrice.value = 0.0;
      //txnTotals.value = 0.0;
    }
  }

  /// -- save cart items to device storage --
  void saveCartItems() async {
    final cartItemsStrings = cartItems.map((item) => item.toJson()).toList();
    //await CLocalStorage.instance().writeData('cartItems', cartItemsStrings);
    CLocalStorage.instance().writeData('cartItems', cartItemsStrings);
    //await localStorage.write('cartItems', cartItemsStrings);
  }

  /// -- get a specific item's quantity in the cart --
  int getItemQtyInCart(int pId) {
    final foundCartItemQty = cartItems
        .where((item) => item.productId == pId)
        .fold(0, (previousValue, element) => previousValue + element.quantity);

    return foundCartItemQty;
  }

  /// -- clear cart content --
  void clearCart() {
    itemQtyInCart.value = 0;
    countOfCartItems.value = 0;
    totalCartPrice.value = 0.0;
    cartItems.clear();
    updateCart();
  }

  /// -- initialize quantity of inventory item in the cart --
  void initializeItemCountInCart(CInventoryModel invItem) async {
    await Future.delayed(Duration.zero);
    itemQtyInCart.value = getItemQtyInCart(invItem.productId!);
  }

  @override
  void dispose() {
    for (var controller in qtyFieldControllers) {
      controller.dispose();
    }
    qtyFieldControllers.clear();
    qtyFieldControllers.close();

    if (kDebugMode) {
      print("----------\n\n TextEditingControllers DISPOSED \n\n ----------");
    }

    super.dispose();
  }
}
