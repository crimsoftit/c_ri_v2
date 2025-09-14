import 'package:c_ri/features/store/models/expansion_panel_model.dart';
import 'package:get/get.dart';

class CExpansionPanelListController extends GetxController {
  late List<CExpansionPanelModel> storeItem;

  final RxBool panelIsExpanded = false.obs;

  @override
  void onInit() {
    storeItem = generateItems(5);
    super.onInit();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  List<CExpansionPanelModel> generateItems(int numberOfItems) {
    return List<CExpansionPanelModel>.generate(numberOfItems, (int index) {
      return CExpansionPanelModel(
          headerValue: 'Panel $index',
          expandedValue: 'This is item number $index');
    });
  }

  onExpansionCallBack(bool pIsExpanded) async {
    generateItems(5);
    panelIsExpanded.value = !pIsExpanded;
  }
}
