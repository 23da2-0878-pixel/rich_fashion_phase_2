import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item_model.dart';

// ── A single line item inside an order ───────────────────────────────────────
class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int    quantity;
  final String? size;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.size,
  });

  double get total => price * quantity;

  Map<String, dynamic> toMap() => {
        'productId':    productId,
        'productName':  productName,
        'productImage': productImage,
        'price':        price,
        'quantity':     quantity,
        'size':         size,
      };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
        productId:    map['productId']    as String? ?? '',
        productName:  map['productName']  as String? ?? '',
        productImage: map['productImage'] as String? ?? '',
        price:        (map['price']    as num).toDouble(),
        quantity:     (map['quantity'] as num).toInt(),
        size:         map['size'] as String?,
      );

  factory OrderItem.fromCartItem(CartItemModel cartItem) => OrderItem(
        productId:    cartItem.product.id,
        productName:  cartItem.product.name,
        productImage: cartItem.product.imagePaths.isNotEmpty
            ? cartItem.product.imagePaths.first
            : '',
        price:        cartItem.product.price,
        quantity:     cartItem.quantity,
        size:         cartItem.selectedSize,
      );
}

// ── Delivery address embedded in the order ───────────────────────────────────
class DeliveryAddress {
  final String name;
  final String phone;
  final String address;
  final String city;
  final String postalCode;

  const DeliveryAddress({
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
  });

  Map<String, dynamic> toMap() => {
        'name':       name,
        'phone':      phone,
        'address':    address,
        'city':       city,
        'postalCode': postalCode,
      };

  factory DeliveryAddress.fromMap(Map<String, dynamic> map) => DeliveryAddress(
        name:       map['name']       as String? ?? '',
        phone:      map['phone']      as String? ?? '',
        address:    map['address']    as String? ?? '',
        city:       map['city']       as String? ?? '',
        postalCode: map['postalCode'] as String? ?? '',
      );
}

// ── The full order ───────────────────────────────────────────────────────────
class OrderModel {
  final String? id;          // Firestore doc id (null before save)
  final String userId;
  final List<OrderItem> items;
  final double subtotal;
  final double shipping;
  final double total;
  final DeliveryAddress deliveryAddress;
  final String paymentMethod;
  final String status;
  final DateTime? createdAt;

  const OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.status    = 'Pending',
    this.createdAt,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  Map<String, dynamic> toMap() => {
        'userId':          userId,
        'items':           items.map((i) => i.toMap()).toList(),
        'subtotal':        subtotal,
        'shipping':        shipping,
        'total':           total,
        'deliveryAddress': deliveryAddress.toMap(),
        'paymentMethod':   paymentMethod,
        'status':          status,
        'createdAt':       FieldValue.serverTimestamp(),
      };

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['createdAt'] as Timestamp?;
    return OrderModel(
      id:        doc.id,
      userId:    data['userId'] as String? ?? '',
      items:     (data['items'] as List<dynamic>? ?? [])
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
      subtotal:  (data['subtotal'] as num? ?? 0).toDouble(),
      shipping:  (data['shipping'] as num? ?? 0).toDouble(),
      total:     (data['total']    as num? ?? 0).toDouble(),
      deliveryAddress: DeliveryAddress.fromMap(
        data['deliveryAddress'] as Map<String, dynamic>? ?? {},
      ),
      paymentMethod: data['paymentMethod'] as String? ?? 'Cash on Delivery',
      status:        data['status']        as String? ?? 'Pending',
      createdAt:     timestamp?.toDate(),
    );
  }
}