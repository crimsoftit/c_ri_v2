import 'package:c_ri/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/common/widgets/products/cart/cart_counter_icon.dart';
import 'package:c_ri/common/widgets/products/cart/positioned_cart_counter_widget.dart';
import 'package:c_ri/common/widgets/products/circle_avatar.dart';
import 'package:c_ri/common/widgets/shimmers/vert_items_shimmer.dart';
import 'package:c_ri/common/widgets/txt_widgets/c_section_headings.dart';
import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/cart_controller.dart';
import 'package:c_ri/features/store/controllers/checkout_controller.dart';
import 'package:c_ri/features/store/controllers/dashboard_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/nav_menu_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/features/store/screens/home/widgets/dashboard_header.dart';
import 'package:c_ri/features/store/screens/txns/txns_for_updates.dart';
import 'package:c_ri/nav_menu.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/constants/sizes.dart';
import 'package:c_ri/utils/constants/txt_strings.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class HomeScreenRaw extends StatelessWidget {
  const HomeScreenRaw({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.put(CCartController());
    final dashboardController = Get.put(CDashboardController());

    final invController = Get.put(CInventoryController());
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;

    final navController = Get.put(CNavMenuController());
    final txnsController = Get.put(CTxnsController());

    Get.put(CDashboardController());
    //Get.put(CTxnsController());

    //invController.onInit();
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CPrimaryHeaderContainer(
              child: Column(
                children: [
                  // -- ## HOME PAGE APP BAR ## --
                  DashboardHeaderWidget(
                    appBarTitle: CTexts.homeAppbarTitle,
                    actionsSection: CCartCounterIcon(
                      iconColor: Colors.white,
                    ),
                    screenTitle: '',
                    isHomeScreen: true,
                  ),

                  // -- ## ALL ABOUT CATEGORIES ## --
                  Padding(
                    padding: const EdgeInsets.only(
                      left: CSizes.defaultSpace,
                    ),
                    child: Obx(
                      () {
                        final txnsController = Get.put(CTxnsController());
                        // run loader --
                        if (txnsController.isLoading.value ||
                            invController.isLoading.value ||
                            invController.syncIsLoading.value ||
                            cartController.cartItemsLoading.value) {
                          return const CVerticalProductShimmer(
                            itemCount: 7,
                          );
                        }
                        return Column(
                          children: [
                            // -- top sellers category heading --
                            CSectionHeading(
                              showActionBtn: true,
                              title: 'top sellers...',
                              txtColor: CColors.white,
                              btnTitle: 'view all',
                              btnTxtColor: CColors.grey,
                              editFontSize: true,
                              onPressed: () {
                                navController.selectedIndex.value = 1;
                                Get.to(() => const NavMenu());
                              },
                            ),
                            const SizedBox(
                              height: CSizes.spaceBtnItems / 4.0,
                            ),
                            // -- top sellers list of items --
                            if (invController.inventoryItems.isNotEmpty)
                              SizedBox(
                                height: 100.0,
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
                                      child: Column(
                                        children: [
                                          Container(
                                            width: 56.0,
                                            height: 56.0,
                                            padding: const EdgeInsets.all(
                                              CSizes.sm,
                                            ),
                                            decoration: BoxDecoration(
                                              color: CColors.white,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                100.0,
                                              ),
                                            ),
                                            child: Center(
                                              child: CCircleAvatar(
                                                avatarInitial: invController
                                                    .topSoldItems[index].name[0]
                                                    .toUpperCase(),
                                                bgColor: CColors.white,
                                                txtColor: CColors.rBrown,
                                              ),
                                            ),
                                          ),
                                          CRoundedContainer(
                                            bgColor: Colors.transparent,
                                            showBorder: false,
                                            width: 90.0,
                                            child: Column(
                                              children: [
                                                Text(
                                                  invController
                                                      .topSoldItems[index].name,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .apply(
                                                        fontWeightDelta: 2,
                                                        color: CColors.white,
                                                      ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  '${invController.topSoldItems[index].qtySold} sold',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .labelMedium!
                                                      .apply(
                                                        color: CColors.white,
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
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: CSizes.spaceBtnSections,
                  ),
                ],
              ),
            ),

            /// -- weekly sales bar graph --
            if (txnsController.sales.isNotEmpty)
              CRoundedContainer(
                bgColor: CColors.softGrey,
                child: Column(
                  children: [
                    Text(
                      'weekly sales...',
                      style: Theme.of(context).textTheme.headlineSmall!.apply(
                            color: CColors.rBrown,
                            fontSizeFactor: 0.8,
                          ),
                    ),
                    const SizedBox(
                      height: CSizes.spaceBtnSections,
                    ),

                    // the graph
                    SizedBox(
                      height: 200.0,
                      child: BarChart(
                        BarChartData(
                          titlesData: buildFlTitlesData(),
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
                          barGroups: dashboardController.weeklySales
                              .asMap()
                              .entries
                              .map(
                                (entry) => BarChartGroupData(
                                  x: entry.key,
                                  barRods: [
                                    BarChartRodData(
                                      width: 25.0,
                                      toY: entry.value,
                                      color: CColors.rBrown,
                                      borderRadius: BorderRadius.circular(
                                        CSizes.sm,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList(),
                          groupsSpace: CSizes.spaceBtnItems,
                          barTouchData: BarTouchData(
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (group) {
                                  return CColors.secondary;
                                },
                              ),
                              touchCallback:
                                  (barTouchEvent, barTouchResponse) {}),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // CSectionHeading(
            //               showActionBtn: true,
            //               title: 'top sellers...',
            //               txtColor: CColors.white,
            //               btnTitle: 'gsheet inventory data',
            //               btnTxtColor: CColors.grey,
            //               editFontSize: true,
            //               onPressed: () {
            //                 Get.to(() => const GsheetsInvScreen());
            //               },
            //             ),
            //             const SizedBox(
            //               height: CSizes.spaceBtnItems,
            //             ),

            // CSectionHeading(
            //   showActionBtn: true,
            //   title: 'popular categories',
            //   txtColor: CColors.white,
            //   btnTitle: 'gsheet txns data',
            //   btnTxtColor: CColors.grey,
            //   editFontSize: true,
            //   onPressed: () {
            //     Get.to(() => const GsheetsTxnsScreen());
            //   },
            // ),
            // const SizedBox(
            //   height: CSizes.spaceBtnItems,
            // ),
            // CSectionHeading(
            //   showActionBtn: true,
            //   title: 'dels',
            //   txtColor: CColors.white,
            //   btnTitle: 'view all',
            //   btnTxtColor: CColors.grey,
            //   editFontSize: true,
            //   onPressed: () {
            //     Get.to(() => const CDels());
            //   },
            // ),
            // const SizedBox(
            //   height: CSizes.spaceBtnItems,
            // ),
            Visibility(
              visible: false,
              child: CSectionHeading(
                showActionBtn: true,
                title: 'pending txn updates(especially refunds)',
                txtColor: CColors.white,
                btnTitle: 'view all',
                btnTxtColor: CColors.grey,
                editFontSize: true,
                onPressed: () {
                  Get.to(() => const CTxnsForUpdates());
                },
              ),
            ),
            // const SizedBox(
            //   height: CSizes.spaceBtnItems,
            // ),
            // CSectionHeading(
            //   showActionBtn: true,
            //   title: 'pending txns',
            //   txtColor: CColors.white,
            //   btnTitle: 'view all',
            //   btnTxtColor: CColors.grey,
            //   editFontSize: true,
            //   onPressed: () {
            //     Get.to(() => const TxnsForAppends());
            //   },
            // ),
          ],
        ),
      ),

      /// -- floating action button to scan item for sale --
      floatingActionButton: Obx(
        () {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              cartController.countOfCartItems.value >= 1
                  ? Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            //Get.put(CCheckoutController());
                            final checkoutController =
                                Get.put(CCheckoutController());
                            checkoutController.handleNavToCheckout();
                          },
                          backgroundColor: isConnectedToInternet
                              ? Colors.brown
                              : CColors.black,
                          foregroundColor: Colors.white,
                          heroTag: 'checkout',
                          child: const Icon(
                            Iconsax.wallet_check,
                          ),
                        ),
                        CPositionedCartCounterWidget(
                          counterBgColor: CColors.white,
                          counterTxtColor: CColors.rBrown,
                          rightPosition: 10.0,
                          topPosition: 8.0,
                        ),
                      ],
                    )
                  : SizedBox(),
              const SizedBox(
                height: CSizes.spaceBtnSections / 8,
              ),
            ],
          );
        },
      ),
    );
  }

  FlTitlesData buildFlTitlesData() {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            // map index to the desired day of the week
            final days = [
              'mon',
              'tue',
              'wed',
              'thu',
              'fri',
              'sat',
              'sun',
            ];

            // calculate the index and ensure it wraps around the corresponding day of the week
            final index = value.toInt() % days.length;

            // get the day corresponding to the calculated index
            final day = days[index];

            return SideTitleWidget(
              space: 0,
              axisSide: AxisSide.bottom,
              child: Text(
                day,
                style: TextStyle(
                  color: CColors.rBrown,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 500.0,
          reservedSize: 70.0,
          getTitlesWidget: (value, meta) {
            final userController = Get.put(CUserController());
            return SideTitleWidget(
              space: 0,
              axisSide: AxisSide.bottom,
              child: Text(
                '${userController.user.value.currencyCode}.$value',
                style: TextStyle(
                  color: CColors.rBrown,
                ),
              ),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
        ),
      ),
    );
  }
}
