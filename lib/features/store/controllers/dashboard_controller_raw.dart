import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/utils/helpers/helper_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class CDashboardControllerRaw extends GetxController {
  static CDashboardControllerRaw get instance => Get.find();

  /// -- variables --
  final invController = Get.put(CInventoryController());
  final txnsController = Get.put(CTxnsController());
  final RxList<double> weeklySales = <double>[].obs;

  @override
  void onInit() async {
    await invController.fetchUserInventoryItems().then(
      (_) async {
        await calculateWeeklySales();
      },
    );

    super.onInit();
  }

  /// -- calculate weekly sales --
  Future calculateWeeklySales() async {
    // reset weeklySales values to zero
    weeklySales.value = List<double>.filled(7, 0.0);

    txnsController.fetchSoldItems().then((_) {
      for (var sale in txnsController.sales) {
        final String rawSaleDate = sale.lastModified.trim();
        var formattedDate = rawSaleDate.replaceAll(' @', '');
        final DateTime salesWeekStart =
            CHelperFunctions.getStartOfWeek(DateTime.parse(formattedDate));

        // check if sale date is within the current week
        if (salesWeekStart.isBefore(DateTime.now()) &&
            salesWeekStart
                .add(const Duration(days: 7))
                .isAfter(DateTime.now())) {
          int index = (DateTime.parse(formattedDate).weekday - 1) % 7;

          // ensure the index is non-negative
          index = index < 0 ? index + 7 : index;
          weeklySales[index] += (sale.unitSellingPrice * sale.quantity);

          if (kDebugMode) {
            print(
                'date: $formattedDate, current week day: $salesWeekStart, index: $index');
          }
        }
      }

      if (kDebugMode) {
        print('weekly sales: $weeklySales');
      }
    });
  }
}
