// Controllers/bill_dues_controller.dart
import 'package:family_mart/Store/Models/due_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../services/due_services.dart';


class BillDuesController extends GetxController {
  final BillDuesService _billDuesService = Get.find<BillDuesService>();

  // Observable variables
  final RxList<BillDue> _billDuesList = <BillDue>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxBool _hasMoreData = true.obs;
  final RxInt _currentOffset = 0.obs;
  final RxInt _totalRecords = 0.obs;
  final RxInt _limit = 20.obs;

  // Getters
  List<BillDue> get billDuesList => _billDuesList.toList();
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  String get errorMessage => _errorMessage.value;
  bool get hasError => _hasError.value;
  bool get hasMoreData => _hasMoreData.value;
  int get totalRecords => _totalRecords.value;
  int get currentOffset => _currentOffset.value;
  int get limit => _limit.value;

  @override
  void onInit() {
    super.onInit();
    loadBillDuesHistory();
  }

  /// Load initial bill dues history
  Future<void> loadBillDuesHistory({bool showLoader = true}) async {
    try {
      if (showLoader) {
        _setLoading(true);
      }
      _clearError();

      // Reset pagination
      _currentOffset.value = 0;
      _hasMoreData.value = true;

      final response = await _billDuesService.getBillDuesHistory(
        offset: _currentOffset.value,
      );

      if (response.isSuccess && response.data != null) {
        _handleSuccessResponse(response.data!, isRefresh: true);
      } else {
        _handleErrorResponse(response.message ?? 'Failed to load bill dues history');
      }
    } catch (e, stackTrace) {
      _logError('Load Bill Dues History Error', e.toString(), stackTrace: stackTrace);
      _handleErrorResponse('An unexpected error occurred while loading bill dues history');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more bill dues history (pagination)
  Future<void> loadMoreBillDuesHistory() async {
    if (!_hasMoreData.value || _isLoadingMore.value) return;

    try {
      _setLoadingMore(true);
      _clearError();

      final nextOffset = _currentOffset.value + _limit.value;

      final response = await _billDuesService.getBillDuesHistory(
        offset: nextOffset,
      );

      if (response.isSuccess && response.data != null) {
        _handleSuccessResponse(response.data!, isRefresh: false);
        _currentOffset.value = nextOffset;
      } else {
        _handleErrorResponse(response.message ?? 'Failed to load more bill dues history');
      }
    } catch (e, stackTrace) {
      _logError('Load More Bill Dues History Error', e.toString(), stackTrace: stackTrace);
      _handleErrorResponse('An unexpected error occurred while loading more data');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Refresh bill dues history
  Future<void> refreshBillDuesHistory() async {
    await loadBillDuesHistory(showLoader: false);
  }

  /// Handle successful API response
  void _handleSuccessResponse(BillDuesHistoryResponse response, {required bool isRefresh}) {
    if (isRefresh) {
      _billDuesList.clear();
    }

    _billDuesList.addAll(response.data);
    _totalRecords.value = response.total;
    _limit.value = response.limit;

    // Check if there's more data to load
    _hasMoreData.value = response.data.length >= response.limit;

    _clearError();

    if (kDebugMode) {
      debugPrint('Bill Dues History loaded: ${response.data.length} items');
      debugPrint('Total records: ${response.total}');
      debugPrint('Has more data: $_hasMoreData');
    }
  }

  /// Handle error response
  void _handleErrorResponse(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
    _hasMoreData.value = false;

    if (kDebugMode) {
      debugPrint('Bill Dues History Error: $message');
    }
  }

  /// Clear error state
  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading.value = loading;
  }

  /// Set loading more state
  void _setLoadingMore(bool loadingMore) {
    _isLoadingMore.value = loadingMore;
  }

  /// Get bill due by ID
  BillDue? getBillDueById(int id) {
    try {
      return _billDuesList.firstWhere((bill) => bill.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get bill due by bill number
  BillDue? getBillDueByBillNo(String billNo) {
    try {
      return _billDuesList.firstWhere((bill) => bill.billNo == billNo);
    } catch (e) {
      return null;
    }
  }

  /// Get total dues amount
  double get totalDuesAmount {
    return _billDuesList.fold(0.0, (sum, bill) {
      return sum + (double.tryParse(bill.total) ?? 0.0);
    });
  }

  /// Get dues count
  int get duesCount => _billDuesList.length;

  /// Filter bills by payment type
  List<BillDue> getBillsByPaymentType(String paymentType) {
    return _billDuesList.where((bill) =>
    bill.paymentType.toLowerCase() == paymentType.toLowerCase()
    ).toList();
  }

  /// Filter bills by date range
  List<BillDue> getBillsByDateRange(DateTime startDate, DateTime endDate) {
    return _billDuesList.where((bill) {
      try {
        // Assuming date format is 'dd-MM-yyyy'
        final parts = bill.date.split('-');
        if (parts.length == 3) {
          final billDate = DateTime(
            int.parse(parts[2]), // year
            int.parse(parts[1]), // month
            int.parse(parts[0]), // day
          );
          return billDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              billDate.isBefore(endDate.add(const Duration(days: 1)));
        }
        return false;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Clear all data
  void clearData() {
    _billDuesList.clear();
    _currentOffset.value = 0;
    _totalRecords.value = 0;
    _hasMoreData.value = true;
    _clearError();
  }

  /// Retry loading data
  Future<void> retry() async {
    await loadBillDuesHistory();
  }

  void _logError(String type, String message, {StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('┌───────────────────────────────────────────────────────');
      debugPrint('│ CONTROLLER ERROR: $type');
      debugPrint('│ Message: $message');
      if (stackTrace != null) {
        debugPrint('│ StackTrace: $stackTrace');
      }
      debugPrint('└───────────────────────────────────────────────────────');
    }
  }

  @override
  void onClose() {
    _billDuesList.close();
    _isLoading.close();
    _isLoadingMore.close();
    _errorMessage.close();
    _hasError.close();
    _hasMoreData.close();
    _currentOffset.close();
    _totalRecords.close();
    _limit.close();
    super.onClose();
  }
}