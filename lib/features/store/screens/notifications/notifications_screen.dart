import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:c_ri/common/widgets/appbar/v2_app_bar.dart';
import 'package:c_ri/common/widgets/divider/c_divider.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/notifications_controller.dart';
import 'package:c_ri/features/store/models/notifications_model.dart';
import 'package:c_ri/features/store/screens/notifications/widgets/alerts_listview.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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
    final userController = Get.put(CUserController());

    return Container(
      color: isDarkTheme ? CColors.transparent : CColors.white,
      child: Scaffold(
        /// -- app bar --
        appBar: CVersion2AppBar(
          autoImplyLeading: true,
        ),
        backgroundColor: CColors.rBrown.withValues(
          alpha: 0.2,
        ),

        /// -- body --
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 15.0,
              top: 10.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userController.user.value.email,
                          style: Theme.of(context).textTheme.labelSmall!.apply(
                                color:
                                    CNetworkManager.instance.hasConnection.value
                                        ? CColors.rBrown
                                        : CColors.darkGrey,
                              ),
                        ),
                        Text(
                          'Alerts',
                          style: Theme.of(context).textTheme.labelLarge!.apply(
                                color:
                                    CNetworkManager.instance.hasConnection.value
                                        ? CColors.rBrown
                                        : CColors.darkGrey,
                                fontSizeFactor: 2.5,
                                fontWeightDelta: -7,
                              ),
                        ),
                        CDivider(
                          endIndent: 250.0,
                          startIndent: 0,
                        ),
                      ],
                    );
                  },
                ),

                // -- list notifications on an ExpansionPanelList.radio widget --
                CAlertsListView(),
                FilledButton(
                  onPressed: () {
                    var notification = CNotificationsModel(
                      0,
                      'noma',
                      'noma sana!!',
                      0,
                      17564321,
                      userController.user.value.email,
                      DateFormat('yyyy-MM-dd @ kk:mm').format(clock.now()),
                    );
                    notsController.saveAndOrTriggerNotification(
                      notification,
                      1,
                      notification.notificationTitle,
                      notification.notificationBody,
                      true,
                    );
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
