import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart';

class CLocalNotsController extends GetxController {
  static CLocalNotsController get instance => Get.find();

  /// -- variables --
  static final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void onInit() {
    initLocalNotifications();
    super.onInit();
  }

  /// -- function to initialize local notifications --
  static Future<void> initLocalNotifications() async {
    tz.initializeTimeZones();

    setLocalLocation(
      getLocation('America/Detroit'),
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notificationsPlugin.initialize(initializationSettings);
  }
}
