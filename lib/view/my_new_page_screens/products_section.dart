
// Products section extracted
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zezo/view/my_new_page_screens/product_card.dart';
import '../../../service/product_service.dart';
import '../../../widgets/shimmer.dart';

class ProductsSection extends StatelessWidget {
  final String categoryId;
  final String uniqueId;
  const ProductsSection({Key? key, required this.categoryId, required this.uniqueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ProductsService().getProductsByCategory(categoryId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final products = snapshot.data!;
        return GridView.builder(
          itemCount: products.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
          ),
          itemBuilder: (_, i) {
            final product = products[i];
            return ProductCard(product: product, uniqueId: uniqueId,);
          },
        );
      },
    );
  }
}
