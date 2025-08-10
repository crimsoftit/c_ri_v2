import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/constants/txt_strings.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    //final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sign in...',
                style: Theme.of(context).textTheme.labelLarge!.apply(
                      color: CNetworkManager.instance.hasConnection.value
                          ? CColors.rBrown
                          : CColors.darkGrey,
                      fontSizeFactor: 2.5,
                      fontWeightDelta: -7,
                    ),
              ),
              const SizedBox(
                //width: double.infinity,
                child: Image(
                  height: 40.0,
                  //image: AssetImage( isDark ? RImages.darkAppLogo_1 : RImages.lightAppLogo_1),
                  // image: AssetImage(
                  //   isDarkTheme ? CImages.darkAppLogo : CImages.lightAppLogo,
                  // ),
                  image: AssetImage(
                    CImages.darkAppLogo,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: CSizes.spaceBtnSections * 1.8,
          ),
          Text(
            CTexts.loginTitle,
            style: Theme.of(context).textTheme.headlineMedium!.apply(
                  color: CNetworkManager.instance.hasConnection.value
                      ? CColors.rBrown
                      : CColors.darkGrey,
                ),
          ),
          const SizedBox(
            height: CSizes.sm,
          ),
          Text(
            CTexts.loginSubTitle,
            style: Theme.of(context).textTheme.labelSmall!.apply(
                  color: CNetworkManager.instance.hasConnection.value
                      ? CColors.rBrown
                      : CColors.darkGrey,
                ),
          ),
        ],
      ),
    );
  }
}
