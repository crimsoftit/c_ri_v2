import 'dart:async';

import 'package:c_ri/data/repos/user/user_repo.dart';
import 'package:c_ri/features/authentication/controllers/signup/signup_controller.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/personalization/models/user_model.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';

class CLocationController extends GetxController {
  // -- variables --
  final RxBool processingLocationAccess = RxBool(false);
  final RxBool updateLoading = RxBool(false);
  final RxString errorDesc = ''.obs;
  final Rx<LocationData?> userLocation = Rx<LocationData?>(null);
  final RxString uAddress = RxString('');
  final RxString uCountry = RxString('');
  final RxString uCurCode = RxString('');

  final signupController = Get.put(SignupController());
  final userController = Get.put(CUserController());
  final userRepo = Get.put(CUserRepo());

  late StreamSubscription<ServiceStatus> serviceStatusStream;

  // -- initialize the network manager and set up a stream to continually check the connection status --

  void updateLocationAccess(bool hasAccess) {
    processingLocationAccess.value = hasAccess;
  }

  void updateUserLocation(LocationData locationData) {
    userLocation.value = locationData;
  }

  fetchUserCurrencyByCountry(String uCountry) {
    // -- load user's currency code --
    signupController.fetchUserCurrencyByCountry(uCountry);
    uCurCode.value = signupController.userCurrencyCode.value;
  }

  Future<void> updateUserSettings() async {
    try {
      updateLoading.value = true;
      var updatedUser = CUserModel(
        id: userController.user.value.id,
        fullName: userController.user.value.fullName,
        businessName: userController.user.value.businessName,
        email: userController.user.value.email,
        countryCode: userController.user.value.countryCode,
        phoneNo: userController.user.value.phoneNo,
        currencyCode: uCurCode.value,
        profPic: userController.user.value.profPic,
        locationCoordinates:
            'lat: ${userLocation.value!.latitude}, long: ${userLocation.value!.longitude}',
        userAddress: uAddress.value,
      );

      userRepo.updateUserDetails(updatedUser);
      //AuthRepo.instance.screenRedirect();
    } catch (e) {
      updateLoading.value = false;
      CPopupSnackBar.errorSnackBar(
        title: "An error occurred",
        message: e.toString(),
      );
      throw 'error updating user details! please try again!';
    } finally {
      updateLoading.value = false;
    }
  }
}
