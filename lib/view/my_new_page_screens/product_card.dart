import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../constants.dart';
import 'package:get/get.dart';

import '../bottom_nav/peoduct_details.dart';

class ProductCard extends StatelessWidget {
  final String uniqueId;
  final dynamic product;
  const ProductCard({Key? key, required this.product, required this.uniqueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(ProductDetails(product: product, uniqueId: '',)),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: product.image,
                placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) => const Icon(Icons.error),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Text("${product.price} SAR", style: TextStyle(color: mainColor)),
          ],
        ),
      ),
    );
  }
}
