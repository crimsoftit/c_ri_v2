import 'package:c_ri/features/personalization/screens/no_data/no_data_screen.dart';
import 'package:c_ri/features/personalization/controllers/notifications_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CAlertsListView extends StatelessWidget {
  const CAlertsListView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final notsController = Get.put(CNotificationsController());

    var items = notsController.allNotifications;

    return Obx(
      () {
        notsController.fetchUserNotifications();

        if (items.isEmpty) {
          return const Center(
            child: NoDataScreen(
              lottieImage: CImages.noDataLottie,
              txt: 'no notifications as yet!!',
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(
            CSizes.borderRadiusLg,
          ),
          child: ListView.separated(
            itemCount: items.length,
            itemBuilder: (_, index) {
              // -- widget for no notifications --
              // if (items.isEmpty && !notsController.isLoading.value) {
              //   return const Center(
              //     child: NoDataScreen(
              //       lottieImage: CImages.noDataLottie,
              //       txt: 'no notifications yet',
              //     ),
              //   );
              // }
              return Card(
                color: isDarkTheme
                    ? CColors.rBrown.withValues(alpha: 0.3)
                    : CColors.lightGrey,
                margin: EdgeInsets.all(
                  1,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        CNetworkManager.instance.hasConnection.value
                            ? CColors.rBrown.withValues(
                                alpha: .3,
                              )
                            : CColors.darkerGrey,
                    radius: 15.0,
                    child: Icon(
                      color: CNetworkManager.instance.hasConnection.value
                          ? CColors.grey
                          : CColors.rBrown,
                      items[index].productId!.isGreaterThan(10)
                          ? Iconsax.information
                          : Iconsax.user,
                      size: CSizes.iconSm,
                    ),
                    // Text(
                    //   '${index + 1}',
                    //   style: Theme.of(context).textTheme.labelMedium!.apply(
                    //         color: CColors.grey,
                    //       ),
                    // ),
                  ),
                  //isThreeLine: true,
                  title: Text(
                    items[index].notificationTitle,
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          color:
                              isDarkTheme ? CColors.darkGrey : CColors.rBrown,
                        ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// -- alert message (subtitle, body) --
                      Text(
                        items[index].notificationBody,
                        style: Theme.of(context).textTheme.labelMedium!.apply(
                              color: isDarkTheme
                                  ? CColors.darkGrey
                                  : CColors.rBrown,
                            ),
                      ),

                      /// -- other alert item details... --
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .apply(
                                    color: isDarkTheme
                                        ? CColors.darkGrey
                                        : CColors.rBrown,
                                  ),
                              text:
                                  'notified: ${items[index].alertCreated}; isRead: ${items[index].notificationIsRead} ',
                            ),
                            TextSpan(
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .apply(
                                    color: isDarkTheme
                                        ? CColors.darkGrey
                                        : CColors.rBrown,
                                  ),
                              // text:
                              //     'user: ${items[index].userEmail}; pId: ${items[index].productId! > 100 ? items[index].productId : 'N/A'} ',
                              text:
                                  'user: ${items[index].userEmail}; pId: ${items[index].productId} ',
                            ),
                          ],
                        ),
                      ),
                      Text(
                        items[index].date,
                        style: Theme.of(context).textTheme.labelSmall!.apply(
                              color: CColors.rBrown,
                            ),
                      ),
                    ],
                  ),

                  // Text(
                  //   items[index].notificationBody,
                  //   style: Theme.of(context).textTheme.labelMedium!.apply(
                  //         color:
                  //             isDarkTheme ? CColors.darkGrey : CColors.rBrown,
                  //         // fontWeightDelta:
                  //         //     items[index].notificationIsRead == 0
                  //         //         ? 2
                  //         //         : 0,
                  //       ),
                  // ),

                  trailing: InkWell(
                    onTap: () {
                      notsController.onDeleteBtnPressed(items[index]);
                    },
                    child: Icon(
                      Icons.close,
                      color: CNetworkManager.instance.hasConnection.value
                          ? CColors.rBrown
                          : CColors.darkerGrey,
                      size: CSizes.iconSm,
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) {
              return SizedBox(
                height: CSizes.spaceBtnSections / 8,
              );
            },
            shrinkWrap: true,
          ),
        );
      },
    );
  }
}
