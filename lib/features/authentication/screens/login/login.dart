import 'package:c_ri/common/widgets/appbar/app_bar.dart';
import 'package:c_ri/common/widgets/login_signup/form_divider.dart';
import 'package:c_ri/common/widgets/login_signup/social_buttons.dart';
import 'package:c_ri/features/authentication/screens/login/widgets/login_form.dart';
import 'package:c_ri/features/authentication/screens/login/widgets/login_header.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/constants/txt_strings.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Scaffold(
      appBar: CAppBar(
        backIconAction: () {
          SystemNavigator.pop();
        },
        // backIconColor: isDarkTheme ? CColors.white : CColors.rBrown,
        backIconColor: CColors.rBrown,
        // bgColor: CNetworkManager.instance.hasConnection.value
        //     ? CColors.rBrown.withValues(
        //         alpha: 0.3,
        //       )
        //     : CColors.black.withValues(
        //         alpha: 0.3,
        //       ),
        horizontalPadding: 0.0,
      ),
      backgroundColor: isDarkTheme
          ? CColors.rBrown.withValues(alpha: 0.2)
          : CColors.lightGrey,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(
            CSizes.defaultSpace,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- logo, title, and subtitle --
              const LoginHeader(),

              // -- login form --
              const LoginForm(),

              // -- divider --
              CFormDivider(
                dividerText: CTexts.orSignInWith.capitalize!,
              ),
              const SizedBox(
                height: CSizes.spaceBtnSections,
              ),

              // -- footer --
              const CSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
