import 'package:c_ri/common/widgets/appbar/app_bar.dart';
import 'package:c_ri/common/widgets/shimmers/shimmer_effects.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardHeaderWidget extends StatelessWidget {
  const DashboardHeaderWidget({
    super.key,
    required this.actionsSection,
    required this.appBarTitle,
    required this.screenTitle,
    required this.isHomeScreen,
    this.showAppBarTitle = true,
  });

  final Widget actionsSection;
  final String appBarTitle, screenTitle;
  final bool isHomeScreen, showAppBarTitle;

  @override
  Widget build(BuildContext context) {
    //final currentUser = FirebaseAuth.instance.currentUser;
    final userController = Get.put(CUserController());

    return CAppBar(
      showBackArrow: false,
      horizontalPadding: 1.0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          showAppBarTitle
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: 4.0,
                  ),
                  child: Text(
                    //CTexts.homeAppbarTitle,
                    appBarTitle,
                    style: Theme.of(context).textTheme.labelMedium!.apply(
                          color: CColors.darkGrey,
                        ),
                  ),
                )
              : SizedBox(),

          Obx(
            () {
              if (isHomeScreen) {
                if (userController.profileLoading.value) {
                  // -- display a shimmer loader effect while loading user profile
                  return const CShimmerEffect(
                    width: 80.0,
                    height: 15.0,
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3.0,
                    ),
                    child: Text(
                      userController.user.value.businessName == ''
                          ? userController.user.value.fullName
                          : userController.user.value.businessName,
                      style: Theme.of(context).textTheme.labelLarge!.apply(
                            color: CNetworkManager.instance.hasConnection.value
                                ? CColors.rBrown
                                : CColors.darkGrey,
                            fontSizeFactor: 2.5,
                            fontWeightDelta: -7,
                          ),
                    ),
                  );
                }
              }

              return Text(
                screenTitle,
                style: Theme.of(context).textTheme.headlineSmall!.apply(
                      color: CColors.white,
                      fontSizeFactor: 0.7,
                    ),
              );
            },
          ),
          // Text(
          //   userController.user.value.email,
          //   style: Theme.of(context).textTheme.headlineSmall!.apply(
          //         color: CColors.white,
          //         fontSizeFactor: 0.7,
          //       ),
          // ),
        ],
      ),
      actions: [actionsSection],
      backIconAction: () {
        //Get.back();
      },
    );
  }
}
