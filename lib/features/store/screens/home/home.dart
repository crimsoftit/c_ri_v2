import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/divider/c_divider.dart';
import 'package:c_ri/common/widgets/products/cart/cart_counter_icon.dart';
import 'package:c_ri/common/widgets/products/circle_avatar.dart';
import 'package:c_ri/common/widgets/shimmers/horizontal_items_shimmer.dart';
import 'package:c_ri/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:c_ri/features/store/controllers/dashboard_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/features/store/screens/home/widgets/dashboard_header.dart';
import 'package:c_ri/nav_menu.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/constants/txt_strings.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //final cartController = Get.put(CCartController());
    final dashboardController = Get.put(CDashboardController());

    final invController = Get.put(CInventoryController());
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    final navController = Get.put(CNavMenuController());
    //final txnsController = Get.put(CTxnsController());

    Get.put(CDashboardController());

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
                CCartCounterIcon(
                  iconColor: CColors.rBrown,
                ),
              ],
            ),
          ),
        ),
        backgroundColor: CColors.rBrown.withValues(alpha: 0.2),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: CSizes.defaultSpace / 4.0,
              ),

              /// -- dashboard header widget --
              DashboardHeaderWidget(
                actionsSection: SizedBox(),
                appBarTitle: CTexts.homeAppbarTitle,
                isHomeScreen: true,
                screenTitle: '',
                showAppBarTitle: false,
              ),
              CDivider(
                endIndent: 0.0,
              ),

              Padding(
                padding: const EdgeInsets.only(
                  left: 18.0,
                  right: 18.0,
                  top: 0,
                ),
                child: Obx(
                  () {
                    if (invController.isLoading.value) {
                      return CHorizontalProductShimmer();
                    }
                    if (invController.inventoryItems.isEmpty &&
                        !invController.isLoading.value) {
                      invController.fetchUserInventoryItems();
                    }
                    if (invController.inventoryItems.isNotEmpty &&
                        invController.topSoldItems.isEmpty &&
                        !invController.isLoading.value) {
                      invController.fetchTopSellers();
                    }

                    /// -- top sellers --
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CSectionHeading(
                          showActionBtn: true,
                          title: 'top sellers...',
                          // txtColor: CColors.white,
                          txtColor: CColors.rBrown,
                          btnTitle: 'view all',
                          btnTxtColor: CColors.grey,
                          editFontSize: true,
                          onPressed: () {
                            navController.selectedIndex.value = 1;
                            Get.to(() => const NavMenu());
                          },
                        ),
                        // CDivider(
                        //   endIndent: 250.0,
                        //   startIndent: 0.0,
                        // ),
                        SizedBox(
                          height: 40.0,
                          child: ListView.separated(
                            itemCount: invController.topSoldItems.length,
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            separatorBuilder: (_, __) {
                              return SizedBox(
                                width: CSizes.spaceBtnItems / 2,
                              );
                            },
                            itemBuilder: (_, index) {
                              return InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    '/inventory/item_details/',
                                    arguments: invController
                                        .topSoldItems[index].productId,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CCircleAvatar(
                                      avatarInitial: invController
                                          .topSoldItems[index].name[0]
                                          .toUpperCase(),
                                      bgColor: CColors.white,
                                      radius: 20.0,
                                      txtColor: CColors.rBrown,
                                    ),
                                    const SizedBox(
                                      width: CSizes.spaceBtnItems / 5,
                                    ),
                                    CRoundedContainer(
                                      bgColor: CColors.transparent,
                                      showBorder: false,
                                      width: 90.0,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            invController
                                                .topSoldItems[index].name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .apply(
                                                  fontWeightDelta: 2,
                                                  color: isDarkTheme
                                                      ? CColors.grey
                                                      : CColors.rBrown,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          Text(
                                            '${invController.topSoldItems[index].qtySold} sold',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium!
                                                .apply(
                                                  color: CColors.darkGrey,
                                                ),
                                            overflow: TextOverflow.fade,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        SizedBox(
                          height: CSizes.spaceBtnSections,
                        ),

                        /// -- weekly sales bar graph --
                        CRoundedContainer(
                          bgColor: CColors.grey,
                          borderRadius: CSizes.cardRadiusSm,
                          child: Column(
                            //crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 15.0,
                                ),
                                width: CHelperFunctions.screenWidth() * .85,
                                child: Text(
                                  'weekly sales',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium!
                                      .apply(
                                        color: isConnectedToInternet
                                            ? CColors.rBrown
                                            : CColors.darkGrey,
                                        fontSizeFactor: 1.20,
                                        fontStyle: FontStyle.italic,
                                      ),
                                ),
                              ),

                              // the graph
                              SizedBox(
                                height: 200.0,
                                child: Obx(
                                  () {
                                    return BarChart(
                                      BarChartData(
                                        titlesData: dashboardController
                                            .buildFlTitlesData(),
                                        borderData: FlBorderData(
                                          show: true,
                                          border: const Border(
                                            top: BorderSide.none,
                                            right: BorderSide.none,
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawHorizontalLine: true,
                                          drawVerticalLine: false,
                                          horizontalInterval: 200,
                                        ),
                                        barGroups: dashboardController
                                            .weeklySales
                                            .asMap()
                                            .entries
                                            .map(
                                              (entry) => BarChartGroupData(
                                                x: entry.key,
                                                barRods: [
                                                  BarChartRodData(
                                                    width: 25.0,
                                                    toY: entry.value,
                                                    color: isConnectedToInternet
                                                        ? CColors.rBrown
                                                        : CColors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      CSizes.sm,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                            .toList(),
                                        groupsSpace: CSizes.spaceBtnItems / 2,
                                        barTouchData: BarTouchData(
                                            touchTooltipData:
                                                BarTouchTooltipData(
                                              getTooltipColor: (group) {
                                                return CColors.secondary;
                                              },
                                            ),
                                            touchCallback: (barTouchEvent,
                                                barTouchResponse) {}),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
