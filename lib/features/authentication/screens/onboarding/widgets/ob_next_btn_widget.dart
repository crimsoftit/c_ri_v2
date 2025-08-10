import 'package:c_ri/features/authentication/controllers/onboarding/ob_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/device/device_utilities.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class OnboardingNextBtnWidget extends StatelessWidget {
  const OnboardingNextBtnWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final obController = OnboardingController.instance;

    return Positioned(
      right: CSizes.defaultSpace,
      bottom: CDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () {
          obController.nextPage();
        },
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
        ),
        child: Icon(
          Iconsax.arrow_right_3,
          color: CColors.white,
        ),
      ),
    );
  }
}
