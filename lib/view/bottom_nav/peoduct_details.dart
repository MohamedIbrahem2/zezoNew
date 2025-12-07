import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:zezo/constants.dart';
import 'package:zezo/view/bottom_nav/edit_product.dart';
import '../../main.dart';
import '../../service/cart_service.dart';
import '../../service/product_service.dart';
import '../my_page_screens/qr_product_view.dart';
import 'cart.dart';

class ProductDetails extends StatefulWidget {
  final Product product;
  final String uniqueId;

  const ProductDetails({super.key, required this.product, required this.uniqueId});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late final String userId;
  late final ValueNotifier<Product> productNotifier;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? widget.uniqueId;
    productNotifier = ValueNotifier<Product>(widget.product);
    _refreshProduct();
  }

  Future<void> _refreshProduct() async {
    final updated = await ProductsService().getProductById(productNotifier.value.id);
    if (mounted) productNotifier.value = updated;
  }

  @override
  void dispose() {
    productNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    final Color _mint = const Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ValueListenableBuilder<Product>(
        valueListenable: productNotifier,
        builder: (context, product, _) {
          final totalPrice = product.regularPrice - product.discountPrice;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Gradient Header with Image ----------
                    Container(
                      height: Get.height * 0.38,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _mint.withOpacity(0.4),
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 70),
                          Expanded(
                            child: Center(
                              child: Image.network(
                                product.images.first,
                                fit: BoxFit.contain,
                                height: 220,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------- Product Info ----------
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product title
                          Text(
                            product.title,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Brand / weight
                          Text(
                            product.brand,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),

                          const SizedBox(height: 18),

                          // ---------- Arabic Price Summary Box ----------
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Column(
                                children: [
                                  _priceRow("السعر", product.regularPrice),
                                  const Divider(height: 16, thickness: 0.7),
                                  _priceRow("سعر التخفيض", product.discountPrice),
                                  const Divider(height: 16, thickness: 0.7),
                                  _priceRow("السعر الكلي", totalPrice, highlight: true),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ---------- Description ----------
                          Text(
                            product.description,
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // ---------- Quantity Selector ----------
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F6F7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "الكمية",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (quantity > 1) quantity--;
                                        });
                                      },
                                      icon: const Icon(Icons.remove, color: Colors.black54),
                                    ),
                                    Text(
                                      quantity.toString(),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          quantity++;
                                        });
                                      },
                                      icon: Icon(Icons.add, color: _mint),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ---------- Add to Cart Button ----------
                          SizedBox(
                            width: double.infinity,
                            height: 54,
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
                                  price: totalPrice,
                                  quantity: quantity,
                                  userId: FirebaseAuth.instance.currentUser?.uid ??
                                      widget.uniqueId,
                                  image: product.images.first,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _mint,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "إضافة إلى السلة",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          if (provider.isAdmin)
                            _AdminActionSection(
                              product: product,
                              onRefresh: _refreshProduct,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- Floating Edit Button for Admin ----------
              if (provider.isAdmin)
                Positioned(
                  top: 90,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        Get.to(EditProduct(product: widget.product));
                      },
                      icon: const Icon(Icons.edit, color: Colors.black87, size: 24),
                      tooltip: "تعديل المنتج",
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _priceRow(String label, double value, {bool highlight = false}) {
    final Color _mint = const Color(0xFF2ECC71);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            fontSize: 16,
            color: highlight ? _mint : Colors.black54,
            fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/* ---------------- ADMIN ACTIONS ---------------- */

class _AdminActionSection extends StatelessWidget {
  final Product product;
  final Future<void> Function() onRefresh;

  const _AdminActionSection({required this.product, required this.onRefresh});

  Future<void> _performAction({
    required Future<void> Function(Product) action,
    required String title,
    required String message,
  }) async {
    await action(product);
    Get.defaultDialog(middleText: "", title: "$title ${product.brand.tr} $message");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          _AdminButton(
            label: "إضافة للأكثر مبيعاً",
            color: mainColor,
            onTap: () async {
              await _performAction(
                action: ProductsService().addProductToBestSelling,
                title: product.brand.tr,
                message: " تمت الإضافة للأكثر مبيعاً",
              );
              await onRefresh();
            },
          ),
          _AdminButton(
            label: "إزالة من الأكثر مبيعاً",
            color: Colors.black,
            onTap: () async {
              await _performAction(
                action: ProductsService().removeProductFromBestSelling,
                title: product.brand.tr,
                message: " تمت الإزالة من الأكثر مبيعاً",
              );
              await onRefresh();
            },
          ),
        ]),
        Row(children: [
          _AdminButton(
            label: "إضافة لغير المتاح",
            color: mainColor,
            onTap: () async {
              await _performAction(
                action: (p) => ProductsService().productNotAvailable(p.id),
                title: product.brand.tr,
                message: " تمت الإضافة لقائمة غير المتاح",
              );
              await onRefresh();
            },
          ),
          _AdminButton(
            label: "إزالة من غير المتاح",
            color: Colors.black,
            onTap: () async {
              await _performAction(
                action: (p) => ProductsService().productAvailable(p.id),
                title: product.brand.tr,
                message: " تمت الإزالة من قائمة غير المتاح",
              );
              await onRefresh();
            },
          ),
        ]),
      ],
    );
  }
}

class _AdminButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AdminButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: color),
          onPressed: onTap,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
