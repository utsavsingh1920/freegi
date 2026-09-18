class FreegiOrderItem {
  final String name;
  final String unit;
  final int price;
  final int quantity;
  final String image;

  const FreegiOrderItem({
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.image,
  });

  int get total => price * quantity;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }

  factory FreegiOrderItem.fromJson(Map<String, dynamic> json) {
    return FreegiOrderItem(
      name: json['name']?.toString() ?? '',
      unit: json['unit']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image']?.toString() ?? '',
    );
  }
}

class FreegiOrder {
  final String orderId;
  final List<FreegiOrderItem> items;

  final int itemTotal;
  final int discount;
  final int deliveryFee;
  final int platformFee;
  final int totalAmount;

  final String paymentMethod;

  final String addressType;
  final String deliveryAddress;
  final String landmark;
  final String area;
  final String city;
  final String state;
  final String postalCode;

  final String deliverySlot;

  final String status;
  final String type;

  final DateTime placedAt;

  const FreegiOrder({
    required this.orderId,
    required this.items,
    required this.itemTotal,
    required this.discount,
    required this.deliveryFee,
    required this.platformFee,
    required this.totalAmount,
    required this.paymentMethod,
    required this.addressType,
    required this.deliveryAddress,
    required this.landmark,
    required this.area,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.deliverySlot,
    required this.status,
    required this.type,
    required this.placedAt,
  });

  int get itemCount {
    return items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  List<String> get productNames {
    return items.map((item) => item.name).toList();
  }

  List<String> get productImages {
    return items.map((item) => item.image).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'items': items.map((item) => item.toJson()).toList(),
      'itemTotal': itemTotal,
      'discount': discount,
      'deliveryFee': deliveryFee,
      'platformFee': platformFee,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'addressType': addressType,
      'deliveryAddress': deliveryAddress,
      'landmark': landmark,
      'area': area,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'deliverySlot': deliverySlot,
      'status': status,
      'type': type,
      'placedAt': placedAt.toIso8601String(),
    };
  }

  factory FreegiOrder.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];

    return FreegiOrder(
      orderId: json['orderId']?.toString() ?? '',
      items: rawItems is List
          ? rawItems
              .whereType<Map>()
              .map(
                (item) => FreegiOrderItem.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : <FreegiOrderItem>[],
      itemTotal:
          (json['itemTotal'] as num?)?.toInt() ?? 0,
      discount:
          (json['discount'] as num?)?.toInt() ?? 0,
      deliveryFee:
          (json['deliveryFee'] as num?)?.toInt() ?? 0,
      platformFee:
          (json['platformFee'] as num?)?.toInt() ?? 0,
      totalAmount:
          (json['totalAmount'] as num?)?.toInt() ?? 0,
      paymentMethod:
          json['paymentMethod']?.toString() ?? 'COD',
      addressType:
          json['addressType']?.toString() ?? 'Home',
      deliveryAddress:
          json['deliveryAddress']?.toString() ?? '',
      landmark:
          json['landmark']?.toString() ?? '',
      area:
          json['area']?.toString() ?? '',
      city:
          json['city']?.toString() ?? '',
      state:
          json['state']?.toString() ?? '',
      postalCode:
          json['postalCode']?.toString() ?? '',
      deliverySlot:
          json['deliverySlot']?.toString() ??
              '25 - 35 minutes',
      status:
          json['status']?.toString() ??
              'Order Confirmed',
      type:
          json['type']?.toString() ?? 'active',
      placedAt: DateTime.tryParse(
            json['placedAt']?.toString() ?? '',
          ) ??
          DateTime.now(),
    );
  }

  FreegiOrder copyWith({
    String? status,
    String? type,
  }) {
    return FreegiOrder(
      orderId: orderId,
      items: items,
      itemTotal: itemTotal,
      discount: discount,
      deliveryFee: deliveryFee,
      platformFee: platformFee,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      addressType: addressType,
      deliveryAddress: deliveryAddress,
      landmark: landmark,
      area: area,
      city: city,
      state: state,
      postalCode: postalCode,
      deliverySlot: deliverySlot,
      status: status ?? this.status,
      type: type ?? this.type,
      placedAt: placedAt,
    );
  }
}