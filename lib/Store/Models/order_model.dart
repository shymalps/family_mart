// Models/order_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'order_model.g.dart';

// =====================
// Request Models
// =====================

@JsonSerializable()
class OrderListRequest {
  @JsonKey(name: 'user_id')
  final int userId;
  final int? offset;
  final int? limit;

  const OrderListRequest({
    required this.userId,
    this.offset,
    this.limit = 20,
  });

  factory OrderListRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderListRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OrderListRequestToJson(this);
}

@JsonSerializable()
class OrderDetailsRequest {
  @JsonKey(name: 'order_id')
  final String orderId;

  const OrderDetailsRequest({
    required this.orderId,
  });

  factory OrderDetailsRequest.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsRequestToJson(this);
}

// =====================
// Response Models
// =====================

@JsonSerializable()
class OrderListResponse {
  final String status;
  final String msg;
  final List<Order> data;
  @JsonKey(name: 'total_count')
  final int? totalCount;
  @JsonKey(name: 'has_more')
  final bool? hasMore;

  const OrderListResponse({
    required this.status,
    required this.msg,
    required this.data,
    this.totalCount,
    this.hasMore,
  });

  factory OrderListResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderListResponseToJson(this);

  bool get isSuccess => status.toLowerCase() == 'success';
}

@JsonSerializable()
class OrderDetailsResponse {
  final String status;
  final String msg;
  final OrderDetailsData data;

  const OrderDetailsResponse({
    required this.status,
    required this.msg,
    required this.data,
  });

  factory OrderDetailsResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderDetailsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OrderDetailsResponseToJson(this);

  bool get isSuccess => status.toLowerCase() == 'success';
}

@JsonSerializable()
class OrderDetailsData {
  @JsonKey(name: 'order_id')
  final String orderId;

  @JsonKey(name: 'total_count')
  final int totalCount;

  @JsonKey(name: 'total_amount')
  final double totalAmount;

  final List<OrderItem> items;

  OrderDetailsData({
    required this.orderId,
    required this.totalCount,
    required this.totalAmount,
    required this.items,
  });

  factory OrderDetailsData.fromJson(Map<String, dynamic> json) {
    final items = <OrderItem>[];

    // Handle dynamic keys for items
    json.forEach((key, value) {
      if (key != 'order_id' &&
          key != 'total_count' &&
          key != 'total_amount' &&
          value is Map<String, dynamic>) {
        try {
          items.add(OrderItem.fromJson(value));
        } catch (e) {
          print('Error parsing order item with key $key: $e');
        }
      }
    });

    return OrderDetailsData(
      orderId: json['order_id']?.toString() ?? '',
      totalCount: int.tryParse(json['total_count']?.toString() ?? '0') ?? 0,
      totalAmount: _toDouble(json['total_amount']),
      items: items,
    );
  }

  Map<String, dynamic> toJson() {
    final json = _$OrderDetailsDataToJson(this);
    // Add items with their indices as keys
    for (int i = 0; i < items.length; i++) {
      json[i.toString()] = items[i].toJson();
    }
    return json;
  }

  OrderDetailsData copyWith({
    String? orderId,
    int? totalCount,
    double? totalAmount,
    List<OrderItem>? items,
  }) {
    return OrderDetailsData(
      orderId: orderId ?? this.orderId,
      totalCount: totalCount ?? this.totalCount,
      totalAmount: totalAmount ?? this.totalAmount,
      items: items ?? this.items,
    );
  }
}

// =====================
// Data Models
// =====================

@JsonSerializable()
class Order {
  @JsonKey(fromJson: _stringFromDynamic, toJson: _stringToDynamic)
  final String id;

  @JsonKey(fromJson: _intFromDynamic)
  final int count;

  @JsonKey(fromJson: _doubleFromDynamic)
  final double amount;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'order_date')
  final String? orderDate;

  @JsonKey(name: 'delivery_date')
  final String? deliveryDate;

  @JsonKey(name: 'customer_name')
  final String? customerName;

  @JsonKey(name: 'customer_phone')
  final String? customerPhone;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isExpanded;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final List<OrderItem>? orderItems;

  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool isLoadingDetails;

  const Order({
    required this.id,
    required this.count,
    required this.amount,
    this.status,
    this.orderDate,
    this.deliveryDate,
    this.customerName,
    this.customerPhone,
    this.isExpanded = false,
    this.orderItems,
    this.isLoadingDetails = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  static String _stringFromDynamic(dynamic value) => value?.toString() ?? '';
  static dynamic _stringToDynamic(String value) => value;
  static int _intFromDynamic(dynamic value) => int.tryParse(value?.toString() ?? '0') ?? 0;
  static double _doubleFromDynamic(dynamic value) => _toDouble(value);

  Order copyWith({
    String? id,
    int? count,
    double? amount,
    String? status,
    String? orderDate,
    String? deliveryDate,
    String? customerName,
    String? customerPhone,
    bool? isExpanded,
    List<OrderItem>? orderItems,
    bool? isLoadingDetails,
  }) {
    return Order(
      id: id ?? this.id,
      count: count ?? this.count,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      isExpanded: isExpanded ?? this.isExpanded,
      orderItems: orderItems ?? this.orderItems,
      isLoadingDetails: isLoadingDetails ?? this.isLoadingDetails,
    );
  }

  // Getters with null safety
  String get formattedId => id.length > 6 ? id.substring(id.length - 6) : id;
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';
  bool get hasAmount => amount > 0;
  String get itemsText => count == 1 ? '$count item' : '$count items';
  OrderStatus? get orderStatus => OrderStatus.fromString(status);
  String get displayStatus => orderStatus?.displayName ?? (status ?? 'Unknown');

  // Date formatting helpers
  DateTime? get parsedOrderDate {
    if (orderDate == null) return null;
    try {
      return DateTime.parse(orderDate!);
    } catch (e) {
      return null;
    }
  }

  DateTime? get parsedDeliveryDate {
    if (deliveryDate == null) return null;
    try {
      return DateTime.parse(deliveryDate!);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Order && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Order(id: $id, count: $count, amount: $amount, status: $status)';
  }
}

@JsonSerializable()
class OrderItem {
  @JsonKey(fromJson: _stringFromDynamic)
  final String? id;

  final String? name;

  @JsonKey(name: 'sub_name')
  final String? subName;

  @JsonKey(name: 'sale_rate', fromJson: _doubleFromDynamic)
  final double? saleRate;

  @JsonKey(name: 'count', fromJson: _intFromDynamic)
  final int? quantity;

  // Changed: Map API's 'amount' field to 'total' instead of 'price'
  @JsonKey(name: 'amount', fromJson: _doubleFromDynamic)
  final double? total;

  @JsonKey(fromJson: _doubleFromDynamic)
  final double? price; // Keep this for unit price if available

  @JsonKey(fromJson: _doubleFromDynamic)
  final double? mrp;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @JsonKey(name: 'file_name')
  final String? fileName;

  final String? measurement;
  final String? value;
  final String? category;
  final String? description;

  const OrderItem({
    this.id,
    this.name,
    this.subName,
    this.quantity,
    this.price,
    this.saleRate,
    this.mrp,
    this.total,
    this.imageUrl,
    this.fileName,
    this.measurement,
    this.value,
    this.category,
    this.description,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  static String? _stringFromDynamic(dynamic value) => value?.toString();
  static int? _intFromDynamic(dynamic value) => int.tryParse(value?.toString() ?? '');
  static double? _doubleFromDynamic(dynamic value) => _toDouble(value);


  OrderItem copyWith({
    String? id,
    String? name,
    String? subName,
    int? quantity,
    double? price,
    double? saleRate,
    double? mrp,
    double? total,
    String? imageUrl,
    String? fileName,
    String? measurement,
    String? value,
    String? category,
    String? description,
  }) {
    return OrderItem(
      id: id ?? this.id,
      name: name ?? this.name,
      subName: subName ?? this.subName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      saleRate: saleRate ?? this.saleRate,
      mrp: mrp ?? this.mrp,
      total: total ?? this.total,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
      measurement: measurement ?? this.measurement,
      value: value ?? this.value,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }

  // Safe getters
  String get displayName => name ?? 'Unknown Product';
  String get formattedPrice {
    print('total');
    print(total);
    if (total != null && quantity != null && quantity! > 0) {
      final unitPrice = total! / quantity!;
      return '₹${unitPrice.toStringAsFixed(2)}';
    }
    final price = saleRate ?? this.price;
    return price != null ? '₹${price.toStringAsFixed(2)}' : '₹0.00';
  }
  String get formattedMrp => mrp != null ? '₹${mrp!.toStringAsFixed(2)}' : '';
  String get formattedTotal => total != null ? '₹${total!.toStringAsFixed(2)}' : 'hello';
  String get quantityText => 'Qty: ${quantity ?? 0}';
  String get measurementText {
    if (value != null && measurement != null) {
      return '$value$measurement';
    }
    return '';
  }

  bool get hasImage => fileName != null && fileName!.isNotEmpty;
  bool get hasDiscount => mrp != null && saleRate != null && saleRate! < mrp!;
  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((mrp! - saleRate!) / mrp!) * 100).round();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is OrderItem && id == other.id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'OrderItem(id: $id, name: $name, quantity: $quantity, price: $price)';
  }
}

// =====================
// Enums
// =====================

enum OrderStatus {
  pending('pending', 'Pending'),
  confirmed('confirmed', 'Confirmed'),
  processing('processing', 'Processing'),
  shipped('shipped', 'Shipped'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled'),
  returned('returned', 'Returned');

  const OrderStatus(this.value, this.displayName);

  final String value;
  final String displayName;

  static OrderStatus? fromString(String? value) {
    if (value == null) return null;
    try {
      return OrderStatus.values.firstWhere(
            (status) => status.value.toLowerCase() == value.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  bool get isCompleted => this == OrderStatus.delivered;
  bool get isPending => [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped
  ].contains(this);
  bool get isCancelled => this == OrderStatus.cancelled || this == OrderStatus.returned;
}

// =====================
// Filter and Sort Enums
// =====================

enum OrderSortBy {
  dateNewest('Date (Newest)'),
  dateOldest('Date (Oldest)'),
  amountHighest('Amount (Highest)'),
  amountLowest('Amount (Lowest)'),
  itemsCount('Items Count');

  const OrderSortBy(this.displayName);
  final String displayName;
}

enum OrderFilterBy {
  all('All Orders'),
  withAmount('With Amount'),
  withoutAmount('Without Amount'),
  lastWeek('Last Week'),
  lastMonth('Last Month'),
  lastThreeMonths('Last 3 Months');

  const OrderFilterBy(this.displayName);
  final String displayName;
}

// =====================
// Pagination
// =====================

@JsonSerializable()
class OrderPagination {
  final int currentOffset;
  final int pageSize;
  final bool hasMore;
  final int totalCount;

  const OrderPagination({
    this.currentOffset = 0,
    this.pageSize = 20,
    this.hasMore = true,
    this.totalCount = 0,
  });

  factory OrderPagination.fromJson(Map<String, dynamic> json) =>
      _$OrderPaginationFromJson(json);

  Map<String, dynamic> toJson() => _$OrderPaginationToJson(this);

  OrderPagination copyWith({
    int? currentOffset,
    int? pageSize,
    bool? hasMore,
    int? totalCount,
  }) {
    return OrderPagination(
      currentOffset: currentOffset ?? this.currentOffset,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  int get nextOffset => currentOffset + pageSize;
  bool get isFirstPage => currentOffset == 0;
  int get currentPage => (currentOffset / pageSize).floor() + 1;
  int get totalPages => totalCount > 0 ? (totalCount / pageSize).ceil() : 1;

  @override
  String toString() {
    return 'OrderPagination(offset: $currentOffset, pageSize: $pageSize, hasMore: $hasMore, total: $totalCount)';
  }
}


double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}