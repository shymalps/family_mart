import 'package:family_mart/Store/Controller/product_list_controller.dart';
import 'package:get/get.dart';

class HomeScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ProductController());
  }
}
