import 'package:c_ri/features/authentication/screens/login/login.dart';
import 'package:c_ri/features/authentication/screens/onboarding/onboarding_screen.dart';
import 'package:c_ri/features/authentication/screens/pswd_config/forgot_password.dart';
import 'package:c_ri/features/authentication/screens/signup/signup.dart';
import 'package:c_ri/features/authentication/screens/signup/verify_email.dart';
import 'package:c_ri/features/personalization/screens/profile/profile.dart';
import 'package:c_ri/features/personalization/screens/settings/user_settings_screen.dart';
import 'package:c_ri/features/personalization/screens/settings/user_settings_screen_raw.dart';
import 'package:c_ri/features/store/screens/home/home.dart';
import 'package:c_ri/features/store/screens/home/home_raw.dart';
import 'package:c_ri/features/store/screens/store_items_tings/checkout/checkout_screen.dart';
import 'package:c_ri/features/store/screens/store_items_tings/inventory/inventory_details/inv_details.dart';
import 'package:c_ri/features/store/screens/store_items_tings/store_items_screen.dart';
import 'package:c_ri/features/store/screens/store_items_tings/store_screen.dart';
import 'package:c_ri/features/store/screens/txns/sales_screen.dart';
import 'package:c_ri/features/store/screens/txns/txn_details/sold_item_details.dart';
import 'package:c_ri/features/store/screens/txns/txn_details/txn_details_revamp_pending.dart';
import 'package:c_ri/features/store/screens/search/search_results.dart';
import 'package:c_ri/features/store/screens/txns/sell_item_screen/sell_item_screen.dart';
import 'package:c_ri/features/store/screens/txns/txns_screen.dart';
import 'package:get/get.dart';

import 'routes.dart';

class CAppRoutes {
  static final pages = [
    GetPage(
      name: CRoutes.home,
      page: () => const HomeScreen(),
    ),
    GetPage(
      name: CRoutes.homeRaw,
      page: () => const HomeScreenRaw(),
    ),
    GetPage(
      name: CRoutes.store,
      page: () => const CStoreScreen(),
    ),
    GetPage(
      name: CRoutes.storeItems,
      page: () => const CStoreItemsScreen(),
    ),
    // GetPage(
    //   name: CRoutes.inventory,
    //   page: () => const CInventoryScreen(),
    // ),
    GetPage(
      name: CRoutes.inventoryDetails,
      page: () => const CInvDetails(),
    ),
    GetPage(
      name: CRoutes.sales,
      page: () => const CSalesScreen(),
    ),

    GetPage(
      name: CRoutes.txns,
      page: () => const CTxnsScreen(),
    ),
    GetPage(
      name: CRoutes.sellItemScreen,
      page: () => const CSellItemScreen(),
    ),
    GetPage(
      name: CRoutes.soldItemDetailsScreen,
      page: () => const CSoldItemDetailsScreen(),
    ),
    GetPage(
      name: CRoutes.txnDetailsScreen,
      page: () => const CTxnDetailsScreen(),
    ),
    GetPage(
      name: CRoutes.checkoutScreen,
      page: () => const CCheckoutScreen(),
    ),
    GetPage(
      name: CRoutes.settings,
      page: () => const CUserSettingsScreen(),
    ),
    GetPage(
      name: CRoutes.settingsScreenRaw,
      page: () => const SettingsScreenRaw(),
    ),
    GetPage(
      name: CRoutes.userProfile,
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: CRoutes.signup,
      page: () => const SignupScreen(),
    ),
    GetPage(
      name: CRoutes.verifyEmail,
      page: () => const VerifyEmailScreen(),
    ),
    GetPage(
      name: CRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: CRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
    ),
    GetPage(
      name: CRoutes.onBoarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: CRoutes.searchResults,
      page: () => const CSearchResultsScreen(),
    ),
  ];
}
