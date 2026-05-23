import 'package:flutter/material.dart';

/// Displays a product image that can be either:
///   - A local asset  e.g.  "assets/images/products/product_maroon_kurti.jpg"
///   - A network URL  e.g.  "https://firebasestorage.googleapis.com/..."
class ProductImage extends StatelessWidget {
  final String path;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const ProductImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  bool get _isNetwork => path.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final image = _isNetwork
        ? Image.network(
            path,
            fit: fit,
            errorBuilder: (_, __, ___) => _placeholder(),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          )
        : Image.asset(
            path,
            fit: fit,
            errorBuilder: (_, __, ___) => _placeholder(),
          );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFF0ECE7),
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined,
            color: Color(0xFFB0A89E), size: 40),
      ),
    );
  }
}