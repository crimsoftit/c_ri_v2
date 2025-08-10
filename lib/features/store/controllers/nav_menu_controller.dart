import 'package:c_ri/features/personalization/screens/profile/profile.dart';
import 'package:c_ri/features/personalization/screens/settings/user_settings_screen.dart';
import 'package:c_ri/features/personalization/screens/settings/user_settings_screen_raw.dart';
import 'package:c_ri/features/store/screens/home/home.dart';
import 'package:c_ri/features/store/screens/store_items_tings/store_screen.dart';
import 'package:c_ri/features/store/screens/txns/txns_screen.dart';
import 'package:get/get.dart';

class CNavMenuController extends GetxController {
  static CNavMenuController get instance => Get.find();

  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const HomeScreen(),
    //const HomeScreenRaw(),
    const CStoreScreen(),
    //const CStoreItemsScreen(),
    //const CInventoryScreen(),

    // const CSalesScreen(),

    const CTxnsScreen(),
    //const CCheckoutScreenRaw(),
    const CUserSettingsScreen(),
    const SettingsScreenRaw(),
    const ProfileScreen(),
  ];
}
