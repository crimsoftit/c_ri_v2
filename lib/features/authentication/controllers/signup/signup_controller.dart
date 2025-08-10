import 'package:c_ri/common/widgets/loaders/loading_dialog.dart';
import 'package:c_ri/data/repos/auth/auth_repo.dart';
import 'package:c_ri/data/repos/user/user_repo.dart';
import 'package:c_ri/features/authentication/screens/signup/verify_email.dart';
import 'package:c_ri/features/personalization/models/currency_model.dart';
import 'package:c_ri/features/personalization/models/user_model.dart';
import 'package:c_ri/utils/constants/file_strings.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/full_screen_loader.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/countries.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  // -- variables --
  final hidePswdTxt = true.obs;
  RxString countryCode = ''.obs;
  RxString completePhoneNo = ''.obs;
  RxString userCountry = ''.obs;
  RxString userCurrencyCode = ''.obs;
  final checkPrivacyPolicy = false.obs;

  final hideConfirmPswdTxt = true.obs;
  final fullName = TextEditingController();
  final txtBusinessName = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final currencyField = TextEditingController();

  final fullNo = TextEditingController();

  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  final RxList<List<dynamic>> csvContent = <List<dynamic>>[].obs;
  final RxList<CurrencyModel> foundCsvContent = <CurrencyModel>[].obs;
  final RxList<CurrencyModel> currencyItemDetails = <CurrencyModel>[].obs;

  List<CurrencyModel> singleItem = [];

  @override
  void onInit() {
    loadCSV();
    super.onInit();
  }

  void loadCSV() async {
    final rawData = await rootBundle.loadString(CFiles.currenciesCsv);

    List<List<dynamic>> listData = const CsvToListConverter(
      fieldDelimiter: ",",
      textDelimiter: '"',
      allowInvalid: true,
      convertEmptyTo: String,
      eol: '\n',
    ).convert(rawData);

    csvContent.value = listData;

    for (var element in csvContent) {
      foundCsvContent.add(CurrencyModel(
        country: element[0],
        countryCode: element[1],
        curCode: element[3],
      ));
    }
  }

  /// -- fetch user's currency code by country --
  fetchUserCurrencyByCountry(String uCountry) {
    currencyItemDetails.value =
        foundCsvContent.where((item) => item.country == uCountry).toList();

    userCurrencyCode.value = currencyItemDetails.first.curCode.toString();
  }

  // -- firebase signup function --
  void signup() async {
    try {
      // -- start loader
      CFullScreenLoader.openLoadingDialog(
        "we're processing your info...",
        CImages.docerAnimation,
      );

      // -- check internet connectivity
      final isConnected = await CNetworkManager.instance.isConnected();
      if (!isConnected) {
        // -- remove loader
        CFullScreenLoader.stopLoading();
        CPopupSnackBar.customToast(
          message: 'please check your internet connection',
          forInternetConnectivityStatus: false,
        );
        return;
      }

      // -- form validation
      if (!signupFormKey.currentState!.validate()) {
        // -- remove loader
        CFullScreenLoader.stopLoading();
        return;
      }

      // -- privacy policy check
      if (!checkPrivacyPolicy.value) {
        CFullScreenLoader.stopLoading();
        CPopupSnackBar.warningSnackBar(
            title: 'accept privacy policy',
            message:
                'to create an account, you must read and accept the privacy policy & terms of use!');
        return;
      }

      // -- check if phone number exists --
      final phoneNoExists =
          await CUserRepo.instance.checkIfPhoneNoExists(completePhoneNo.value);
      if (phoneNoExists) {
        CFullScreenLoader.stopLoading();
        CPopupSnackBar.warningSnackBar(
          title: 'phone no. exists!',
          message: 'the supplied phone no. is already in use!',
        );
        return;
      }

      // -- register user implementing Firebase Authentication & save user data in the Firebase database
      final userCredentials =
          await AuthRepo.instance.signupWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // -- save user data in the Firestore database

      final newUser = CUserModel(
        id: userCredentials.user!.uid,
        fullName: fullName.text,
        businessName: txtBusinessName.text,
        email: email.text.trim(),
        countryCode: countryCode.value,
        // phoneNo: phoneNumber.text.trim(),
        phoneNo: completePhoneNo.value,
        currencyCode: userCurrencyCode.value,
        profPic: '',
        locationCoordinates: '',
        userAddress: '',
      );

      final userRepo = Get.put(CUserRepo());

      await userRepo.saveUserDetails(newUser);

      // -- remove loader
      CFullScreenLoader.stopLoading();

      // -- show signup success message
      CPopupSnackBar.successSnackBar(
        title: 'ngrats!',
        message:
            'your account has been created! verify your e-mail address to proceed!',
      );

      // -- move to verify email screen
      Get.to(() => VerifyEmailScreen(
            email: email.text.trim(),
          ));
    } catch (e) {
      // -- remove loader --
      CLoadingDialog.hideLoader();
      // -- show some generic error msg to the user
      CPopupSnackBar.errorSnackBar(
        title: 'Oh Snap!',
        message: e.toString(),
      );
      // -- remove loader --
      CLoadingDialog.hideLoader();
      return;
    }
  }

  onPhoneInputChanged(Country country) {
    userCountry.value = country.name;
    loadCSV();

    fetchUserCurrencyByCountry(userCountry.value);
  }
}
