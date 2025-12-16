import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_mart/Store/Models/due_model.dart';

import '../../Controller/Single Controllers/due_controller.dart';
import '../../Extras/approutes/route_name.dart';
import '../../Extras/styles.dart';



class DuesPage extends StatefulWidget {
  const DuesPage({super.key});

  @override
  State<DuesPage> createState() => _DuesPageState();
}

class _DuesPageState extends State<DuesPage> {
  late final BillDuesController billDuesController;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    billDuesController = Get.put(BillDuesController());
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Load more data when reaching bottom
        billDuesController.loadMoreBillDuesHistory();
      }
    });
  }

  List<BillDue> get filteredDues {
    List<BillDue> allDues = billDuesController.billDuesList.toList();

    // Apply date filter if both dates are selected
    if (fromDate.value != null && toDate.value != null) {
      allDues = billDuesController.getBillsByDateRange(
        fromDate.value!,
        toDate.value!,
      );
    }

    return allDues;
  }

  void _handleDateFilter() {
    // The filtering is handled by the getter filteredDues
    setState(() {});
  }

  String _formatDateForAPI(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.bgColor,
              AppColors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.6],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => billDuesController.refreshBillDuesHistory(),
            color: AppColors.primary,
            child: Column(
              children: [
                _buildTopBar(),
                _buildDateFilter(),
                Expanded(child: _buildDuesList()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 2))
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_rounded,
                  color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Due Bills', style: AppTextStyles.heading1),
                    const SizedBox(width: 8),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${billDuesController.duesCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Colors.red,
                      Colors.red.withOpacity(0.4)
                    ]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(child: _buildDateButton('From', fromDate)),
          const SizedBox(width: 8),
          Expanded(child: _buildDateButton('To', toDate)),
          const SizedBox(width: 8),
          _buildQuickActionButton(Icons.clear_rounded, Colors.red, () {
            fromDate.value = null;
            toDate.value = null;
            setState(() {});
          }),
        ],
      ),
    );
  }

  Widget _buildDateButton(String label, Rx<DateTime?> dateValue) {
    return Obx(() => GestureDetector(
      onTap: () => _selectDate(dateValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: dateValue.value != null
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: dateValue.value != null
                  ? AppColors.primary.withOpacity(0.3)
                  : AppColors.grey.withOpacity(0.3)),
        ),
        child: Text(
          dateValue.value != null ? _formatDate(dateValue.value!) : label,
          style: AppTextStyles.caption.copyWith(
            color: dateValue.value != null
                ? AppColors.primary
                : AppColors.grey,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ));
  }

  Widget _buildQuickActionButton(
      IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  Future<void> _selectDate(Rx<DateTime?> dateValue) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateValue.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dateValue.value = picked;
      _handleDateFilter();
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  Widget _buildDuesList() {
    return Obx(() {
      final bool isLoading = billDuesController.isLoading;
      final bool hasError = billDuesController.hasError;
      final bool isLoadingMore = billDuesController.isLoadingMore;
      final List<BillDue> currentFilteredDues = filteredDues;

      if (isLoading && currentFilteredDues.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                  spreadRadius: 2,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        );
      }

      if (hasError && currentFilteredDues.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 64, color: Colors.red.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('Error loading dues',
                  style: AppTextStyles.heading2.copyWith(color: Colors.red)),
              const SizedBox(height: 8),
              Text(billDuesController.errorMessage,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.grey.withOpacity(0.7)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => billDuesController.retry(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (currentFilteredDues.isEmpty) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded,
                  size: 64, color: Colors.green.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('No dues found',
                  style:
                  AppTextStyles.heading2.copyWith(color: Colors.green)),
              const SizedBox(height: 8),
              Text('All bills are paid or try adjusting the date filter',
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.grey.withOpacity(0.7)),
                  textAlign: TextAlign.center),
            ],
          ),
        );
      }

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: currentFilteredDues.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom when loading more
            if (index == currentFilteredDues.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return _buildDueCard(currentFilteredDues[index]);
          },
        ),
      );
    });
  }

  Widget _buildDueCard(BillDue bill) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Bill #${bill.billNo}',
                            style: AppTextStyles.heading2
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('OVERDUE',
                              style: AppTextStyles.caption.copyWith(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 14, color: AppColors.grey),
                        const SizedBox(width: 4),
                        Text(bill.date,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${_formatAmount(double.tryParse(bill.total) ?? 0.0)}',
                      style: AppTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.red)),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPaymentTypeColor(bill.paymentType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getPaymentTypeIcon(bill.paymentType),
                            size: 10,
                            color: _getPaymentTypeColor(bill.paymentType)),
                        const SizedBox(width: 3),
                        Text(bill.paymentType,
                            style: AppTextStyles.caption.copyWith(
                                color: _getPaymentTypeColor(bill.paymentType),
                                fontWeight: FontWeight.w600,
                                fontSize: 9)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteName.singlebillview, arguments: bill.id);
                    print('View bill details for ID: ${bill.id}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.visibility_rounded,
                            size: 16, color: AppColors.primary),
                        const SizedBox(width: 6),
                        Text('View Details',
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPaymentTypeColor(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'cash':
        return Colors.green;
      case 'card':
        return Colors.blue;
      case 'qr code':
      case 'upi':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }

  IconData _getPaymentTypeIcon(String paymentType) {
    switch (paymentType.toLowerCase()) {
      case 'cash':
        return Icons.money_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'qr code':
      case 'upi':
        return Icons.qr_code_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(2);
  }
}