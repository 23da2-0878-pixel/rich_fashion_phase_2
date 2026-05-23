import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/product_image.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: provider.cartItems.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              subtitle: 'Add a few elegant picks and they will appear here.',
              buttonLabel: 'Continue Shopping',
              onPressed: () => Navigator.pop(context),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    itemBuilder: (context, index) {
                      final item = provider.cartItems[index];
                      return Dismissible(
                        key: ValueKey(item.id ?? '${item.product.id}-${item.selectedSize}'),
                        onDismissed: (_) => provider.removeFromCart(item),
                        background: Container(
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 96,
                                height: 112,
                                child: ProductImage(
                                  path: item.product.imagePaths.first,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, style: Theme.of(context).textTheme.titleMedium),
                                    const SizedBox(height: 4),
                                    Text(item.product.subtitle, style: Theme.of(context).textTheme.bodySmall),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${AppConstants.currency} ${item.product.price.toStringAsFixed(0)}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: AppColors.success,
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 10,
                                      runSpacing: 10,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        if (item.selectedSize != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: AppColors.soft,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text('Size: ${item.selectedSize}'),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.soft,
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                constraints: const BoxConstraints(),
                                                padding: EdgeInsets.zero,
                                                onPressed: () => provider.decreaseQuantity(item),
                                                icon: const Icon(Icons.remove_rounded, size: 18),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                                ),
                                              ),
                                              IconButton(
                                                constraints: const BoxConstraints(),
                                                padding: EdgeInsets.zero,
                                                onPressed: () => provider.increaseQuantity(item),
                                                icon: const Icon(Icons.add_rounded, size: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemCount: provider.cartItems.length,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(label: 'Subtotal', value: provider.subtotal),
                      const SizedBox(height: 8),
                      _SummaryRow(label: 'Shipping', value: provider.shipping),
                      const SizedBox(height: 12),
                      _SummaryRow(label: 'Total', value: provider.total, bold: true),
                      const SizedBox(height: 16),
                      AppButton(
                        label: 'Proceed to Checkout',
                        onPressed: () => Navigator.pushNamed(context, CheckoutScreen.routeName),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = (bold ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.bodyLarge)?.copyWith(
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        );

    return Row(
      children: [
        Text(label, style: style),
        const Spacer(),
        Text('${AppConstants.currency} ${value.toStringAsFixed(0)}', style: style),
      ],
    );
  }
}