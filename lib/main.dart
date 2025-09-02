import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:c_ri/api/sheets/store_sheets_api.dart';
import 'package:c_ri/app.dart';
import 'package:c_ri/data/repos/auth/auth_repo.dart';
import 'package:c_ri/firebase_options.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest.dart' as tz;

final globalNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  /// -- todo: add widgets binding --
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  /// -- todo: initialize firebase --
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) => Get.put(AuthRepo()));

  /// -- initialize spreadsheets --
  await StoreSheetsApi.initSpreadSheets();

  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: CColors.rBrown,
          enableLights: true,
          enableVibration: true,
          ledColor: CColors.rBrown,
        )
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);

  /// -- todo: init local storage (GetX Local Storage) --
  await GetStorage.init();

  tz.initializeTimeZones();

  /// -- todo: await native splash --
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- todo: load all the material design, themes, localizations, bindings, etc. --
  runApp(const App());
}
