class LedgerModel {
  final double lendAmount;
  final String advanceBalance;
  final double pendingBalance;
  final double totalLedgerBalance;
  final String creditsLimit;
  final String availableCredits;
  final double totalBillAmount;
  final double totalReceivedAmount;

  LedgerModel({
    required this.lendAmount,
    required this.advanceBalance,
    required this.pendingBalance,
    required this.totalLedgerBalance,
    required this.creditsLimit,
    required this.availableCredits,
    required this.totalBillAmount,
    required this.totalReceivedAmount,
  });

  factory LedgerModel.fromJson(Map<String, dynamic> json) {
    return LedgerModel(
      lendAmount: (json['lend_amount'] ?? 0).toDouble(),
      advanceBalance: json['advance_balance']?.toString() ?? '0',
      pendingBalance: (json['pending_balance'] ?? 0).toDouble(),
      totalLedgerBalance: (json['total_ledger_balance'] ?? 0).toDouble(),
      creditsLimit: json['credits_limit']?.toString() ?? '0',
      availableCredits: json['available_credits']?.toString() ?? '0',
      totalBillAmount: (json['total_bill_amount'] ?? 0).toDouble(),
      totalReceivedAmount: (json['total_received_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lend_amount': lendAmount,
      'advance_balance': advanceBalance,
      'pending_balance': pendingBalance,
      'total_ledger_balance': totalLedgerBalance,
      'credits_limit': creditsLimit,
      'available_credits': availableCredits,
      'total_bill_amount': totalBillAmount,
      'total_received_amount': totalReceivedAmount,
    };
  }
}
