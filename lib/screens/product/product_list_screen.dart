import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/dummy_data.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/home/category_chip.dart';
import '../../widgets/product/product_card.dart';

class ProductListScreen extends StatelessWidget {
  static const routeName = '/products';

  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();
    final products = provider.filteredProducts();

    return Scaffold(
      appBar: AppBar(title: const Text('Product Listing')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5DFD7)),
                  ),
                  child: TextField(
                    onChanged: provider.setSearchQuery,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      suffixIcon: Icon(Icons.mic_none_rounded),
                      border: InputBorder.none,
                      hintText: 'Search ...',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category chips
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return CategoryChip(
                        item: item,
                        selected:
                            provider.selectedCategory == item.title,
                        onTap: () =>
                            provider.setCategory(item.title),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Product grid ────────────────────────────────────────────────
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Color(0xFFD33B32)),
                          ),
                        ),
                      )
                    : products.isEmpty
                        ? const EmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No products found',
                            subtitle:
                                'Try a different category or search term.',
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                20, 0, 20, 30),
                            itemCount: products.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisExtent: 355,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                            ),
                            itemBuilder: (context, index) =>
                                ProductCard(product: products[index]),
                          ),
          ),
        ],
      ),
    );
  }
}