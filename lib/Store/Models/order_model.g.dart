// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderListRequest _$OrderListRequestFromJson(Map<String, dynamic> json) =>
    OrderListRequest(
      userId: (json['user_id'] as num).toInt(),
      offset: (json['offset'] as num?)?.toInt(),
      limit: (json['limit'] as num?)?.toInt() ?? 20,
    );

Map<String, dynamic> _$OrderListRequestToJson(OrderListRequest instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'offset': instance.offset,
      'limit': instance.limit,
    };

OrderDetailsRequest _$OrderDetailsRequestFromJson(Map<String, dynamic> json) =>
    OrderDetailsRequest(
      orderId: json['order_id'] as String,
    );

Map<String, dynamic> _$OrderDetailsRequestToJson(
        OrderDetailsRequest instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
    };

OrderListResponse _$OrderListResponseFromJson(Map<String, dynamic> json) =>
    OrderListResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => Order.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['total_count'] as num?)?.toInt(),
      hasMore: json['has_more'] as bool?,
    );

Map<String, dynamic> _$OrderListResponseToJson(OrderListResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
      'total_count': instance.totalCount,
      'has_more': instance.hasMore,
    };

OrderDetailsResponse _$OrderDetailsResponseFromJson(
        Map<String, dynamic> json) =>
    OrderDetailsResponse(
      status: json['status'] as String,
      msg: json['msg'] as String,
      data: OrderDetailsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderDetailsResponseToJson(
        OrderDetailsResponse instance) =>
    <String, dynamic>{
      'status': instance.status,
      'msg': instance.msg,
      'data': instance.data,
    };

OrderDetailsData _$OrderDetailsDataFromJson(Map<String, dynamic> json) =>
    OrderDetailsData(
      orderId: json['order_id'] as String,
      totalCount: (json['total_count'] as num).toInt(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderDetailsDataToJson(OrderDetailsData instance) =>
    <String, dynamic>{
      'order_id': instance.orderId,
      'total_count': instance.totalCount,
      'total_amount': instance.totalAmount,
      'items': instance.items,
    };

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      id: Order._stringFromDynamic(json['id']),
      count: Order._intFromDynamic(json['count']),
      amount: Order._doubleFromDynamic(json['amount']),
      status: json['status'] as String?,
      orderDate: json['order_date'] as String?,
      deliveryDate: json['delivery_date'] as String?,
      customerName: json['customer_name'] as String?,
      customerPhone: json['customer_phone'] as String?,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'id': Order._stringToDynamic(instance.id),
      'count': instance.count,
      'amount': instance.amount,
      'status': instance.status,
      'order_date': instance.orderDate,
      'delivery_date': instance.deliveryDate,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
    };

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      id: OrderItem._stringFromDynamic(json['id']),
      name: json['name'] as String?,
      subName: json['sub_name'] as String?,
      quantity: OrderItem._intFromDynamic(json['count']),
      price: OrderItem._doubleFromDynamic(json['price']),
      saleRate: OrderItem._doubleFromDynamic(json['sale_rate']),
      mrp: OrderItem._doubleFromDynamic(json['mrp']),
      total: OrderItem._doubleFromDynamic(json['amount']),
      imageUrl: json['image_url'] as String?,
      fileName: json['file_name'] as String?,
      measurement: json['measurement'] as String?,
      value: json['value'] as String?,
      category: json['category'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sub_name': instance.subName,
      'sale_rate': instance.saleRate,
      'count': instance.quantity,
      'amount': instance.total,
      'price': instance.price,
      'mrp': instance.mrp,
      'image_url': instance.imageUrl,
      'file_name': instance.fileName,
      'measurement': instance.measurement,
      'value': instance.value,
      'category': instance.category,
      'description': instance.description,
    };

OrderPagination _$OrderPaginationFromJson(Map<String, dynamic> json) =>
    OrderPagination(
      currentOffset: (json['currentOffset'] as num?)?.toInt() ?? 0,
      pageSize: (json['pageSize'] as num?)?.toInt() ?? 20,
      hasMore: json['hasMore'] as bool? ?? true,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$OrderPaginationToJson(OrderPagination instance) =>
    <String, dynamic>{
      'currentOffset': instance.currentOffset,
      'pageSize': instance.pageSize,
      'hasMore': instance.hasMore,
      'totalCount': instance.totalCount,
    };
