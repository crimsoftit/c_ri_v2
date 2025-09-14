import 'package:c_ri/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:c_ri/features/store/controllers/expansion_panel_list_controller.dart';
import 'package:c_ri/features/store/models/expansion_panel_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CExpansionPanelItem extends StatelessWidget {
  const CExpansionPanelItem({super.key});

  @override
  Widget build(BuildContext context) {
    final panelController = Get.put(CExpansionPanelListController());

    return Scaffold(
      body: SingleChildScrollView(
        child: CRoundedContainer(
          margin: const EdgeInsets.only(
            bottom: 20.0,
            top: 20.0,
          ),
          child: Obx(
            () {
              return ExpansionPanelList(
                expansionCallback: (panelIndex, isExpanded) {
                  panelController.storeItem[panelIndex].isExpanded = isExpanded;
                },
                children: panelController.storeItem.map<ExpansionPanel>(
                  (CExpansionPanelModel item) {
                    return ExpansionPanel(
                      headerBuilder: ((context, isExpanded) {
                        return ListTile(
                          title: Text('item.header!'),
                        );
                      }),
                      body: ListTile(
                        title: Text('item.body!'),
                      ),
                      //isExpanded: item.isExpanded!.value,
                      isExpanded: panelController.panelIsExpanded.value,
                    );
                  },
                ).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
