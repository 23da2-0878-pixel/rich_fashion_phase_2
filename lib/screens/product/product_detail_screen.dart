import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/common/app_button.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  String? _selectedSize;
  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as ProductModel;
    final provider = context.watch<ShopProvider>();
    _selectedSize ??= product.sizes.first;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 420,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  actions: [
                    IconButton(
                      onPressed: () => provider.toggleWishlist(product.id),
                      icon: Icon(
                        provider.isInWishlist(product.id)
                            ? Icons.favorite
                            : Icons.favorite_border_rounded,
                        color: provider.isInWishlist(product.id) ? AppColors.danger : AppColors.primary,
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'product-${product.id}',
                      child: Image.asset(product.imagePaths.first, fit: BoxFit.cover),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    transform: Matrix4.translationValues(0, -20, 0),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                            ),
                            Text(
                              '${AppConstants.currency} ${product.price.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppColors.success,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(product.subtitle, style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                            const SizedBox(width: 4),
                            Text(
                              '${product.rating} (${product.reviews} reviews)',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(AppConstants.deliveryText),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text('Select Size', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: product.sizes.map((size) {
                            final selected = _selectedSize == size;
                            return ChoiceChip(
                              label: Text(size),
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedSize = size),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 22),
                        Text('Select Color', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(product.colors.length, (index) {
                            final color = product.colors[index];
                            final selected = _selectedColorIndex == index;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColorIndex = index),
                              child: Container(
                                width: 34,
                                height: 34,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected ? AppColors.primary : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Text('Quantity', style: Theme.of(context).textTheme.titleMedium),
                            const Spacer(),
                            _StepperButton(
                              icon: Icons.remove_rounded,
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity -= 1);
                                }
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                '$_quantity',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            _StepperButton(
                              icon: Icons.add_rounded,
                              onTap: () => setState(() => _quantity += 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
                        Text('Details', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(product.description, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 20,
              right: 20,
              bottom: 18,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.98),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Add to Cart',
                        onPressed: () {
                          for (var i = 0; i < _quantity; i++) {
                            provider.addToCart(product, size: _selectedSize);
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        },
                        backgroundColor: AppColors.soft,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: provider.isInCart(product.id) ? 'Go To Cart' : 'Buy Now',
                        onPressed: () {
                          provider.addToCart(product, size: _selectedSize);
                          Navigator.pushNamed(context, CartScreen.routeName);
                        },
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
