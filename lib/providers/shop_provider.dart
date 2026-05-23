import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class ShopProvider extends ChangeNotifier {
  final FirebaseFirestore _db   = FirebaseFirestore.instance;
  final FirebaseAuth      _auth = FirebaseAuth.instance;

  // ── Products ──────────────────────────────────────────────────────────────
  List<ProductModel> _products = [];
  bool   _isLoading = true;
  String? _error;

  List<ProductModel> get allProducts => _products;
  bool               get isLoading   => _isLoading;
  String?            get error       => _error;

  List<ProductModel> get featuredProducts =>
      _products.where((p) => p.isFeatured).toList();

  // ── Cart ──────────────────────────────────────────────────────────────────
  // Raw cart data from Firestore: { id, productId, selectedSize, quantity }
  List<Map<String, dynamic>> _rawCartData = [];

  // Hydrated cart items (raw data joined with products)
  List<CartItemModel> _cartItems = [];

  StreamSubscription? _cartSubscription;
  StreamSubscription? _authSubscription;

  List<CartItemModel> get cartItems => List.unmodifiable(_cartItems);

  int    get cartCount => _cartItems.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal  => _cartItems.fold(0, (sum, i) => sum + i.total);
  double get shipping  => _cartItems.isEmpty ? 0 : 250;
  double get total     => subtotal + shipping;

  // ── Wishlist (still local for now) ────────────────────────────────────────
  final Set<String> _wishlistIds = {};
  Set<String>       get wishlistIds => _wishlistIds;
  List<ProductModel> get wishlistProducts =>
      _products.where((p) => _wishlistIds.contains(p.id)).toList();

  // ── Filters ───────────────────────────────────────────────────────────────
  String _selectedCategory = 'All';
  String _searchQuery      = '';
  String get selectedCategory => _selectedCategory;
  String get searchQuery      => _searchQuery;

  // ── Constructor ───────────────────────────────────────────────────────────
  ShopProvider() {
    _listenToProducts();
    // Auto-switch cart when user logs in / out
    _authSubscription = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  // ── Product stream ────────────────────────────────────────────────────────
  void _listenToProducts() {
    _db.collection('products').snapshots().listen(
      (snapshot) {
        _products  = snapshot.docs.map(ProductModel.fromFirestore).toList();
        _isLoading = false;
        _error     = null;
        _rebuildCart();  // cart items depend on products
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error     = 'Failed to load products. Please check your connection.';
        notifyListeners();
      },
    );
  }

  // ── Auth state listener ───────────────────────────────────────────────────
  void _onAuthStateChanged(User? user) {
    // Cancel previous cart subscription (different user or logged out)
    _cartSubscription?.cancel();
    _rawCartData = [];
    _cartItems   = [];

    if (user != null) {
      _listenToCart(user.uid);
    } else {
      notifyListeners();  // cart cleared
    }
  }

  // ── Cart stream ───────────────────────────────────────────────────────────
  void _listenToCart(String uid) {
    _cartSubscription = _db
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots()
        .listen(
      (snapshot) {
        _rawCartData = snapshot.docs.map((doc) => {
              'id': doc.id,
              ...doc.data(),
            }).toList();
        _rebuildCart();
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Cart stream error: $e');
      },
    );
  }

  // Join raw cart data with the products list
  void _rebuildCart() {
    _cartItems = _rawCartData
        .map((raw) {
          try {
            final product =
                _products.firstWhere((p) => p.id == raw['productId']);
            return CartItemModel(
              id:           raw['id'] as String,
              product:      product,
              quantity:     (raw['quantity'] as num).toInt(),
              selectedSize: raw['selectedSize'] as String?,
            );
          } catch (_) {
            return null;  // product not loaded yet or deleted
          }
        })
        .whereType<CartItemModel>()
        .toList();
  }

  // ── Filtering & search ────────────────────────────────────────────────────
  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  List<ProductModel> filteredProducts({String? categoryOverride}) {
    final category = categoryOverride ?? _selectedCategory;
    return _products.where((p) {
      final categoryMatch = category == 'All' || p.category == category;
      final q = _searchQuery.toLowerCase();
      final searchMatch = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.subtitle.toLowerCase().contains(q);
      return categoryMatch && searchMatch;
    }).toList();
  }

  // ── Wishlist ──────────────────────────────────────────────────────────────
  bool isInWishlist(String productId) => _wishlistIds.contains(productId);

  void toggleWishlist(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  // ── Cart mutations (all write to Firestore) ───────────────────────────────
  bool isInCart(String productId) =>
      _cartItems.any((item) => item.product.id == productId);

  Future<void> addToCart(ProductModel product, {String? size}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('addToCart: no user logged in');
      return;
    }

    final cartRef = _db.collection('users').doc(uid).collection('cart');

    // If same product + size is already in cart, just increment quantity
    final existing = await cartRef
        .where('productId',    isEqualTo: product.id)
        .where('selectedSize', isEqualTo: size)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      await existing.docs.first.reference.update({
        'quantity': FieldValue.increment(1),
      });
    } else {
      await cartRef.add({
        'productId':    product.id,
        'selectedSize': size,
        'quantity':     1,
        'addedAt':      FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> increaseQuantity(CartItemModel item) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || item.id == null) return;
    await _db
        .collection('users').doc(uid)
        .collection('cart').doc(item.id)
        .update({'quantity': FieldValue.increment(1)});
  }

  Future<void> decreaseQuantity(CartItemModel item) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || item.id == null) return;
    final docRef = _db
        .collection('users').doc(uid)
        .collection('cart').doc(item.id);
    if (item.quantity > 1) {
      await docRef.update({'quantity': FieldValue.increment(-1)});
    } else {
      await docRef.delete();
    }
  }

  Future<void> removeFromCart(CartItemModel item) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || item.id == null) return;
    await _db
        .collection('users').doc(uid)
        .collection('cart').doc(item.id)
        .delete();
  }

  Future<void> clearCart() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final cartRef = _db.collection('users').doc(uid).collection('cart');
    final snapshot = await cartRef.get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}