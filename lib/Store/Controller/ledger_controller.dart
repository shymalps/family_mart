import 'package:family_mart/Store/services/ledger_service.dart';
import 'package:get/get.dart';


class LedgerController extends GetxController {
  final LedgerService ledgerService;

  LedgerController({required this.ledgerService});

  var isLoading = false.obs;
  var ledgerData = {}.obs;
  var errorMessage = ''.obs;

  Future<void> getLedger(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ledgerService.fetchLedgerData(id: id);

      if (response.success) {
        ledgerData.value = response.data?['data'] ?? {};
      } else {
        errorMessage.value = response.message!;
      }
    } catch (e) {
      errorMessage.value = 'Something went wrong: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
