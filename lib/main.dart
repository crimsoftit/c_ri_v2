import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:c_ri/api/sheets/store_sheets_api.dart';
import 'package:c_ri/app.dart';
import 'package:c_ri/data/repos/auth/auth_repo.dart';
import 'package:c_ri/firebase_options.dart';
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

  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true);

  // AwesomeNotifications().initialize(
  //   null,
  //   [
  //     NotificationChannel(
  //       channelGroupKey: 'basic_channel_group',
  //       channelKey: 'key1',
  //       channelName: 'channelName',
  //       channelDescription: 'channelDescription',
  //       defaultColor: Color(0XFF9050DD),
  //       enableLights: true,
  //       enableVibration: true,
  //       ledColor: CColors.white,
  //       playSound: true,
  //       //soundSource: '',
  //     )
  //   ],
  //   channelGroups: [
  //     NotificationChannelGroup(
  //       channelGroupKey: 'channelGroupKey',
  //       channelGroupName: 'channelGroupName',
  //     ),
  //   ],
  //   debug: true,
  // );

  /// -- todo: init local storage (GetX Local Storage) --
  await GetStorage.init();

  /// -- initialize spreadsheets --
  await StoreSheetsApi.initSpreadSheets();

  tz.initializeTimeZones();

  /// -- todo: await native splash --
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  /// -- todo: load all the material design, themes, localizations, bindings, etc. --
  runApp(const App());
}
