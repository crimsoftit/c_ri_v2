import 'package:c_ri/common/widgets/divider/c_divider.dart';
import 'package:c_ri/common/widgets/img_widgets/c_circular_img.dart';
import 'package:c_ri/common/widgets/list_tiles/menu_tile.dart';
import 'package:c_ri/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/nav_menu.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/img_strings.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CUserSettingsScreen extends StatelessWidget {
  const CUserSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final isDarkTheme = CHelperFunctions.isDarkMode(context);
    final navController = Get.put(CNavMenuController());
    final userController = Get.put(CUserController());

    return Container(
      color: isDarkTheme ? CColors.transparent : CColors.white,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                        navController.selectedIndex.value = 4;
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
        ),
        backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 15.0, top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(
                //   height: CSizes.spaceBtnSections / 2,
                // ),
                Text(
                  'my account',
                  style: Theme.of(context).textTheme.labelLarge!.apply(
                        color: CNetworkManager.instance.hasConnection.value
                            ? CColors.rBrown
                            : CColors.darkGrey,
                        fontSizeFactor: 2.5,
                        fontWeightDelta: -7,
                      ),
                ),
                CDivider(
                  endIndent: 100.0,
                  startIndent: 0,
                ),
                // -- app settings
                const SizedBox(
                  height: CSizes.spaceBtnItems,
                ),
                const CSectionHeading(
                  showActionBtn: false,
                  title: 'app settings',
                  btnTitle: '',
                  editFontSize: false,
                ),

                CMenuTile(
                  icon: Iconsax.document_upload,
                  title: 'upload data',
                  subTitle: 'upload data to your cloud firebase',
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.arrow_right),
                  ),
                  onTap: () {},
                ),
                CMenuTile(
                  icon: Iconsax.cloud,
                  title: 'auto-sync data',
                  subTitle:
                      'set automatic cloud sync for your inventory and sales data',
                  trailing: Switch(
                    value: true,
                    activeColor: CColors.rBrown,
                    onChanged: (value) {},
                  ),
                ),
                CMenuTile(
                  icon: Iconsax.location,
                  title: 'geolocation',
                  subTitle: 'set recommendation based on location',
                  trailing: Switch(
                    value: true,
                    activeColor: CColors.rBrown,
                    onChanged: (value) {},
                  ),
                ),
                CMenuTile(
                  icon: Iconsax.shopping_cart,
                  title: 'my cart',
                  subTitle: 'add, remove products, and proceed to checkout',
                  onTap: () {},
                ),
                CMenuTile(
                  icon: Iconsax.shopping_cart,
                  subTitle: 'add, remove products, and proceed to checkout',
                  title: 'checkout items',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
