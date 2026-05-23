import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Call seedProducts() once to push all 10 products into Firestore.
/// It checks if products already exist before writing — safe to call on every run.
class SeedService {
  static final _db = FirebaseFirestore.instance;

  static const _productDescription =
      'Elevate your wardrobe with breathable, premium fabrics and elegant ethnic styling. '
      'This collection blends graceful silhouettes, festive details, and daily-wear comfort, '
      'making it ideal for both casual outings and special occasions.';

  static Future<void> seedProducts() async {
    final collection = _db.collection('products');

    // Check if already seeded — if p1 exists, skip
    final existing = await collection.doc('p1').get();
    if (existing.exists) {
      debugPrint('SeedService: products already seeded, skipping.');
      return;
    }

    debugPrint('SeedService: seeding 10 products into Firestore...');

    final products = _buildProducts();
    final batch = _db.batch();

    for (final product in products) {
      final ref = collection.doc(product['id'] as String);
      final data = Map<String, dynamic>.from(product)..remove('id');
      batch.set(ref, data);
    }

    await batch.commit();
    debugPrint('SeedService: done — ${products.length} products seeded.');
  }

  static List<Map<String, dynamic>> _buildProducts() {
    return [
      {
        'id': 'p1',
        'name': 'Maroon Heritage Kurti Set',
        'category': 'Festive',
        'price': 5400.0,
        'rating': 4.8,
        'reviews': 128,
        'imageUrls': ['assets/images/products/product_maroon_kurti.jpg'],
        'description': _productDescription,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['ff7a1f2b', 'ffb85c38', 'ff232323'],
        'isFeatured': true,
        'isNew': true,
        'subtitle': 'Marwar collection inspired',
      },
      {
        'id': 'p2',
        'name': 'Sky Blue Long Gown Kurti',
        'category': 'Premium',
        'price': 4700.0,
        'rating': 4.6,
        'reviews': 92,
        'imageUrls': ['assets/images/products/product_skyblue_gown.jpg'],
        'description': _productDescription,
        'sizes': ['S', 'M', 'L'],
        'colors': ['ff8dd8f2', 'ffe8f3f6'],
        'isFeatured': true,
        'isNew': false,
        'subtitle': 'Flowy silhouette with tassel detail',
      },
      {
        'id': 'p3',
        'name': 'Emerald Panel Kurti Set',
        'category': 'Festive',
        'price': 4300.0,
        'rating': 4.5,
        'reviews': 76,
        'imageUrls': ['assets/images/products/product_green_set.jpg'],
        'description': _productDescription,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['ff0c6b4f', 'ffc64b4b'],
        'isFeatured': true,
        'isNew': false,
        'subtitle': 'Elegant contrast bottom styling',
      },
      {
        'id': 'p4',
        'name': 'Rose Embroidered Suit',
        'category': 'Premium',
        'price': 6900.0,
        'rating': 4.9,
        'reviews': 144,
        'imageUrls': ['assets/images/products/product_pink_suit.jpg'],
        'description': _productDescription,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['ffe98ca6', 'fff7d9df'],
        'isFeatured': false,
        'isNew': false,
        'subtitle': 'Festive look with detailed embroidery',
      },
      {
        'id': 'p5',
        'name': 'Blue Floral Anarkali',
        'category': 'Printed',
        'price': 5900.0,
        'rating': 4.7,
        'reviews': 118,
        'imageUrls': ['assets/images/products/product_blue_floral.jpg'],
        'description': _productDescription,
        'sizes': ['S', 'M', 'L'],
        'colors': ['ff2d5d8c', 'ffdceaf7'],
        'isFeatured': false,
        'isNew': false,
        'subtitle': 'Classic floral print and dupatta',
      },
      {
        'id': 'p6',
        'name': 'Amber Statement Kurti Set',
        'category': 'Casual',
        'price': 3800.0,
        'rating': 4.4,
        'reviews': 51,
        'imageUrls': ['assets/images/products/product_orange_set.jpg'],
        'description': _productDescription,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['ffd9772b', 'ff663300'],
        'isFeatured': false,
        'isNew': true,
        'subtitle': 'Vibrant statement everyday wear',
      },
      {
        'id': 'p7',
        'name': 'Navy Panel Dress',
        'category': 'Casual',
        'price': 3200.0,
        'rating': 4.3,
        'reviews': 39,
        'imageUrls': ['assets/images/products/product_navy_dress.jpg'],
        'description': _productDescription,
        'sizes': ['S', 'M', 'L'],
        'colors': ['ff1d3557', 'fff6f8fb'],
        'isFeatured': false,
        'isNew': false,
        'subtitle': 'Minimal evening-ready dress',
      },
      {
        'id': 'p8',
        'name': 'Mint Stripe Cotton Kurti',
        'category': 'Casual',
        'price': 2600.0,
        'rating': 4.2,
        'reviews': 33,
        'imageUrls': ['assets/images/products/product_mint_stripe.jpg'],
        'description': _productDescription,
        'sizes': ['S', 'M', 'L', 'XL'],
        'colors': ['ff8ed8d3', 'ffffffff'],
        'isFeatured': false,
        'isNew': false,
        'subtitle': 'Breathable cotton for daily use',
      },
      {
        'id': 'p9',
        'name': 'White Embroidery Lawn Kurti',
        'category': 'Printed',
        'price': 4100.0,
        'rating': 4.8,
        'reviews': 102,
        'imageUrls': ['assets/images/products/product_white_embroidery.jpg'],
        'description': _productDescription,
        'sizes': ['S', 'M', 'L'],
        'colors': ['ffffffff', 'ffc43f71', 'ff799940'],
        'isFeatured': false,
        'isNew': false,
        'subtitle': 'Fresh floral embroidery finish',
      },
      {
        'id': 'p10',
        'name': 'Ivory Paisley Printed Suit',
        'category': 'Premium',
        'price': 5200.0,
        'rating': 4.6,
        'reviews': 67,
        'imageUrls': ['assets/images/products/product_white_print.jpg'],
        'description': _productDescription,
        'sizes': ['M', 'L', 'XL'],
        'colors': ['fff4efe8', 'ff453c55'],
        'isFeatured': false,
        'isNew': false,
        'subtitle': 'Soft printed set with dupatta',
      },
    ];
  }
}