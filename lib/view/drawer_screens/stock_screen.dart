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
  final ProductsService _service = ProductsService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _service.hasMore) {
        _loadProducts(loadMore: true);
      }
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

  Future<void> _loadProducts({bool loadMore = false}) async {
    setState(() => _isLoading = true);
    final result = await _service.getProductsPagination(loadMore: loadMore);
    setState(() {
      _products = result;
      _filteredProducts = result;
      _isLoading = false;
    });
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = _products);
    } else {
      setState(() {
        _filteredProducts =
            _products
                .where(
                  (p) => p.title.toLowerCase().contains(query.toLowerCase()),
                )
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
    if (_products.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
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
                  if (qty == null || qty <= 0) {
                    // invalid input - you may show an error toast if you want
                    return;
                  }

                  int newStock = currentStock;
                  if (isAdd) {
                    newStock += qty;
                  } else {
                    newStock = (currentStock - qty).clamp(0, double.infinity).toInt();
                  }

                  try {
                    // 1) Update Firestore
                    await FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId)
                        .update({'stock': newStock});

                    // 2) Read the updated document back
                    final updatedDoc = await FirebaseFirestore.instance
                        .collection('products')
                        .doc(productId)
                        .get();

                    // 3) Build a Product instance from snapshot
                    // If you have a fromSnapshot factory, use it; otherwise create manually.
                    Product updatedProduct;
                    try {
                      updatedProduct = Product.fromSnapshot(updatedDoc);
                    } catch (_) {
                      // If fromSnapshot isn't present or failed, build manually from data:
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

                    // 4) Replace the product in both lists (if present)
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

                    // 5) Success snackbar
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
                    // error handling: show snackbar and keep dialog open (or close if you want)
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


    return Scaffold(
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
            // 🔍 Search Bar
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
                onChanged: (_) {
                  setState(() {}); // Rebuild UI as user types
                },
              ),
            ),

            // 🧾 Product Grid
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _service.reset();
                  await _loadProducts();
                },
                child: Builder(
                  builder: (context) {
                    // 🔎 Apply search filtering
                    List<Product> filteredProducts = _filterProductsBySearch(
                      _products,
                      _searchController.text,
                    );

                    if (filteredProducts.isEmpty && !_isLoading) {
                      return const Center(child: Text('لا توجد منتجات مطابقة'));
                    }

                    return GridView.builder(
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: Get.height * .24,
                        childAspectRatio: .6,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 5,
                      ),
                      itemCount: filteredProducts.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredProducts.length) {
                          return const Center(child: CircularProgressIndicator());
                        }

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
                                // 🖼 Product image
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
                                      color: Colors.blue,
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

                                // 🏷 Product title
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

                                // 📦 Stock Control
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
                                          // ➕ Add button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add,
                                              color: Colors.green,
                                            ),
                                            onPressed: () {
                                              _showStockDialog(
                                                context,
                                                product.id,
                                                stock,
                                                isAdd: true,
                                              );
                                            },
                                          ),

                                          // Stock number display
                                          Text(
                                            stock.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),

                                          // ➖ Remove button
                                          IconButton(
                                            icon: const Icon(
                                              Icons.remove,
                                              color: Colors.red,
                                            ),
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
}
