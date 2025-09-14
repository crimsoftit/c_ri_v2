import 'package:c_ri/common/widgets/shimmers/shimmer_effects.dart';
import 'package:c_ri/features/store/controllers/inv_controller.dart';
import 'package:c_ri/features/store/controllers/sync_controller.dart';
import 'package:c_ri/features/store/controllers/txns_controller.dart';
import 'package:c_ri/features/store/models/inv_model.dart';
import 'package:c_ri/features/store/screens/store_items_tings/checkout/widgets/checkout_scan_fab.dart';
import 'package:c_ri/features/store/screens/store_items_tings/inventory/widgets/inv_dialog.dart';
import 'package:c_ri/utils/constants/colors.dart';
import 'package:c_ri/utils/helpers/network_manager.dart';
import 'package:c_ri/utils/popups/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class CStoreScreenHeader extends StatelessWidget {
  const CStoreScreenHeader({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final invController = Get.put(CInventoryController());
    final isConnectedToInternet = CNetworkManager.instance.hasConnection.value;
    final syncController = Get.put(CSyncController());
    final txnsController = Get.put(CTxnsController());

    AddUpdateItemDialog dialog = AddUpdateItemDialog();
    return Obx(
      () {
        return Container(
          // padding: const EdgeInsets.only(left: 2.0),
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge!.apply(
                      color: CNetworkManager.instance.hasConnection.value
                          ? CColors.rBrown
                          : CColors.darkGrey,
                      fontSizeFactor: 2.5,
                      fontWeightDelta: -7,
                    ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// -- button to add inventory item --
                  FloatingActionButton(
                    elevation: 0, // -- removes shadow
                    onPressed: () {
                      invController.resetInvFields();
                      showDialog(
                        context: context,
                        useRootNavigator: false,
                        builder: (BuildContext context) => dialog.buildDialog(
                          context,
                          CInventoryModel('', '', '', '', '', 0, 0, 0, 0, 0.0,
                              0.0, 0.0, 0, '', '', '', '', 0, ''),
                          true,
                        ),
                      );
                    },
                    backgroundColor: CColors.transparent,
                    foregroundColor: isConnectedToInternet
                        ? CColors.rBrown
                        : CColors.darkGrey,
                    heroTag: 'add',
                    child: Icon(
                      // Iconsax.scan_barcode,
                      Iconsax.add,
                    ),
                  ),

                  /// -- sync control btn --
                  syncController.processingSync.value
                      ? CShimmerEffect(
                          width: 40.0,
                          height: 40.0,
                          radius: 40.0,
                        )
                      : FloatingActionButton(
                          elevation: 0, // -- removes shadow
                          onPressed: invController.unSyncedAppends.isEmpty &&
                                  invController.unSyncedUpdates.isEmpty &&
                                  txnsController.unsyncedTxnAppends.isEmpty &&
                                  txnsController.unsyncedTxnUpdates.isEmpty
                              ? null
                              : () async {
                                  // -- check internet connectivity --
                                  final internetIsConnected =
                                      await CNetworkManager.instance
                                          .isConnected();

                                  if (internetIsConnected) {
                                    syncController.processSync();
                                  } else {
                                    CPopupSnackBar.customToast(
                                      message:
                                          'internet connection required for cloud sync!',
                                      forInternetConnectivityStatus: true,
                                    );
                                  }
                                },
                          backgroundColor: CColors.transparent,
                          foregroundColor: isConnectedToInternet
                              ? CColors.rBrown
                              : CColors.darkGrey,
                          heroTag: 'sync',
                          child: Icon(
                            invController.unSyncedAppends.isEmpty &&
                                    invController.unSyncedUpdates.isEmpty &&
                                    txnsController.unsyncedTxnAppends.isEmpty &&
                                    txnsController.unsyncedTxnUpdates.isEmpty
                                ? Iconsax.cloud_add
                                : Iconsax.cloud_change,
                          ),
                        ),

                  // -- scan item for checkout btn --
                  CCheckoutScanFAB(
                    elevation: 0.0,
                    bgColor: CColors.transparent,
                    foregroundColor:
                        CNetworkManager.instance.hasConnection.value
                            ? CColors.rBrown
                            : CColors.darkGrey,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
