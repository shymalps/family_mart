// Controllers/single_bill_controller.dart
import 'package:family_mart/Store/services/single_bill_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../Models/single_bill_model.dart';


class SingleBillController extends GetxController {
  final SingleBillService _singleBillService = Get.find<SingleBillService>();

  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<SingleBillData> billData = Rxn<SingleBillData>();

  // Observable for refresh indicator
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Get bill ID from arguments if navigated with parameters
    final billId = Get.arguments as int?;
    if (billId != null) {
      fetchSingleBill(billId);
    }
  }

  /// Fetch single bill details
  Future<void> fetchSingleBill(int billId) async {
    try {
      _setLoadingState(true);
      _clearError();

      if (kDebugMode) {
        debugPrint('Fetching single bill with ID: $billId');
      }

      final response = await _singleBillService.getSingleBill(billId: billId);

      if (response.success && response.data != null) {
        billData.value = response.data!.data;
        if (kDebugMode) {
          debugPrint('Single bill data loaded successfully');
          debugPrint('Bill Number: ${billData.value?.billNumber}');
          debugPrint('Total Amount: ${billData.value?.totalAmount}');
        }
      } else {
        _setError(response.message ?? 'Failed to load bill details');
        if (kDebugMode) {
          debugPrint('Error loading single bill: ${response.message}');
        }
      }
    } catch (e, stackTrace) {
      _setError('An unexpected error occurred: ${e.toString()}');
      if (kDebugMode) {
        debugPrint('Exception in fetchSingleBill: $e');
        debugPrint('StackTrace: $stackTrace');
      }
    } finally {
      _setLoadingState(false);
    }
  }

  /// Refresh bill data
  Future<void> refreshBillData(int billId) async {
    try {
      isRefreshing.value = true;
      _clearError();

      final response = await _singleBillService.getSingleBill(billId: billId);

      if (response.success && response.data != null) {
        billData.value = response.data!.data;
        Get.snackbar(
          'Success',
          'Bill data refreshed successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        _setError(response.message ?? 'Failed to refresh bill details');
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to refresh bill details',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      _setError('Failed to refresh bill data');
      Get.snackbar(
        'Error',
        'Failed to refresh bill data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Retry loading bill data
  Future<void> retryFetchBill(int billId) async {
    await fetchSingleBill(billId);
  }

  // Helper methods
  void _setLoadingState(bool loading) {
    isLoading.value = loading;
  }

  void _setError(String message) {
    hasError.value = true;
    errorMessage.value = message;
  }

  void _clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  // Getters for computed values
  bool get hasBillData => billData.value != null;

  String get formattedBillNumber => billData.value?.billNumber ?? 'N/A';

  String get formattedTotalAmount => '₹${billData.value?.totalAmount.toStringAsFixed(2) ?? '0.00'}';

  String get formattedFinalTotal => '₹${billData.value?.finalTotal.toStringAsFixed(2) ?? '0.00'}';

  String get formattedPaidAmount => '₹${billData.value?.paidAmount.toStringAsFixed(2) ?? '0.00'}';

  String get customerName => billData.value?.customerName ?? 'N/A';

  String get phoneNumber => billData.value?.phoneNumber ?? 'N/A';

  String get address => billData.value?.address ?? 'N/A';

  String get paymentType => billData.value?.paymentType ?? 'N/A';

  String get staff => billData.value?.staff ?? 'N/A';

  List<ProductDetail> get productDetails => billData.value?.productDetails ?? [];

  double get totalAmount => billData.value?.totalAmount ?? 0.0;

  double get paidAmount => billData.value?.paidAmount ?? 0.0;

  double get finalTotal => billData.value?.finalTotal ?? 0.0;

  double get balance => billData.value?.balance ?? 0.0;

  int get totalQuantity => billData.value?.totalQuantity ?? 0;

  String get createdAt => billData.value?.createdAt ?? 'N/A';

  // Utility methods
  bool get isPaid => billData.value?.isFullyPaid ?? false;

  bool get hasPendingAmount => balance > 0;

  BillDetails? get billDetails => billData.value?.billDetails;

  // Helper method to get formatted date from bill details
  String get formattedBillDate => billDetails?.formattedDate ?? 'N/A';

  String get formattedBillDateTime => billDetails?.formattedDateTime ?? 'N/A';

  String get paymentStatus => billDetails?.paymentStatus ?? 'Unknown';

  bool get isDeliveryCompleted => billDetails?.isDeliveryCompleted ?? false;

  @override
  void onClose() {
    // Clean up any resources if needed
    super.onClose();
  }
}