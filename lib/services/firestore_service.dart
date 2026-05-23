import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';
import '../models/user_model.dart';

/// All Firestore reads/writes live here, grouped by domain.
class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ════════════════════════════════════════════════════════════════════════
  // ORDERS
  // ════════════════════════════════════════════════════════════════════════

  /// Save the order to `orders/{auto-id}` and return the new doc id.
  static Future<String> placeOrder(OrderModel order) async {
    final ref = await _db.collection('orders').add(order.toMap());
    return ref.id;
  }

  /// Live stream of a user's orders, newest first (sorted client-side).
  static Stream<List<OrderModel>> userOrdersStream(String uid) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map(OrderModel.fromFirestore).toList();
      orders.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      return orders;
    });
  }

  static Future<OrderModel?> getOrder(String orderId) async {
    final doc = await _db.collection('orders').doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromFirestore(doc);
  }

  // ════════════════════════════════════════════════════════════════════════
  // USERS
  // ════════════════════════════════════════════════════════════════════════

  /// Live stream of the user's profile doc. Emits null if the doc doesn't exist.
  static Stream<UserModel?> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  /// One-time fetch of the user doc.
  static Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Update part of the user doc (uses set with merge so it works even if
  /// the doc didn't exist yet).
  static Future<void> updateUser(
    String uid, {
    String? name,
    String? phone,
    String? address,
  }) async {
    final updates = <String, dynamic>{};
    if (name    != null) updates['name']    = name;
    if (phone   != null) updates['phone']   = phone;
    if (address != null) updates['address'] = address;
    if (updates.isEmpty) return;

    await _db.collection('users').doc(uid).set(
          updates,
          SetOptions(merge: true),
        );
  }
}