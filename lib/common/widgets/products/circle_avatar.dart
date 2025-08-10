import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CCircleAvatar extends StatelessWidget {
  const CCircleAvatar({
    super.key,
    this.bgColor = CColors.rBrown,
    this.includeEditBtn = false,
    this.onEdit,
    this.txtColor = CColors.white,
    this.radius = 16.0,
    required this.avatarInitial,
  });

  final bool includeEditBtn;
  final Color? bgColor, txtColor;

  final double? radius;
  final String avatarInitial;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return InkWell(
      onTap: onEdit,
      child: CircleAvatar(
        backgroundColor: bgColor,
        // backgroundColor: Colors.brown[300],
        radius: radius,
        child: includeEditBtn
            ? SizedBox(
                width: 40.0,
                height: 40.0,
                child: Stack(
                  children: [
                    Text(
                      avatarInitial.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium!.apply(
                            color: txtColor,
                            fontSizeFactor: 1.7,
                            fontWeightDelta: -3,
                          ),
                    ),
                    Positioned(
                      top: 15.0,
                      right: 5.0,
                      child: Icon(
                        Iconsax.edit,
                        size: CSizes.iconXs,
                        color: isDarkTheme ? CColors.white : CColors.rBrown,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                avatarInitial.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium!.apply(
                      color: txtColor,
                    ),
              ),
      ),
    );
  }
}
