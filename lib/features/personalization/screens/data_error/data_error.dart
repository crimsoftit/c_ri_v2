import 'package:c_ri/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DataErrorScreen extends StatelessWidget {
  const DataErrorScreen({
    super.key,
    required this.lottieImage,
    required this.txt,
  });

  final String lottieImage, txt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // -- image --
            Lottie.asset(
              lottieImage,
              width: 130,
              height: 130,
            ),

            const SizedBox(
              height: CSizes.spaceBtnSections / 8,
            ),

            // -- text --
            Text(
              txt,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(
              height: CSizes.spaceBtnSections / 8,
            ),
          ],
        ),
      ),
    );
  }
}
