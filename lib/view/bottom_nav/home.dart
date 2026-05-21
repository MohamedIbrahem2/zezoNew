import 'dart:ui';
import 'package:auto_scroll/auto_scroll.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:zezo/constants.dart';
import 'package:zezo/main.dart';
import 'package:zezo/service/category_service.dart';
import 'package:zezo/service/product_service.dart';
import 'package:zezo/view/bottom_nav/cart.dart';
import 'package:zezo/view/bottom_nav/peoduct_details.dart';
import 'package:zezo/view/categories/categories_view.dart';
import 'package:zezo/view/drawer_screens/add_stories_screen.dart';
import 'package:zezo/view/drawer_screens/stock_screen.dart';
import 'package:zezo/view/drawer_screens/unavailable_product.dart';
import 'package:zezo/view/drawer_screens/sendMessage.dart';
import 'package:zezo/view/drawer_screens/add_subcategory_screen.dart';
import 'package:zezo/view/drawer_screens/add_products_screen.dart';
import 'package:zezo/view/drawer_screens/add_category_screen.dart';
import 'package:zezo/view/drawer_screens/financial_management_screens/financial_manegment.dart';
import 'package:zezo/view/drawer_screens/language.dart';
import 'package:zezo/view/drawer_screens/obout_us.dart';
import 'package:zezo/view/drawer_screens/prfile_screen.dart';
import 'package:zezo/view/drawer_screens/technical_support.dart';
import 'package:zezo/view/drawer_screens/wallet.dart';
import 'package:zezo/view/my_page_screens/orders_management.dart';
import 'package:zezo/view/my_page_screens/our_location_page.dart';
import 'package:zezo/view/bottom_nav/admins.dart';
import 'package:zezo/view/sign_in.dart';
import 'package:zezo/widgets/stories_view.dart';
import '../../service/cart_service.dart';
import '../../service/offer_service.dart';
import '../../widgets/stories_shimmer.dart';

class HomePage extends StatefulWidget {
  final String uniqueId;
  const HomePage({Key? key, required this.uniqueId}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AutoScrollController _autoScroll = AutoScrollController();

  late final String _userId =
      FirebaseAuth.instance.currentUser?.uid ?? widget.uniqueId;

  String categoryId = "6GtrTH5CBa4CgQfPTRM4";
  int _selectedIndex = 0;
  int _count = 1;
  bool _busy = false;
  String _error = '';
  final _formKey = GlobalKey<FormState>();

  bool get _isSearching => _search.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ensureProfile();
    _search.addListener(() => setState(() {}));
  }

  Future<void> _ensureProfile() async {
    final ref = _firestore.collection('users').doc(widget.uniqueId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': "الأسم",
        'phone': "رقم الهاتف",
        'email': "البريد الألكتروني",
      }, SetOptions(merge: true));
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _categoryController.dispose();
    _autoScroll.dispose();
    super.dispose();
  }

  // ---------- Helpers: Mint theme ----------
  Color get _mint => const Color(0xFF2ECC71); // primary mint
  Color get _mintLight => const Color(0xFFE9F7EF);
  Color get _mintDark => const Color(0xFF27AE60);
  Color get _cardShadow => Colors.black.withOpacity(0.06);

  InputBorder _roundedBorder([Color? c]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: c ?? Colors.transparent, width: 1),
  );



  // Simple fade-in wrapper (for loaders instead of shimmer)
  Widget _fadeIn(Widget child, {int ms = 300}) {
    final ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: ms),
    )..forward();
    return FadeTransition(opacity: CurvedAnimation(parent: ctrl, curve: Curves.easeIn), child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mintLight,
      appBar: _buildAppBar(), // keep app bar logic & look
      drawer: _buildDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // ---- Search bar (under app bar) ----
              _buildSearchBar(),

              const SizedBox(height: 12),

              ListItemsStatusHome(),

              const SizedBox(height: 12),

              // ---- Carousel (kept logic, adjusted look) ----
              _buildCarousel(),

              const SizedBox(height: 10),

              // ---- All categories button + spacing ----
              if (!_isSearching)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPrimaryButton(
                        label: 'All categories'.tr,
                        onTap: () => Get.to(Categories(uniqueId: widget.uniqueId)),
                      ),
                    ],
                  ),
                ),

              // ---- Mint rounded categories ----
              if (!_isSearching) _buildMintCategories(),

              const SizedBox(height: 16),

              // ---- Products by selected category ----
              if (!_isSearching)
                _buildHorizontalProducts(
                  stream: ProductsService().getProductsByCategory(categoryId),
                  compact: false,
                  allowRemoveFromBestSelling: false,
                ),
              const SizedBox(height: 16),
              // ---- Search results ----
              if (_isSearching) _buildSearchResults(),
              const SizedBox(height: 24),
              // ---- Best Selling ----
              if (!_isSearching) ...[
                _buildSectionTitle('best_selling'.tr),
                _buildHorizontalProducts(
                  stream: ProductsService().getBestSellingProducts(),
                  compact: true,
                  allowRemoveFromBestSelling: true,
                ),
              ],
              const SizedBox(height: 24),
              // ---- Offers / Favorites ----
              if (!_isSearching) ...[
                _buildSectionTitle('offers'.tr),
                _buildFavoritesStrip(),
              ],

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- AppBar (unchanged logic) ----------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      actions: [
        GestureDetector(
          onTap: () => Get.to(Screen2(uniqueId: widget.uniqueId)),
          child: Stack(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 15, top: 6),
                child: Icon(Icons.shopping_cart_outlined, size: 30, color: Colors.black),
              ),
              // Cart badge
              StreamBuilder<List<CartItem>>(
                stream: CartService().getCartItems(_userId),
                builder: (context, snapshot) {
                  final quantity = (snapshot.data == null || snapshot.data!.isEmpty)
                      ? 0
                      : snapshot.data!.map((e) => e.quantity).fold<int>(0, (a, b) => a + b);
                  final label = quantity >= 100 ? '99+' : quantity.toString();
                  return Positioned(
                    left: 18,
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                      child: Center(
                        child: Text(label,
                            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: Colors.white, // keep as original app bar bg
      title: Padding(
        padding: const EdgeInsets.only(top: 5.0),
        child: Image.asset('images/logo2.png', height: Get.height * .05, width: Get.width * .5),
      ),
      centerTitle: true,
    );
  }

  // ---------------- Drawer (same options, cleaner UI) ----------------
  Widget _buildDrawer() {
    final isAdmin = context.watch<AdminProvider>().isAdmin;
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Drawer(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(30),
                width: Get.width,
                height: Get.height * .2,
                alignment: Alignment.center,
                color: Colors.blue.shade50,
                child: Image.asset('images/logo_zezo.png'),
              ),
              if (isAdmin) _drawerTile('stock'.tr, () => Get.to(StockScreen())),
              _drawerTile('account_points'.tr, () => Get.to(const Wallet())),
              _drawerTile('technical_support'.tr, () => Get.to(const TechnicalSupport())),
              if (isAdmin) _drawerTile("financial management".tr, () => Get.to(const FinancialManegment())),
              _drawerTile('profile'.tr, () => Get.to(const PrfileScreen())),
              ListTile(
                title: Text('language'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.language_outlined),
                onTap: () => Get.to(const Language()),
              ),
              _drawerTile('who_we_are'.tr, () => Get.to(const AboutUs())),
              _drawerTile('our_location'.tr, () => Get.to(const OurLocationPage())),
              if (isAdmin) _drawerTile('orders Management'.tr, () => Get.to(const OrdersManagement())),
              if (isAdmin) _drawerTile('addStory'.tr, () => Get.to(AddStoryPage())),
              if (isAdmin) _drawerTile('admins'.tr, () => Get.to(const AdminsPage())),
              if (isAdmin) _drawerTile('unavailable_products'.tr, () => Get.to(const UnavailableProduct())),
              if (isAdmin) _drawerTile('send_message'.tr, () => Get.to(const SendMessage())),
              if (isAdmin) _drawerTile('add category'.tr, () => Get.to(const AddCategoryScreen())),
              if (isAdmin) _drawerTile('add product'.tr, () => Get.to(const AddProductScreen())),
              ListTile(
                title: Row(
                  children: [
                    Text('share app'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 10),
                    const Icon(Icons.share, color: Colors.black),
                  ],
                ),
                onTap: () async {/* no-op */},
              ),
              FirebaseAuth.instance.currentUser == null
                  ? _coloredTile('login'.tr, mainColor, () => Get.to(const SignIn()))
                  : _logoutTile(context),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _drawerTile(String title, VoidCallback onTap) => ListTile(
    title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    onTap: onTap,
  );

  Widget _coloredTile(String title, Color color, VoidCallback onTap) => ListTile(
    title: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
    onTap: onTap,
  );

  Widget _logoutTile(BuildContext context) => ListTile(
    title: Text('logout'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainColor)),
    onTap: () {
      Get.defaultDialog(
        title: 'are you sure?'.tr,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 10),
              child: Text('no'.tr, style: const TextStyle(color: Colors.black)),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Get.offAll(const SignIn());
              },
              style: ElevatedButton.styleFrom(backgroundColor: mainColor, elevation: 10),
              child: Text('yes'.tr, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    },
  );

  // ---------------- Search Bar ----------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEAEAEA)),
          boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: TextFormField(
            controller: _search,
            decoration: InputDecoration(
              hintText: 'what_ever_you_want'.tr,
              prefixIcon: const Icon(Icons.search_rounded, size: 24, color: Colors.black87),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: _roundedBorder(Colors.transparent),
              focusedBorder: _roundedBorder(_mint.withOpacity(.4)),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Carousel (kept logic, refined UI) ----------------
  Widget _buildCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 6))],
          ),
          child: StreamBuilder<List<Offer>>(
            stream: OfferService().getAllOffers(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return _fadeIn(const SizedBox(height: 130));
              if (!snapshot.hasData) {
                return _fadeIn(Container(
                  height: 100,
                  color: _mintLight,
                  alignment: Alignment.center,
                  child: const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2)),
                ));
              }
              // Keep same items as your original code:contentReference[oaicite:1]{index=1}
              final items = [
                {"image": "images/offer_image2.jpg"},
                {"image": "images/offer_image1.jpg"},
              ];
              return CarouselSlider(
                items: items.map((offer) {
                  return Builder(
                    builder: (_) => Container(
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage(offer['image']!), fit: BoxFit.fill),
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 100,
                  viewportFraction: 1,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ---------------- Mint Rounded Categories ----------------
  Widget _buildMintCategories() {
    return StreamBuilder<List<Category>>(
      stream: CategoryService().getCategories(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox();

        if (!snapshot.hasData) {
          return SizedBox(
            height: 400,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final categories = snapshot.data!;
        if (categories.isEmpty) return const SizedBox();

        return SizedBox(
          width: Get.width,
          height: 400, // 🔥 SAME HEIGHT AS FIRST GRID
          child: GridView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 🔥 SAME AS FIRST ONE
              mainAxisSpacing: 18,
              crossAxisSpacing: 30,
              childAspectRatio: 1.05,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = categoryId == category.id;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onLongPress: () {
                  if (!context.read<AdminProvider>().isAdmin) return;
                  _showEditDeleteCategoryDialog(category);
                },
                onTap: () => setState(() {
                  categoryId = category.id;
                  _selectedIndex = index;
                }),
                child: Column(
                  children: [
                    /// ===== IMAGE CARD (SAME DESIGN)
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [mainColor, Colors.white]
                                    : [mainColor.withOpacity(0.6), Colors.white],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: CachedNetworkImage(
                                  imageUrl: category.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  placeholder: (_, __) =>
                                  const ImageShimmer(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(14)),
                                  ),
                                  errorWidget: (_, __, ___) => Image.asset(
                                    "",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 6),

                    /// ===== TITLE (UNCHANGED)
                    Builder(builder: (ctx) {
                      final title = category.name;
                      final len = title.trim().length;
                      final langCode = Get.locale?.languageCode ?? 'ar';
                      final isArabic = langCode.startsWith('ar');
                      final threshold = isArabic ? 14 : 18;
                      final fontSize = len > threshold ? 10.0 : 13.5;

                      return Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          fontFamily: 'lamasans',
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }



  void _showEditDeleteCategoryDialog(Category category) {
    Get.defaultDialog(
      title: 'Do you want to delete'.tr + category.name.tr + "category".tr + " ?",
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Get.defaultDialog(
                title: "edit category".tr,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _categoryController,
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter category name' : null,
                      decoration: const InputDecoration(
                        labelText: 'category name',
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() => _busy = true);
                        try {
                          await CategoryService()
                              .updateCategory(category.copyWith(name: _categoryController.text));
                          Get.back();
                          Get.snackbar('Success', 'Category Edited successfully');
                        } catch (e) {
                          setState(() => _error = e.toString());
                        } finally {
                          setState(() => _busy = false);
                        }
                      },
                      child: Text('update category'.tr),
                    ),
                  ],
                ),
              );
            },
          ),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 10),
            child: Text('no'.tr, style: const TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () async {
              await ProductsService().deleteCategory(category.id);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 10),
            child: Text('yes'.tr, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------- Section Title ----------------
  Widget _buildSectionTitle(String title) {
    return Container(
      margin: const EdgeInsets.only(top: 6, right: 15, bottom: 8),
      alignment: Alignment.topRight,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationColor: _mintDark,
        ),
      ),
    );
  }

  // ---------------- Primary Button ----------------
  Widget _buildPrimaryButton({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34,
        width: Get.width * .4,
        margin: const EdgeInsets.only(top: 8, bottom: 8, right: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _mint,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: _cardShadow, blurRadius: 10, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios_outlined, size: 15, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ---------------- Horizontal Products (cards refined) ----------------
  Widget _buildHorizontalProducts({
    required Stream<List<Product>> stream,
    required bool compact,
    required bool allowRemoveFromBestSelling,
  }) {
    return StreamBuilder<List<Product>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _fadeIn(SizedBox(
            height: compact ? Get.height * .21 : Get.height * .295,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ));
        }
        final products = snapshot.data ?? const <Product>[];
        return SizedBox(
          height: compact ? Get.height * .26 : Get.height * .31,
          width: Get.width,
          child: GridView.builder(
            reverse: true,
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: compact ? 1.25 : 1.50,
            ),
            itemBuilder: (_, index) {
              final p = products[index];
              return _buildProductTile(
                product: p,
                compact: compact,
                allowRemoveFromBestSelling: allowRemoveFromBestSelling,
              );
            },
          ),
        );
      },
    );
  }

  // ---------------- Search Results ----------------
  Widget _buildSearchResults() {
    final lower = _search.text.toLowerCase();
    bool _isEnglish(String input) => RegExp(r'^[A-Za-z\s]+$').hasMatch(input);

    return Container(
      margin: const EdgeInsets.all(10).copyWith(bottom: 0),
      width: Get.width,
      height: Get.height * .88,
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection("products").snapshots(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Error'));
          if (snap.connectionState == ConnectionState.waiting && _search.text.isNotEmpty) {
            return _fadeIn(const Center(child: CircularProgressIndicator(strokeWidth: 2)));
          }
          if (_search.text.isEmpty) {
            return const Center(
              child: Text("من فضلك اكتب اسم المنتج الذي تريد البحث عنه", textDirection: TextDirection.rtl),
            );
          }

          final docs = snap.data?.docs ?? [];
          final isEng = _isEnglish(_search.text);
          final filtered = docs.where((d) {
            final nameEng = (d['brand'] ?? '').toString().toLowerCase();
            final nameAr = (d['title'] ?? '').toString().toLowerCase();
            return isEng ? nameEng.contains(lower) : nameAr.contains(lower);
          }).toList();

          return Container(
            margin: const EdgeInsets.only(bottom: 250),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: .8,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final f = filtered[i];
                final data = f.data() as Map<String, dynamic>;
                final p = Product(
                  available: (data['avalible'] ?? true) as bool,
                  favorite: (data['favorite'] ?? false) as bool,
                  isbestselling: (data['isbestselling'] ?? false) as bool,
                  category: (data['category'] ?? '') as String,
                  brand: (data['brand'] ?? '') as String,
                  description: (data['description'] ?? '') as String,
                  stock: 0,
                  title: (data['title'] ?? '') as String,
                  weight: (data['weight'] ?? '') as String,
                  id: f.id,
                  categoryId: data['categoryId'] ?? 0,
                  regularPrice: (data['regularPrice'] ?? 0.0) * 1.0,
                  images: List<String>.from((data['images'] ?? const <String>[]) as List),
                  discountPrice: (data['discountPrice'] ?? 0.0) * 1.0,
                  discountPercentage: (data['discountPercentage'] ?? 0.0),
                  quantityDiscount: (data['quantityDiscount'] ?? 0)
                );
                return _buildProductTile(product: p, compact: false, allowRemoveFromBestSelling: false);
              },
            ),
          );
        },
      ),
    );
  }

  // ---------------- Product Card ----------------
  Widget _buildProductTile({
    required Product product,
    required bool compact,
    required bool allowRemoveFromBestSelling,
  }) {
    final isAdmin = context.read<AdminProvider>().isAdmin;
    final priceNow = (product.regularPrice - product.discountPrice);

    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: GestureDetector(
        onLongPress: () {
          if (!isAdmin) return;
          Get.defaultDialog(
            title: 'Do you want to delete'.tr + product.brand.tr + "product".tr + " ?",
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 10),
                  child: Text('no'.tr, style: const TextStyle(color: Colors.black)),
                ),
                if (allowRemoveFromBestSelling)
                  ElevatedButton(
                    onPressed: () async {
                      await ProductsService().deleteProductFromBestSelling(product.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 10),
                    child: Text('yes'.tr, style: const TextStyle(color: Colors.white)),
                  )
                else
                  ElevatedButton(
                    onPressed: () async {
                      await ProductsService().deleteProductFromBestSelling(product.id);
                      ProductsService().deleteProduct(product.id);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 10),
                    child: Text('yes'.tr, style: const TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          );
        },
        onTap: () => Get.to(ProductDetails(product: product, uniqueId: _userId)),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: _cardShadow, offset: const Offset(0, 6), blurRadius: 12)],
          ),
          child: Column(
            children: [
              const SizedBox(height: 6),
              // Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: product.images.first,
                    placeholder: (_, __) => _fadeIn(Container(
                      height: compact ? Get.height * .065 : Get.height * .115,
                      color: _mintLight,
                    )),
                    imageBuilder: (context, provider) => Container(
                      height: compact ? Get.height * .065 : Get.height * .115,
                      decoration: BoxDecoration(
                        color: _mintLight,
                        image: DecorationImage(image: provider, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  product.title,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  style: TextStyle(
                    height: 1.05,
                    overflow: TextOverflow.ellipsis,
                    fontSize: compact ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Brand
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: Text(
                  product.brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: compact ? 10 : 12, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
              ),
           product.discountPercentage != 0 ?   Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                      fontWeight: FontWeight.w800,
                    ),
                    children: [
                      TextSpan(text: "discountQuantity".tr),
                      TextSpan(
                        text: "${(product.discountPercentage * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Color(0xFF1CD426), // dark green
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: "moreThan".tr),
                      TextSpan(
                        text: "${product.quantityDiscount}",
                        style: const TextStyle(
                          color: Color(0xFF1CD426),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: "product".tr),
                    ],
                  ),
                ),
              ) : const SizedBox(),
              Flexible(child: Container()),

              // Price + Add Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prices
                    Row(
                      children: [
                        if (product.discountPrice > 0)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Text(
                                product.regularPrice.toString(),
                                style: TextStyle(
                                  fontSize: compact ? 10 : 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: _mintDark,
                                ),
                              ),
                            ],
                          ),
                        if (product.discountPrice > 0) const SizedBox(width: 6),
                        Text(
                          (product.discountPrice > 0 ? priceNow : product.regularPrice).toString(),
                          style: TextStyle(
                            fontSize: compact ? 12 : 13,
                            fontWeight: FontWeight.w800,
                            color: _mintDark,
                          ),
                        ),
                      ],
                    ),

                    // Add to cart
                    SizedBox(
                      width: Get.width * 0.095,
                      height: Get.height * 0.04,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!product.available) {
                            Get.defaultDialog(
                              title: "هذا المنتج غير متاح حاليا\nسيتم توفيره قريبا",
                              content: ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 10),
                                child: Text('go_back'.tr, style: const TextStyle(color: Colors.black)),
                              ),
                            );
                            return;
                          }
                          await CartService().addToCart(
                            productNameEng: product.brand,
                            productId: product.id,
                            productName: product.title,
                            price: priceNow,
                            quantity: _count <= 0 ? 1 : _count,
                            userId: _userId,
                            image: product.images.first,
                            discountPercentage: product.discountPercentage,
                            quantityDiscount: product.quantityDiscount
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          backgroundColor: _mint,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ) ,
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Favorites (with only heart icon here) ----------------
  Widget _buildFavoritesStrip() {
    return StreamBuilder<List<Product>>(
      stream: ProductsService().getFavoriteProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text(snapshot.error.toString()));
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _fadeIn(
            SizedBox(
              height: Get.height * .22,
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          );
        }
        final products = snapshot.data ?? const <Product>[];
        if (products.isEmpty) return const Center(child: Text("لا يوجد منتجات مفضله"));

        return SizedBox(
          height: Get.height * .25,
          width: Get.width,
          child: GridView.builder(
            reverse: true,
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (_, i) {
              final p = products[i];
              return Stack(
                alignment: Alignment.topLeft,
                children: [
                  _buildProductTile(product: p, compact: true, allowRemoveFromBestSelling: false),
                  Positioned(
                    top: -10,
                    left: -10,
                    child: IconButton(
                      onPressed: () async {
                        if (p.favorite) {
                          await ProductsService().removeProductFromFavorite(p);
                          Get.defaultDialog(middleText: "", title: p.brand.tr + " Removed successfully from Favorite");
                        } else {
                          await ProductsService().addProductToFavorite(p);
                          Get.defaultDialog(middleText: "", title: p.brand.tr + " Added successfully to Favorite.");
                        }
                      },
                      icon: Icon(
                        p.favorite ? Icons.favorite_outlined : Icons.favorite_outline_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
