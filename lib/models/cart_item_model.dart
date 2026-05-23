import 'package:cloud_firestore/cloud_firestore.dart';

import 'product_model.dart';

class CartItemModel {
  final String? id;          // Firestore doc ID (null until saved)
  final ProductModel product;
  int quantity;
  String? selectedSize;

  CartItemModel({
    this.id,
    required this.product,
    this.quantity = 1,
    this.selectedSize,
  });

  double get total => product.price * quantity;

  // ── Convert to Firestore map for saving ──────────────────────────────────
  Map<String, dynamic> toFirestoreMap() {
    return {
      'productId':    product.id,
      'selectedSize': selectedSize,
      'quantity':     quantity,
      'addedAt':      FieldValue.serverTimestamp(),
    };
  }
}