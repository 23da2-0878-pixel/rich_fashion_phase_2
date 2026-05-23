import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final double rating;
  final int reviews;
  final List<String> imagePaths; // asset paths OR https:// URLs
  final String description;
  final List<String> sizes;
  final List<Color> colors;
  final bool isFeatured;
  final bool isNew;
  final String subtitle;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.imagePaths,
    required this.description,
    required this.sizes,
    required this.colors,
    this.isFeatured = false,
    this.isNew = false,
    this.subtitle = '',
  });

  // ── Build a ProductModel from a Firestore document ─────────────────────────
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Colors are stored as hex strings e.g. "FF7A1F2B"
    final rawColors = (data['colors'] as List<dynamic>?)?.cast<String>() ?? [];
    final colors = rawColors.map((hex) {
      final value = int.tryParse(hex, radix: 16) ?? 0xFF000000;
      return Color(value);
    }).toList();

    return ProductModel(
      id:          doc.id,
      name:        data['name']        as String? ?? '',
      category:    data['category']    as String? ?? '',
      price:       (data['price']      as num).toDouble(),
      rating:      (data['rating']     as num).toDouble(),
      reviews:     (data['reviews']    as num).toInt(),
      imagePaths:  (data['imageUrls']  as List<dynamic>?)?.cast<String>() ?? [],
      description: data['description'] as String? ?? '',
      sizes:       (data['sizes']      as List<dynamic>?)?.cast<String>() ?? [],
      colors:      colors,
      isFeatured:  data['isFeatured']  as bool? ?? false,
      isNew:       data['isNew']       as bool? ?? false,
      subtitle:    data['subtitle']    as String? ?? '',
    );
  }

  // ── Convert to Map (used when seeding Firestore manually) ─────────────────
  Map<String, dynamic> toMap() {
    return {
      'name':        name,
      'category':    category,
      'price':       price,
      'rating':      rating,
      'reviews':     reviews,
      'imageUrls':   imagePaths,
      'description': description,
      'sizes':       sizes,
      // Store colors as 8-char hex strings "AARRGGBB"
      'colors':      colors.map((c) => c.value.toRadixString(16).padLeft(8, '0')).toList(),
      'isFeatured':  isFeatured,
      'isNew':       isNew,
      'subtitle':    subtitle,
    };
  }
}