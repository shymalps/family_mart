import 'package:family_mart/Store/Controller/product_list_controller.dart';
import 'package:get/get.dart';

import '../Controller/bill_controller.dart';

class BillsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BillController());
  }
}
