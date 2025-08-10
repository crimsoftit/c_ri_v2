import 'package:c_ri/features/authentication/controllers/onboarding/ob_controller.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/device/device_utilities.dart';
import 'package:flutter/material.dart';

class OnboardingSkipBtnWidget extends StatelessWidget {
  const OnboardingSkipBtnWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: CDeviceUtils.getAppBarHeight(),
      right: CSizes.defaultSpace,
      child: TextButton(
        onPressed: () {
          OnboardingController.instance.skipPage();
        },
        child: Text(
          'skip',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
