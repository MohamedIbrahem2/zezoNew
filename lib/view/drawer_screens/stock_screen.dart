import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import '../../service/product_service.dart';
import '../../widgets/shimmer.dart';
import '../bottom_nav/peoduct_details.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();

    // ✅ Load products after first frame to avoid drawer animation black flash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });

    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

  bool _containsOnlyEnglishCharacters(String input) {
    final RegExp regExp = RegExp(r'^[A-Za-z\s]+$');
    return regExp.hasMatch(input);
  }

  List<Product> _filterProductsBySearch(List<Product> allProducts, String query) {
    if (query.trim().isEmpty) return allProducts;

    final bool isEnglish = _containsOnlyEnglishCharacters(query);
    final String lowerQuery = query.toLowerCase();

    return allProducts.where((product) {
      final String nameEng = product.brand.toLowerCase();
      final String nameArabic = product.title.toLowerCase();
      return isEnglish
          ? nameEng.contains(lowerQuery)
          : nameArabic.contains(lowerQuery);
    }).toList();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .orderBy('title', descending: false)
          .get();

      final products = snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();

      setState(() {
        _products = products;
        _filteredProducts = products;
      });
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = _products);
    } else {
      setState(() {
        _filteredProducts = _products
            .where((p) => p.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Prevents black flash on open
      appBar: AppBar(
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'stock'.tr,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ---------- Search Bar ----------
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'ابحث عن منتج',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // ---------- Products Section ----------
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProducts,
                child: _isLoading
                    ? buildShimmer(4) // ✅ Show shimmer while loading
                    : Builder(
                  builder: (context) {
                    List<Product> filteredProducts = _filterProductsBySearch(
                      _products,
                      _searchController.text,
                    );

                    if (filteredProducts.isEmpty && !_isLoading) {
                      return const Center(
                        child: Text(
                          'لا توجد منتجات مطابقة',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }

                    return GridView.builder(
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: Get.height * .24,
                        childAspectRatio: .6,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        int stock = (product.stock ?? 0).toDouble().toInt();

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0),
                                  blurRadius: 6.0,
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          offset: Offset(0.0, 1.0),
                                          blurRadius: 3.0,
                                        ),
                                      ],
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: SizedBox(
                                      height: Get.height * 0.12,
                                      width: Get.width * .4,
                                      child: Image.network(
                                        product.images.first,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    product.title,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                    style: const TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const Text(
                                        "الكمية المتاحة:",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.add, color: Colors.green),
                                            onPressed: () {
                                              _showStockDialog(
                                                context,
                                                product.id,
                                                stock,
                                                isAdd: true,
                                              );
                                            },
                                          ),
                                          Text(
                                            stock.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.remove, color: Colors.red),
                                            onPressed: () {
                                              _showStockDialog(
                                                context,
                                                product.id,
                                                stock,
                                                isAdd: false,
                                              );
                                            },
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Stock Dialog ----------
  void _showStockDialog(BuildContext context, String productId, int currentStock,
      {required bool isAdd}) {
    final TextEditingController qtyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(isAdd ? "إضافة كمية" : "حذف كمية"),
          content: TextField(
            controller: qtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: isAdd ? "أدخل الكمية لإضافتها" : "أدخل الكمية للحذف",
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("إغلاق"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdd ? Colors.green : Colors.red,
              ),
              onPressed: () async {
                final int? qty = int.tryParse(qtyController.text);
                if (qty == null || qty <= 0) return;

                int newStock = currentStock;
                if (isAdd) {
                  newStock += qty;
                } else {
                  newStock = (currentStock - qty).clamp(0, double.infinity).toInt();
                }

                try {
                  await FirebaseFirestore.instance
                      .collection('products')
                      .doc(productId)
                      .update({'stock': newStock});

                  final updatedDoc = await FirebaseFirestore.instance
                      .collection('products')
                      .doc(productId)
                      .get();

                  Product updatedProduct;
                  try {
                    updatedProduct = Product.fromSnapshot(updatedDoc);
                  } catch (_) {
                    final data = updatedDoc.data() ?? <String, dynamic>{};
                    updatedProduct = Product(
                      available: data['available'] ?? false,
                      favorite: data['favorite'] ?? false,
                      isbestselling: data['isbestselling'] ?? false,
                      category: data['category'] ?? '',
                      brand: data['brand'] ?? '',
                      description: data['description'] ?? '',
                      stock: (data['stock'] ?? 0).toDouble().toInt(),
                      title: data['title'] ?? '',
                      weight: data['weight'] ?? '',
                      id: updatedDoc.id,
                      categoryId: data['categoryId'] ?? '',
                      regularPrice: data['regularPrice'] ?? 0,
                      images: List<String>.from(data['images'] ?? []),
                      discountPrice: data['discountPrice'] ?? 0,
                    );
                  }

                  setState(() {
                    _products = _products.map((p) {
                      if (p.id == productId) return updatedProduct;
                      return p;
                    }).toList();

                    _filteredProducts = _filteredProducts.map((p) {
                      if (p.id == productId) return updatedProduct;
                      return p;
                    }).toList();
                  });

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isAdd
                            ? "تمت إضافة $qty إلى المخزون بنجاح ✅"
                            : "تم حذف $qty من المخزون بنجاح ✅",
                        textDirection: TextDirection.rtl,
                      ),
                      backgroundColor: isAdd ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                } catch (e) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "حدث خطأ أثناء التحديث: $e",
                        textDirection: TextDirection.rtl,
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: Text(isAdd ? "إضافة" : "حذف"),
            ),
          ],
        );
      },
    );
  }
}
