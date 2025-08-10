import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/models/payment_method_model.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CPaymentMethodsTile extends StatelessWidget {
  const CPaymentMethodsTile({
    super.key,
    required this.paymentMethod,
  });

  /// -- variables --
  final CPaymentMethodModel paymentMethod;

  @override
  Widget build(BuildContext context) {
    final checkoutController = Get.put(CCheckoutController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      onTap: () {
        checkoutController.selectedPaymentMethod.value = paymentMethod;
        // if (paymentMethod.platformName != 'cash') {
        //   checkoutController.amtIssuedFieldController.text = '';
        //   checkoutController.amtIssuedFieldController.dispose();

        //   checkoutController.customerNameFieldController =
        //       TextEditingController(
        //     text: '',
        //   );
        // } else {
        //   checkoutController.amtIssuedFieldController = TextEditingController(
        //     text: '',
        //   );
        //   checkoutController.customerNameFieldController.text = '';
        //   checkoutController.customerNameFieldController.dispose();
        // }
        
        Navigator.pop(context);
      },
      leading: CRoundedContainer(
        width: 60.0,
        height: 40.0,
        padding: const EdgeInsets.all(
          CSizes.sm,
        ),
        bgColor:
            isDarkTheme ? CColors.rBrown.withValues(alpha: 0.2) : CColors.white,
        child: Image(
          image: AssetImage(paymentMethod.platformLogo),
          fit: BoxFit.contain,
        ),
      ),
      title: Text(
        paymentMethod.platformName,
      ),
      trailing: const Icon(
        Iconsax.arrow_right_34,
      ),
    );
  }
}
