import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:c_ri/features/store/controllers/notifications_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CNotificationsScreen extends StatefulWidget {
  const CNotificationsScreen({super.key});

  @override
  State<CNotificationsScreen> createState() => _CNotificationsScreenState();
}

class _CNotificationsScreenState extends State<CNotificationsScreen> {
  @override
  void initState() {
    // Only after at least the action method is set, the notification events are delivered
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: CNotificationsController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            CNotificationsController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            CNotificationsController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            CNotificationsController.onDismissActionReceivedMethod);

    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final notsController = Get.put(CNotificationsController());

    return Container(
      color: isDarkTheme ? CColors.transparent : CColors.white,
      child: Scaffold(
        appBar: AppBar(
          title: Text('notifications'),
        ),
        backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () {
                    notsController.notify();
                  },
                  child: Text(
                    'instant notifications',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
