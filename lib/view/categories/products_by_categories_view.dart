import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:zezo/constants.dart';
import 'package:zezo/service/product_service.dart';
import '../../main.dart';
import '../../service/cart_service.dart';
import '../bottom_nav/peoduct_details.dart';

class ProductsByCategories extends StatefulWidget {
  final String categoryId;
  final String uniqueId;
  const ProductsByCategories(
      {super.key, required this.categoryId, required this.uniqueId});

  @override
  State<ProductsByCategories> createState() => _ProductsByCategoriesState();
}

class _ProductsByCategoriesState extends State<ProductsByCategories> {
  int count = 1;
  final Color _mint = const Color(0xFF2ECC71);
  final Color _shadow = Colors.black12;
  final Color _bgColor = const Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        centerTitle: true,
        title: const Text(
          "Vegetables",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<List<Product>>(
        stream: ProductsService().getProductsByCategory(widget.categoryId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          }

          final products = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                final double priceNow =
                (product.regularPrice - product.discountPrice);

                return GestureDetector(
                  onTap: () {
                    Get.to(ProductDetails(
                      product: product,
                      uniqueId: widget.uniqueId,
                    ));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: _shadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Product image with mint circle background
                          Container(
                            height: 70,
                            width: 85,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  _mint.withOpacity(0.12),
                                  _mint.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: CachedNetworkImage(
                                imageUrl: product.images.first,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: _mint.withOpacity(0.05),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Product title
                          Text(
                            product.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Product subtext (brand/weight)
                          Text(
                            product.brand,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),

                          const Spacer(),

                          // Price + button row
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, left: 6, right: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Price
                                Row(
                                  children: [
                                    if (product.discountPrice > 0)
                                      Text(
                                        product.regularPrice.toString(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black45,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    if (product.discountPrice > 0)
                                      const SizedBox(width: 5),
                                    Text(
                                      (product.discountPrice > 0
                                          ? priceNow
                                          : product.regularPrice)
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: _mint,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                // Add (+) button at bottom right
                                SizedBox(
                                  width: 34,
                                  height: 34,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      if (!product.available) {
                                        Get.snackbar("غير متاح", "هذا المنتج غير متاح حالياً");
                                        return;
                                      }
                                      await CartService().addToCart(
                                        productNameEng: product.brand,
                                        productId: product.id,
                                        productName: product.title,
                                        price: priceNow,
                                        quantity: count,
                                        userId:
                                        FirebaseAuth.instance.currentUser?.uid ??
                                            widget.uniqueId,
                                        image: product.images.first,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _mint,
                                      padding: EdgeInsets.zero,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
