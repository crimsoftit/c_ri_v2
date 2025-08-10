import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/device/device_utilities.dart';
import 'package:flutter/material.dart';

class CTabBar extends StatelessWidget implements PreferredSizeWidget {
  const CTabBar({
    super.key,
    required this.tabs,
  });

  final List<Widget> tabs;

  @override
  Widget build(BuildContext context) {
    //final isDarkTheme = CHelperFunctions.isDarkMode(context);
    return TabBar(
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      indicatorColor: CColors.rBrown,
      unselectedLabelColor: CColors.darkGrey,
      // labelColor: isDarkTheme ? CColors.white : CColors.rBrown,
      labelColor: CColors.rBrown,
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(CDeviceUtils.getAppBarHeight());
}
