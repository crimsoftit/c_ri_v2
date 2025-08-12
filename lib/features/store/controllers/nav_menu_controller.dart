import 'package:c_ri/features/personalization/screens/profile/profile.dart';
import 'package:c_ri/features/personalization/screens/settings/user_settings_screen.dart';
import 'package:c_ri/features/store/screens/home/home.dart';
import 'package:c_ri/features/store/screens/local_notifications/local_notifications_screen.dart';
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

    const CTxnsScreen(),
    //const CCheckoutScreenRaw(),
    const CUserSettingsScreen(),

    //const SettingsScreenRaw(),
    const ProfileScreen(),
    const CLocalNotifications(),
  ];
}
