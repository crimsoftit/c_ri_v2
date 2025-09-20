import 'package:c_ri/common/widgets/appbar/app_bar.dart';
import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/headers/app_header.dart';
import 'package:c_ri/common/widgets/login_signup/form_divider.dart';
import 'package:c_ri/features/authentication/screens/login/login.dart';
import 'package:c_ri/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/constants/txt_strings.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return CRoundedContainer(
      bgColor: isDarkTheme ? CColors.transparent : CColors.white,
      borderRadius: 0,
      showBorder: false,
      child: Scaffold(
        appBar: CAppBar(
          backIconAction: () {
            SystemNavigator.pop();
          },
          backIconColor: CColors.rBrown,
          horizontalPadding: 0.0,
          showBackArrow: true,
        ),
        backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(
              CSizes.defaultSpace,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- logo, title, and subtitle --
                const AppScreenHeader(
                  includeAfterSpace: true,
                  subTitle: 'excited to have you!',
                  title: 'sign up...',
                ),
                // const SizedBox(
                //   height: CSizes.spaceBtnSections / 4,
                // ),

                // -- divider --
                // const CFormDivider(
                //   dividerText: 'already have an account?',
                // ),

                // const SizedBox(
                //   height: CSizes.spaceBtnSections / 4,
                // ),

                // -- signup form --
                const CSignupForm(),

                // -- divider --
                CFormDivider(
                  dividerText: 'already have an account?'.capitalize!,
                ),
                const SizedBox(
                  height: CSizes.spaceBtnSections / 2,
                ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.offAll(const LoginScreen());
                    },
                    child: Text(
                      CTexts.signIn.toUpperCase(),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
                // TextButton(
                //   onPressed: () {
                //     Get.offAll(const LoginScreen());
                //   },
                //   child: Text(
                //     'click here to sign in',
                //     style: Theme.of(context).textTheme.bodySmall!.apply(
                //           color: isDarkTheme ? CColors.grey : CColors.rBrown,
                //         ),
                //     textAlign: TextAlign.left,
                //   ),
                // ),

                // -- footer --
                //const CSocialButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
