import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class NavMenu extends StatelessWidget {
  const NavMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CCartController());
    final isDark = CHelperFunctions.isDarkMode(context);
    final invController = Get.put(CInventoryController());

    final navController = Get.put(CNavMenuController());

    Get.put(CInventoryController());
    Get.put(CCartController());

    // invController.onInit();
    // cartController.fetchCartItems();

    GlobalKey navBarGlobalKey = GlobalKey(debugLabel: 'bottomAppBar');

    return Obx(
      () {
        if (invController.inventoryItems.isEmpty &&
            !invController.isLoading.value) {
          invController.onInit();
        }

        if (cartController.cartItems.isEmpty &&
            !cartController.cartItemsLoading.value) {
          cartController.fetchCartItems();
        }

        return Scaffold(
          bottomNavigationBar: NavigationBar(
            key: navBarGlobalKey,
            height: 80.0,
            elevation: 0,
            selectedIndex: navController.selectedIndex.value,
            onDestinationSelected: (index) {
              navController.selectedIndex.value = index;
            },
            backgroundColor: isDark
                ? CNetworkManager.instance.hasConnection.value
                    ? CColors.rBrown
                    : CColors.black
                : CNetworkManager.instance.hasConnection.value
                    ? CColors.rBrown.withValues(alpha: 0.1)
                    : CColors.black.withValues(alpha: 0.1),
            indicatorColor: isDark
                ? CColors.white.withValues(alpha: 0.3)
                : CNetworkManager.instance.hasConnection.value
                    ? CColors.rBrown.withValues(alpha: 0.3)
                    : CColors.black.withValues(alpha: 0.3),
            destinations: const [
              NavigationDestination(
                icon: Icon(
                  Iconsax.home,
                ),
                label: 'home',
              ),
              // NavigationDestination(
              //   icon: Icon(
              //     Iconsax.home,
              //   ),
              //   label: 'homeRaw',
              // ),
              NavigationDestination(
                icon: Icon(
                  Iconsax.shop,
                ),
                label: 'store',
              ),
              // NavigationDestination(
              //   icon: Icon(Iconsax.shop),
              //   label: 'store items',
              // ),
              // NavigationDestination(
              //   icon: Icon(Iconsax.card_tick),
              //   label: 'inventory',
              // ),

              // NavigationDestination(
              //   icon: Icon(Iconsax.empty_wallet_time),
              //   label: 'sales_raw',
              // ),
              NavigationDestination(
                icon: Icon(Iconsax.wallet_check),
                label: 'txns',
              ),

              NavigationDestination(
                icon: Icon(Iconsax.setting),
                label: 'account',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.wallet_check),
                label: 'ac raw',
              ),
              NavigationDestination(
                icon: Icon(Iconsax.user),
                label: 'profile',
              ),
            ],
          ),
          body: navController.screens[navController.selectedIndex.value],
        );
      },
    );
  }
}
