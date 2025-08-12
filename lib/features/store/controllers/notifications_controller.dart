import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/main.dart';
import 'package:get/get.dart';

class CNotificationsController extends GetxController {
  static CNotificationsController get instance => Get.find();

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened

    final navController = Get.put(CNavMenuController());

    navController.selectedIndex.value = 4;
    globalNavigatorKey.currentState?.pushNamedAndRemoveUntil('/landing_screen',
        (route) => (route.settings.name != '/landing_screen') || route.isFirst,
        arguments: receivedAction);
  }

  void notify() async {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        actionType: ActionType.Default,
        body: 'noma sana!',
        channelKey: 'basic_channel',
        displayOnBackground: true,
        displayOnForeground: true,
        fullScreenIntent: true,
        id: 0,
        title: 'noma',
        wakeUpScreen: true,
      ),
    );
  }
}
