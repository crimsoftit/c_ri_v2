import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CPaymentMethodSection extends StatelessWidget {
  const CPaymentMethodSection({
    super.key,
    required this.platformName,
    required this.platformLogo,
    required this.txtFieldSpace,
  });

  final String platformName, platformLogo;
  final Widget txtFieldSpace;

  @override
  Widget build(BuildContext context) {
    //final cartController = Get.put(CCartController());
    final checkoutController = Get.put(CCheckoutController());
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Column(
      children: [
        CSectionHeading(
          showActionBtn: true,
          title: 'payment method',
          btnTitle: 'change',
          btnTxtColor: CColors.darkerGrey,
          editFontSize: true,
          fSize: 13.0,
          onPressed: () {
            checkoutController.amtIssuedFieldController.text = '';
            checkoutController.customerBal.value = 0.0;
            checkoutController.selectPaymentMethod(context);
          },
        ),
        SizedBox(
          height: CSizes.spaceBtnItems / 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CRoundedContainer(
              width: 60.0,
              height: 45.0,
              bgColor: isDarkTheme ? CColors.light : CColors.white,
              padding: const EdgeInsets.all(
                CSizes.sm / 4,
              ),
              child: Image(
                image: AssetImage(
                  platformLogo,
                  //checkoutController.selectedPaymentMethod.value.platformLogo,
                ),
                fit: BoxFit.contain,
              ),
            ),
            // const SizedBox(
            //   width: CSizes.spaceBtnItems / 4,
            // ),
            Expanded(
              child: Text(
                //checkoutController.selectedPaymentMethod.value.platformName,
                platformName,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            txtFieldSpace,
          ],
        ),
      ],
    );
  }
}
