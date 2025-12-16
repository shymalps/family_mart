// Controllers/credit_history_controller.dart
import 'package:family_mart/Store/Models/credit_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../services/credit_service.dart';

class CreditHistoryController extends GetxController {
  final CreditHistoryService _creditHistoryService = Get.find<CreditHistoryService>();

  // Observable variables
  final RxList<Credit> _creditList = <Credit>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isLoadingMore = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxBool _hasError = false.obs;
  final RxBool _hasMoreData = true.obs;
  final RxInt _currentOffset = 0.obs;
  final RxInt _totalRecords = 0.obs;
  final RxInt _limit = 20.obs;

  // Getters
  List<Credit> get creditList => _creditList.toList();
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
    loadCreditHistory();
  }

  /// Load initial credit history
  Future<void> loadCreditHistory({bool showLoader = true}) async {
    try {
      if (showLoader) {
        _setLoading(true);
      }
      _clearError();

      // Reset pagination
      _currentOffset.value = 0;
      _hasMoreData.value = true;

      final response = await _creditHistoryService.getCreditHistory(
        offset: _currentOffset.value,
      );

      if (response.isSuccess && response.data != null) {
        _handleSuccessResponse(response.data!, isRefresh: true);
      } else {
        _handleErrorResponse(response.message ?? 'Failed to load credit history');
      }
    } catch (e, stackTrace) {
      _logError('Load Credit History Error', e.toString(), stackTrace: stackTrace);
      _handleErrorResponse('An unexpected error occurred while loading credit history');
    } finally {
      _setLoading(false);
    }
  }

  /// Load more credit history (pagination)
  Future<void> loadMoreCreditHistory() async {
    if (!_hasMoreData.value || _isLoadingMore.value) return;

    try {
      _setLoadingMore(true);
      _clearError();

      final nextOffset = _currentOffset.value + _limit.value;

      final response = await _creditHistoryService.getCreditHistory(
        offset: nextOffset,
      );

      if (response.isSuccess && response.data != null) {
        _handleSuccessResponse(response.data!, isRefresh: false);
        _currentOffset.value = nextOffset;
      } else {
        _handleErrorResponse(response.message ?? 'Failed to load more credit history');
      }
    } catch (e, stackTrace) {
      _logError('Load More Credit History Error', e.toString(), stackTrace: stackTrace);
      _handleErrorResponse('An unexpected error occurred while loading more data');
    } finally {
      _setLoadingMore(false);
    }
  }

  /// Refresh credit history
  Future<void> refreshCreditHistory() async {
    await loadCreditHistory(showLoader: false);
  }

  /// Handle successful API response
  void _handleSuccessResponse(CreditHistoryResponse response, {required bool isRefresh}) {
    if (isRefresh) {
      _creditList.clear();
    }

    _creditList.addAll(response.data);
    _totalRecords.value = response.total;
    _limit.value = response.limit;

    // Check if there's more data to load
    _hasMoreData.value = response.data.length >= response.limit;

    _clearError();

    if (kDebugMode) {
      debugPrint('Credit History loaded: ${response.data.length} items');
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
      debugPrint('Credit History Error: $message');
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

  /// Get credit by ID
  Credit? getCreditById(int id) {
    try {
      return _creditList.firstWhere((credit) => credit.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get credit by customer ID
  Credit? getCreditByCustomerId(int customerId) {
    try {
      return _creditList.firstWhere((credit) => credit.customerId == customerId);
    } catch (e) {
      return null;
    }
  }

  /// Get total credit amount
  double get totalCreditAmount {
    return _creditList.fold(0.0, (sum, credit) {
      return sum + credit.amount;
    });
  }

  /// Get credit count
  int get creditCount => _creditList.length;

  /// Filter credits by root type
  List<Credit> getCreditsByRoot(String root) {
    return _creditList.where((credit) =>
    credit.root.toLowerCase() == root.toLowerCase()
    ).toList();
  }

  /// Filter credits by customer ID
  List<Credit> getCreditsByCustomerId(int customerId) {
    return _creditList.where((credit) => credit.customerId == customerId).toList();
  }

  /// Filter credits by date range
  List<Credit> getCreditsByDateRange(DateTime startDate, DateTime endDate) {
    return _creditList.where((credit) {
      try {
        final creditDate = DateTime.fromMillisecondsSinceEpoch(credit.date * 1000);
        return creditDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
            creditDate.isBefore(endDate.add(const Duration(days: 1)));
      } catch (e) {
        return false;
      }
    }).toList();
  }

  /// Get credits by amount range
  List<Credit> getCreditsByAmountRange(double minAmount, double maxAmount) {
    return _creditList.where((credit) {
      return credit.amount >= minAmount && credit.amount <= maxAmount;
    }).toList();
  }

  /// Get average credit amount
  double get averageCreditAmount {
    if (_creditList.isEmpty) return 0.0;
    return totalCreditAmount / _creditList.length;
  }

  /// Get highest credit amount
  double get highestCreditAmount {
    if (_creditList.isEmpty) return 0.0;
    return _creditList.map((credit) => credit.amount)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Get lowest credit amount
  double get lowestCreditAmount {
    if (_creditList.isEmpty) return 0.0;
    return _creditList.map((credit) => credit.amount)
        .reduce((a, b) => a < b ? a : b);
  }

  /// Clear all data
  void clearData() {
    _creditList.clear();
    _currentOffset.value = 0;
    _totalRecords.value = 0;
    _hasMoreData.value = true;
    _clearError();
  }

  /// Retry loading data
  Future<void> retry() async {
    await loadCreditHistory();
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
    _creditList.close();
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