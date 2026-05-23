import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../providers/shop_provider.dart';
import '../../services/firestore_service.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/product_image.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _cityCtrl     = TextEditingController();
  final _postalCtrl   = TextEditingController();

  String _paymentMethod = 'Cash on Delivery';
  bool   _isPlacing     = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill name from Firebase Auth display name
    final user = FirebaseAuth.instance.currentUser;
    if (user?.displayName != null) {
      _nameCtrl.text = user!.displayName!;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    super.dispose();
  }

  // ── Place order: validate, save to Firestore, clear cart, navigate ───────
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ShopProvider>();
    final user     = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showError('Please log in to place an order.');
      return;
    }
    if (provider.cartItems.isEmpty) {
      _showError('Your cart is empty.');
      return;
    }

    setState(() => _isPlacing = true);

    try {
      final order = OrderModel(
        userId:   user.uid,
        items:    provider.cartItems.map(OrderItem.fromCartItem).toList(),
        subtotal: provider.subtotal,
        shipping: provider.shipping,
        total:    provider.total,
        deliveryAddress: DeliveryAddress(
          name:       _nameCtrl.text.trim(),
          phone:      _phoneCtrl.text.trim(),
          address:    _addressCtrl.text.trim(),
          city:       _cityCtrl.text.trim(),
          postalCode: _postalCtrl.text.trim(),
        ),
        paymentMethod: _paymentMethod,
      );

      // 1. Save to Firestore
      final orderId = await FirestoreService.placeOrder(order);

      // 2. Clear cart in Firestore
      await provider.clearCart();

      if (!mounted) return;

      // 3. Go to success screen with the order id
      Navigator.pushReplacementNamed(
        context,
        OrderSuccessScreen.routeName,
        arguments: orderId,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      _showError('Could not place order: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Delivery address form ──────────────────────────────────
              _SectionCard(
                title: 'Delivery Address',
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().length < 7
                              ? 'Enter a valid phone'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressCtrl,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _cityCtrl,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              labelText: 'City',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _postalCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Postal',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Order summary ──────────────────────────────────────────
              _SectionCard(
                title: 'Order Summary',
                child: Column(
                  children: [
                    ...provider.cartItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 58,
                              height: 58,
                              child: ProductImage(
                                path: item.product.imagePaths.isNotEmpty
                                    ? item.product.imagePaths.first
                                    : '',
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text('Qty: ${item.quantity}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                ],
                              ),
                            ),
                            Text(
                                '${AppConstants.currency} ${item.total.toStringAsFixed(0)}'),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    _CheckoutRow(label: 'Subtotal', value: provider.subtotal),
                    const SizedBox(height: 8),
                    _CheckoutRow(label: 'Shipping', value: provider.shipping),
                    const SizedBox(height: 12),
                    _CheckoutRow(
                        label: 'Total', value: provider.total, bold: true),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // ── Payment method ─────────────────────────────────────────
              _SectionCard(
                title: 'Payment Method',
                child: Column(
                  children: [
                    _PaymentOption(
                      label: 'Cash on Delivery',
                      groupValue: _paymentMethod,
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),
                    _PaymentOption(
                      label: 'Card',
                      groupValue: _paymentMethod,
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // ── Place order button ─────────────────────────────────────
              AppButton(
                label: _isPlacing ? 'Placing order...' : 'Place Order',
                onPressed: _isPlacing ? null : () => _placeOrder(),
                trailing: _isPlacing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.arrow_forward_rounded, size: 20),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline_rounded,
                      size: 16, color: AppColors.gold),
                  const SizedBox(width: 6),
                  Text(
                    'Your details are stored securely on Firebase',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── helper widgets ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _CheckoutRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  const _CheckoutRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = (bold
            ? Theme.of(context).textTheme.titleMedium
            : Theme.of(context).textTheme.bodyLarge)
        ?.copyWith(fontWeight: bold ? FontWeight.w800 : FontWeight.w500);
    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text('${AppConstants.currency} ${value.toStringAsFixed(0)}', style: style),
      ],
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String label;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.label,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: label,
      groupValue: groupValue,
      onChanged: onChanged,
      title: Text(label),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}