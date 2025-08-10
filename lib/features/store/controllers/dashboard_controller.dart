import 'dart:math';

import 'package:c_ri/features/personalization/controllers/user_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:clock/clock.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CDashboardController extends GetxController {
  static CDashboardController get instance => Get.find();

  /// -- variables --
  final RxDouble weeklySalesHighestAmount = 0.0.obs;
  final txnsController = Get.put(CTxnsController());
  final RxList<double> weeklySales = <double>[].obs;

  @override
  void onInit() async {
    weeklySalesHighestAmount.value = 1000.0;
    await txnsController.fetchSoldItems().then(
      (result) async {
        if (result.isNotEmpty) {
          calculateWeeklySales();
        }
      },
    );

    super.onInit();
  }

  /// -- calculate weekly sales --
  void calculateWeeklySales() async {
    // reset weeklySales values to zero
    weeklySales.value = List<double>.filled(7, 0.0);

    txnsController.fetchSoldItems().then(
      (result) {
        if (result.isNotEmpty) {
          for (var sale in txnsController.sales) {
            final String rawSaleDate = sale.lastModified.trim();
            var formattedDate = rawSaleDate.replaceAll(' @', '');
            final DateTime salesWeekStart =
                CHelperFunctions.getStartOfWeek(DateTime.parse(formattedDate));

            // check if sale date is within the current week
            if (salesWeekStart.isBefore(clock.now()) &&
                salesWeekStart
                    .add(const Duration(days: 7))
                    .isAfter(clock.now())) {
              int index = (DateTime.parse(formattedDate).weekday - 1) % 7;

              // ensure the index is non-negative
              index = index < 0 ? index + 7 : index;
              weeklySales[index] += (sale.unitSellingPrice * sale.quantity);

              if (kDebugMode) {
                print(
                    'date: $formattedDate, current week day: $salesWeekStart, index: $index');
              }
            }
            // if (salesWeekStart.isBefore(DateTime.now()) &&
            //     salesWeekStart
            //         .add(const Duration(days: 7))
            //         .isAfter(DateTime.now())) {
            //   int index = (DateTime.parse(formattedDate).weekday - 1) % 7;

            //   // ensure the index is non-negative
            //   index = index < 0 ? index + 7 : index;
            //   weeklySales[index] += (sale.unitSellingPrice * sale.quantity);

            //   if (kDebugMode) {
            //     print(
            //         'date: $formattedDate, current week day: $salesWeekStart, index: $index');
            //   }
            // }
          }
        }

        weeklySalesHighestAmount.value = weeklySales.reduce(max);

        if (kDebugMode) {
          print('weekly sales: $weeklySales');
        }
      },
    );
  }

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
