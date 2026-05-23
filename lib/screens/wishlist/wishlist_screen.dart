import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/shop_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/product/product_card.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<ShopProvider>().wishlistProducts;

    return SafeArea(
      child: wishlist.isEmpty
          ? const EmptyState(
              icon: Icons.favorite_border_rounded,
              title: 'No favorites yet',
              subtitle: 'Tap the heart icon on products to save your favorites.',
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              itemCount: wishlist.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 355,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemBuilder: (context, index) => ProductCard(product: wishlist[index]),
            ),
    );
  }
}
