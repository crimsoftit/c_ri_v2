import 'package:c_ri/common/widgets/img_widgets/c_circular_img.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/nav_menu.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/device/device_utilities.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CVersion2AppBar extends StatelessWidget implements PreferredSizeWidget {
  const CVersion2AppBar({
    super.key,
    required this.autoImplyLeading,
  });

  final bool autoImplyLeading;

  @override
  Widget build(BuildContext context) {
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    //final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final navController = Get.put(CNavMenuController());
    final userController = Get.put(CUserController());

    return AppBar(
      automaticallyImplyLeading: autoImplyLeading,
      iconTheme: IconThemeData(
        color: CColors.rBrown,
      ),
      title: Padding(
        padding: const EdgeInsets.only(
          left: 0.5,
          right: 0.5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Iconsax.menu,
              size: 25.0,
              color: CColors.rBrown,
            ),
            Obx(
              () {
                final networkImg = userController.user.value.profPic;

                final dpImg = networkImg.isNotEmpty && isConnectedToInternet
                    ? networkImg
                    : CImages.user;

                return InkWell(
                  onTap: () {
                    navController.selectedIndex.value = 3;
                    Get.to(const NavMenu());
                  },
                  child: CCircularImg(
                    isNetworkImg:
                        networkImg.isNotEmpty && isConnectedToInternet,
                    img: dpImg,
                    width: 47.0,
                    height: 47.0,
                    padding: 1.0,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(CDeviceUtils.getAppBarHeight());
}
