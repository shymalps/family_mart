import 'package:family_mart/Store/Controller/Single%20Controllers/credit_controller.dart';
import 'package:family_mart/Store/services/due_services.dart';
import 'package:family_mart/Store/services/otp_services.dart';
import 'package:get/get.dart';

import '../Controller/Single Controllers/single_bill_controller.dart';
import '../Controller/bill_controller.dart';
import '../Controller/cart_controller.dart';
import '../Controller/order_controller.dart';
import '../Controller/profile_controller.dart';
import '../Services/order_service.dart';
import '../services/bill_services.dart';
import '../services/cart_services.dart';
import '../services/category_services.dart';
import '../services/credit_service.dart';
import '../services/profile_service.dart';
import '../services/single_bill_service.dart';
import '../services/update_profile_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CategoryService());
    Get.put(ProfileService());
    Get.put(OtpService());
    Get.put(BillService());
    Get.put(SingleBillService());
    Get.put(BillDuesService());
    Get.put(CreditHistoryService());
    Get.put(ProfileServiceUpdate());
    Get.put(CartService());
    Get.put(OrderService());

    ///
    Get.lazyPut<BillController>(() => BillController());
    Get.lazyPut<SingleBillController>(() => SingleBillController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<CreditHistoryController>(() => CreditHistoryController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<OrderController>(() => OrderController());
    // Get.lazyPut<categoryServices>(() => categoryServices());  
  }
}
