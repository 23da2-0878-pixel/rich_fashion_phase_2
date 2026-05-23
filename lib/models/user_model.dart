import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user document at `users/{uid}` in Firestore.
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone   = '',
    this.address = '',
    this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts   = data['createdAt'] as Timestamp?;
    return UserModel(
      uid:       doc.id,
      name:      data['name']    as String? ?? '',
      email:     data['email']   as String? ?? '',
      phone:     data['phone']   as String? ?? '',
      address:   data['address'] as String? ?? '',
      createdAt: ts?.toDate(),
    );
  }

  /// A blank user (used when the Firestore doc doesn't exist yet).
  factory UserModel.empty(String uid, String? email) => UserModel(
        uid:   uid,
        name:  '',
        email: email ?? '',
      );
}