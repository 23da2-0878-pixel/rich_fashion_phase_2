import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../data/dummy_data.dart';
import '../../providers/shop_provider.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/home/banner_carousel.dart';
import '../../widgets/home/category_chip.dart';
import '../../widgets/product/product_card.dart';
import '../product/product_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShopProvider>();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () async {
          await Future<void>.delayed(const Duration(milliseconds: 600));
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Header row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Explore Our',
                                style:
                                    Theme.of(context).textTheme.bodyLarge),
                            const SizedBox(height: 4),
                            Text('Vibrant Summer Collection',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium),
                          ],
                        ),
                      ),
                      Badge(
                        label: Text(provider.cartCount.toString()),
                        isLabelVisible: provider.cartCount > 0,
                        child: const Icon(
                            Icons.notifications_none_rounded,
                            size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

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
                      onTap: () => Navigator.pushNamed(
                          context, ProductListScreen.routeName),
                      readOnly: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search_rounded),
                        suffixIcon: Icon(Icons.tune_rounded),
                        border: InputBorder.none,
                        hintText:
                            'Search kurtis, sets, and festive wear',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Banners
                  const BannerCarousel(
                    imagePaths: [
                      'assets/images/banners/banner_primary.jpg',
                      'assets/images/banners/banner_secondary.jpg',
                      'assets/images/banners/banner_third.jpg',
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Category chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: categories.map((item) {
                        final selected =
                            provider.selectedCategory == item.title;
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CategoryChip(
                            item: item,
                            selected: selected,
                            onTap: () =>
                                provider.setCategory(item.title),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SectionHeader(
                    title: 'Featured',
                    onTap: () => Navigator.pushNamed(
                        context, ProductListScreen.routeName),
                  ),
                  const SizedBox(height: 14),
                ]),
              ),
            ),

            // ── Featured products grid ────────────────────────────────────
            if (provider.isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else if (provider.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFFD33B32)),
                    ),
                  ),
                ),
              )
            else if (provider.featuredProducts.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: Text('No featured products yet.')),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product =
                          provider.featuredProducts[index];
                      return ProductCard(product: product);
                    },
                    childCount: provider.featuredProducts.length,
                  ),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: 355,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                ),
              ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 26, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(
                      title: 'Why shop ${AppConstants.appName}?',
                      action: 'Details',
                      onTap: () {},
                    ),
                    const SizedBox(height: 14),
                    _InfoCard(
                      title: 'Premium quality picks',
                      subtitle:
                          'Carefully curated ethnic fashion with polished design.',
                      icon: Icons.workspace_premium_rounded,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Smooth shopping flow',
                      subtitle:
                          'Wishlist, cart, checkout, and order tracking — all in one.',
                      icon: Icons.auto_awesome_motion_rounded,
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

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5DFD7)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, child: Icon(icon)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}