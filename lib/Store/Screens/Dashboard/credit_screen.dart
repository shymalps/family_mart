import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:family_mart/Store/Models/credit_model.dart';

import '../../Controller/Single Controllers/credit_controller.dart';
import '../../Extras/styles.dart';

class CreditHistoryPage extends StatefulWidget {
  const CreditHistoryPage({super.key});

  @override
  State<CreditHistoryPage> createState() => _CreditHistoryPageState();
}

class _CreditHistoryPageState extends State<CreditHistoryPage> {
  late final CreditHistoryController creditHistoryController;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);
  final Rx<String> selectedRoot = Rx<String>('All');
  final Rx<double?> minAmount = Rx<double?>(null);
  final Rx<double?> maxAmount = Rx<double?>(null);
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    creditHistoryController = Get.put(CreditHistoryController());
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // Load more data when reaching bottom
        creditHistoryController.loadMoreCreditHistory();
      }
    });
  }

  List<Credit> get filteredCredits {
    List<Credit> allCredits = creditHistoryController.creditList.toList();

    // Apply date filter if both dates are selected
    if (fromDate.value != null && toDate.value != null) {
      allCredits = creditHistoryController.getCreditsByDateRange(
        fromDate.value!,
        toDate.value!,
      );
    }

    // Apply root filter
    if (selectedRoot.value != 'All') {
      allCredits = allCredits.where((credit) =>
      credit.root.toLowerCase() == selectedRoot.value.toLowerCase()
      ).toList();
    }

    // Apply amount filter
    if (minAmount.value != null || maxAmount.value != null) {
      final min = minAmount.value ?? 0.0;
      final max = maxAmount.value ?? double.infinity;
      allCredits = allCredits.where((credit) =>
      credit.amount >= min && credit.amount <= max
      ).toList();
    }

    return allCredits;
  }

  void _handleFilter() {
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
            onRefresh: () async => creditHistoryController.refreshCreditHistory(),
            color: AppColors.primary,
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildCreditsList()),
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
                    Text('Credit History', style: AppTextStyles.heading1),
                    const SizedBox(width: 8),
                    Obx(() => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${creditHistoryController.creditCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.green,
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
                      Colors.green,
                      Colors.green.withOpacity(0.4)
                    ]),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // const SizedBox(height: 8),
                // Obx(() => Text(
                //   'Total: ₹${_formatAmount(creditHistoryController.totalCreditAmount)}',
                //   style: AppTextStyles.body2.copyWith(
                //     color: Colors.green,
                //     fontWeight: FontWeight.w600,
                //   ),
                // )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          _buildDateFilter(),
          const SizedBox(height: 8),
          _buildAmountFilter(),
          const SizedBox(height: 8),
          _buildRootFilter(),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
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
            _handleFilter();
          }),
        ],
      ),
    );
  }

  Widget _buildAmountFilter() {
    return Container(
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
          const Icon(Icons.currency_rupee_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _minAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Min Amount',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: AppTextStyles.caption,
              onChanged: (value) {
                minAmount.value = double.tryParse(value);
                _handleFilter();
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _maxAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Max Amount',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: AppTextStyles.caption,
              onChanged: (value) {
                maxAmount.value = double.tryParse(value);
                _handleFilter();
              },
            ),
          ),
          const SizedBox(width: 8),
          _buildQuickActionButton(Icons.clear_rounded, Colors.red, () {
            _minAmountController.clear();
            _maxAmountController.clear();
            minAmount.value = null;
            maxAmount.value = null;
            _handleFilter();
          }),
        ],
      ),
    );
  }

  Widget _buildRootFilter() {
    return Container(
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
          const Icon(Icons.category_rounded,
              color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Obx(() => DropdownButtonFormField<String>(
              value: selectedRoot.value,
              decoration: const InputDecoration(
                hintText: 'Select Root Type',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _getRootOptions().map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: AppTextStyles.caption),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  selectedRoot.value = newValue;
                  _handleFilter();
                }
              },
            )),
          ),
          const SizedBox(width: 8),
          _buildQuickActionButton(Icons.clear_rounded, Colors.red, () {
            selectedRoot.value = 'All';
            _handleFilter();
          }),
        ],
      ),
    );
  }

  List<String> _getRootOptions() {
    final roots = creditHistoryController.creditList
        .map((credit) => credit.root)
        .where((root) => root.isNotEmpty)
        .toSet()
        .toList();
    roots.insert(0, 'All');
    return roots;
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
      _handleFilter();
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  Widget _buildCreditsList() {
    return Obx(() {
      final bool isLoading = creditHistoryController.isLoading;
      final bool hasError = creditHistoryController.hasError;
      final bool isLoadingMore = creditHistoryController.isLoadingMore;
      final List<Credit> currentFilteredCredits = filteredCredits;

      if (isLoading && currentFilteredCredits.isEmpty) {
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

      if (hasError && currentFilteredCredits.isEmpty) {
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
              Text('Error loading credits',
                  style: AppTextStyles.heading2.copyWith(color: Colors.red)),
              const SizedBox(height: 8),
              Text(creditHistoryController.errorMessage,
                  style: AppTextStyles.body2
                      .copyWith(color: AppColors.grey.withOpacity(0.7)),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => creditHistoryController.retry(),
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

      if (currentFilteredCredits.isEmpty) {
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
              Icon(Icons.account_balance_wallet_outlined,
                  size: 64, color: Colors.green.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('No credits found',
                  style:
                  AppTextStyles.heading2.copyWith(color: Colors.green)),
              const SizedBox(height: 8),
              Text('No credit history available or try adjusting the filters',
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
          itemCount: currentFilteredCredits.length + (isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the bottom when loading more
            if (index == currentFilteredCredits.length) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            return _buildCreditCard(currentFilteredCredits[index]);
          },
        ),
      );
    });
  }

  Widget _buildCreditCard(Credit credit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
              color: Colors.green.withOpacity(0.1),
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
                        Text('Credit #${credit.id}',
                            style: AppTextStyles.heading2
                                .copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('CREDIT',
                              style: AppTextStyles.caption.copyWith(
                                  color: Colors.green,
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
                        Text(credit.formattedDate,
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.grey)),
                      ],
                    ),
                    if (credit.root.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.category_rounded,
                              size: 14, color: AppColors.grey),
                          const SizedBox(width: 4),
                          Text(credit.root,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.grey)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('₹${_formatAmount(credit.amount)}',
                      style: AppTextStyles.heading2.copyWith(
                          fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 10, color: Colors.blue),
                        const SizedBox(width: 3),
                        Text('Customer ID: ${credit.customerId}',
                            style: AppTextStyles.caption.copyWith(
                                color: Colors.blue,
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
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline_rounded,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 6),
                      Text('Credit Added',
                          style: AppTextStyles.caption.copyWith(
                              color: Colors.green,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 100000) return '${(amount / 100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}K';
    return amount.toStringAsFixed(2);
  }
}