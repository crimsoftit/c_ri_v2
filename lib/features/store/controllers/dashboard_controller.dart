import 'dart:math';

import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:clock/clock.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_date_utils/in_date_utils.dart';

class CDashboardController extends GetxController {
  static CDashboardController get instance => Get.find();

  /// -- variables --
  final invController = Get.put(CInventoryController());
  final RxDouble weeklySalesHighestAmount = 0.0.obs;
  final txnsController = Get.put(CTxnsController());
  final RxList<double> lastWeekSales = <double>[].obs;
  final RxList<double> weeklySales = <double>[].obs;

  @override
  void onInit() async {
    weeklySalesHighestAmount.value = 1000.0;
    Future.delayed(
      Duration.zero,
      () {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) async {
            await txnsController.fetchSoldItems().then(
              (result) async {
                calculateCurrentWeekSales();
              },
            );
          },
        );
      },
    );

    super.onInit();
  }

  /// -- calculate this week's sales --
  void calculateCurrentWeekSales() async {
    // reset weeklySales values to zero
    weeklySales.value = List<double>.filled(7, 0.0);

    txnsController.fetchSoldItems().then(
      (result) {
        if (result.isNotEmpty) {
          for (var sale in txnsController.sales) {
            final String rawSaleDate = sale.lastModified.trim();
            var formattedDate = rawSaleDate.replaceAll(' @', '');
            final DateTime currentWeekSalesStart =
                CHelperFunctions.getStartOfCurrentWeek(
                    DateTime.parse(formattedDate));

            // check if sale date is within the current week
            if (currentWeekSalesStart.isBefore(clock.now()) &&
                currentWeekSalesStart
                    .add(const Duration(days: 7))
                    .isAfter(clock.now())) {
              int index = (DateTime.parse(formattedDate).weekday - 1) % 7;

              // ensure the index is non-negative
              index = index < 0 ? index + 7 : index;
              weeklySales[index] += (sale.unitSellingPrice * sale.quantity);

              if (kDebugMode) {
                print(
                    'date: $formattedDate, current week day: $currentWeekSalesStart, index: $index');
              }
            }
          }
        }

        weeklySalesHighestAmount.value =
            weeklySales.reduce(max) > 1 ? weeklySales.reduce(max) : 1000;

        if (kDebugMode) {
          print('weekly sales: $weeklySales');
        }
        calculateLastWeekSales();
      },
    );
  }

  /// -- calculate last week's sales --
  void calculateLastWeekSales() {
    // reset lastWeekSales values to zero
    lastWeekSales.value = List<double>.filled(7, 0.0);

    final now = DateTime.now();
    final lastWeekStart =
        now.subtract(Duration(days: now.weekday + 6)); // Monday of last week
    final lastWeekEnd =
        lastWeekStart.add(Duration(days: 6)); // Sunday of last week

    if (kDebugMode) {
      print('last week start date: $lastWeekStart \n');
      print('last week end date: $lastWeekEnd \n');
    }

    // Filter sales data for the last week
    Future.delayed(
      Duration.zero,
      () {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) {
            txnsController.fetchSoldItems().then(
              (result) {
                if (result.isNotEmpty) {
                  // Filter sales data for last week
                  final lastWeekSales = txnsController.sales.where((sale) {
                    final String rawSaleDate = sale.lastModified.trim();
                    var formattedDate = rawSaleDate.replaceAll(' @', '');
                    final DateTime lastWeekSalesStart =
                        CHelperFunctions.getStartOfLastWeek(
                            DateTime.parse(formattedDate));
                    return lastWeekSalesStart.isAfter(
                            lastWeekStart.subtract(Duration(days: 1))) &&
                        lastWeekStart
                            .isBefore(lastWeekEnd.add(Duration(days: 1)));
                  }).fold(
                      0.0,
                      (sum, sale) =>
                          sum + (sale.unitSellingPrice * sale.quantity));

                  if (kDebugMode) {
                    print('Total sales for last week: $lastWeekSales');
                  }
                }
              },
            );
          },
        );
      },
    );
  }

  // /// -- calculate last week's sales --
  // void calculateLastWeekSales(CTxnsModel allSales) {
  //   // Get the current date and time
  //   final now = DateTime.now();

  //   // Calculate the start of last week (Monday of the previous week)
  //   final startOfLastWeek = now.subtract(
  //       Duration(days: now.weekday + 6)); // Subtract days to get to Monday

  //   // Calculate the end of last week (Sunday of the previous week)
  //   final endOfLastWeek =
  //       startOfLastWeek.add(Duration(days: 6)); // Add 6 days to get to Sunday

  //   if (kDebugMode) {
  //     print('last week end date: $endOfLastWeek');
  //   }

  //   // Filter sales data for the last week
  //   final lastWeekSales = txnsController.sales.where((sale) {
  //     final String rawSaleDate = sale.lastModified.trim();
  //     var formattedDate = rawSaleDate.replaceAll(' @', '');
  //     final DateTime lastWeekSalesStart =
  //         CHelperFunctions.getStartOfLastWeek(DateTime.parse(formattedDate));
  //     return lastWeekSalesStart
  //             .isAfter(startOfLastWeek.subtract(Duration(seconds: 1))) &&
  //         lastWeekSalesStart.isBefore(endOfLastWeek.add(Duration(seconds: 1)));
  //   }).toList();

  //   // Calculate total sales for last week
  //   final totalSales = lastWeekSales.fold(
  //       0.0, (sum, sale) => sum + (sale.quantity * sale.unitSellingPrice));

  //   // Print results
  //   if (kDebugMode) {
  //     print('*********\n');
  //     print('Last week sales: $totalSales');
  //     print('Sales details: $lastWeekSales');
  //     print('*********\n');
  //   }
  // }

  FlTitlesData buildFlTitlesData() {
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
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
                  color:
                      isConnectedToInternet ? CColors.rBrown : CColors.darkGrey,
                ),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: weeklySalesHighestAmount.value,
          reservedSize: 70.0,
          getTitlesWidget: (value, meta) {
            final userController = Get.put(CUserController());
            return SideTitleWidget(
              space: 0,
              axisSide: AxisSide.bottom,
              child: Text(
                '${userController.user.value.currencyCode}.$value',
                style: TextStyle(
                  color:
                      isConnectedToInternet ? CColors.rBrown : CColors.darkGrey,
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
