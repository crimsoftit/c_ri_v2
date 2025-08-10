import 'package:c_ri/features/authentication/controllers/signup/signup_controller.dart';
import 'package:c_ri/features/authentication/screens/signup/widgets/t_and_c_checkbox.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/constants/txt_strings.dart';
import 'package:c_ri/utils/validators/validation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RSignupForm extends StatelessWidget {
  const RSignupForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final signupController = Get.put(SignupController());
    FocusNode focusNode = FocusNode();
    return Form(
      key: signupController.signupFormKey,
      child: Column(
        children: [
          // -- full name field --
          TextFormField(
            controller: signupController.fullName,
            expands: false,
            style: const TextStyle(
              height: 0.7,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.user),
              labelText: 'full name',
            ),
            validator: (value) => CValidator.validateName('full name', value),
          ),

          const SizedBox(
            height: CSizes.spaceBtnInputFields,
          ),

          // -- email field --
          TextFormField(
            controller: signupController.txtBusinessName,
            style: const TextStyle(
              height: 0.7,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.buildings),
              labelText: 'business name',
            ),
            validator: (value) =>
                CValidator.validateName('business name', value),
          ),

          const SizedBox(
            height: CSizes.spaceBtnInputFields,
          ),

          // -- email field --
          TextFormField(
            controller: signupController.email,
            style: const TextStyle(
              height: 0.7,
            ),
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.direct),
              labelText: CTexts.email,
            ),
            validator: (value) => CValidator.validateEmail(value),
          ),

          const SizedBox(
            height: CSizes.spaceBtnInputFields,
          ),

          // -- phone number field --
          IntlPhoneField(
            controller: signupController.phoneNumber,
            initialCountryCode: 'KE',
            focusNode: focusNode,
            dropdownTextStyle: const TextStyle(
              fontSize: 10,
              fontFamily: 'Poppins',
              height: 0.8,
            ),
            decoration: const InputDecoration(
              counterText: '',
              label: Text('Phone number'),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.0,
                  color: CColors.rBrown,
                ),
              ),
            ),
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Poppins',
              height: 0.8,
            ),
            keyboardType: TextInputType.phone,
            languageCode: "en",
            onChanged: (phone) {
              signupController.completePhoneNo.value = phone.completeNumber;
            },
            onCountryChanged: (country) {
              signupController.countryCode.value = country.code;

              if (kDebugMode) print('country changed to: ${country.dialCode}');

              signupController.onPhoneInputChanged(country);
            },
            validator: (value) =>
                CValidator.validatePhoneNumber(value.toString()),
          ),

          const SizedBox(
            height: CSizes.spaceBtnInputFields,
          ),

          // -- password field --
          Obx(
            () => TextFormField(
              controller: signupController.password,
              obscureText: signupController.hidePswdTxt.value,
              style: const TextStyle(
                height: 0.7,
              ),
              decoration: InputDecoration(
                labelText: CTexts.password,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () {
                    signupController.hidePswdTxt.value =
                        !signupController.hidePswdTxt.value;
                  },
                  icon: Icon(
                    signupController.hidePswdTxt.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    color: signupController.hidePswdTxt.value
                        ? CColors.grey
                        : CColors.rBrown,
                  ),
                ),
              ),
              validator: (value) => CValidator.validatePassword(value),
            ),
          ),

          const SizedBox(
            height: CSizes.spaceBtnInputFields,
          ),

          // -- confirm password field --
          Obx(
            () => TextFormField(
              controller: signupController.confirmPassword,
              obscureText: signupController.hideConfirmPswdTxt.value,
              style: const TextStyle(
                height: 0.7,
              ),
              decoration: InputDecoration(
                labelText: 're-type password',
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () {
                    signupController.hideConfirmPswdTxt.value =
                        !signupController.hideConfirmPswdTxt.value;
                  },
                  icon: Icon(
                    signupController.hideConfirmPswdTxt.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    color: signupController.hideConfirmPswdTxt.value
                        ? CColors.grey
                        : CColors.rBrown,
                  ),
                ),
              ),
              validator: (value) => CValidator.validateConfirmPassword(
                  signupController.password.text, value),
            ),
          ),

          const SizedBox(
            height: CSizes.spaceBtnSections,
          ),

          // -- terms & conditions checkbox --
          const TandCCheckbox(),

          const SizedBox(
            height: CSizes.spaceBtnSections,
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                //Get.to(() => const VerifyEmailScreen());
                // CPopupSnackBar.customToast(
                //   message: 'message',
                //   forInternetConnectivityStatus: false,
                // );
                signupController.signup();
              },
              child: Text(
                CTexts.createAccount.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium?.apply(
                      color: CColors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
