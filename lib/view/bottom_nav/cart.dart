import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:zezo/bottom_navbar_provider.dart';
import 'package:zezo/service/cart_service.dart';
import 'package:zezo/view/home_view.dart';
import '../../constants.dart';
import '../../main.dart';
import '../check_out/checkhome.dart';
import '../sign_in.dart';

class Screen2 extends StatefulWidget {
  final String uniqueId;
  const Screen2({Key? key, required this.uniqueId}) : super(key: key);

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  final Map<String, TextEditingController> _qtyControllers = {};
  final Map<String, double> _editedPrices = {};

  @override
  void dispose() {
    for (final c in _qtyControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    String userId = FirebaseAuth.instance.currentUser?.uid ?? widget.uniqueId;

    const Color mint = Color(0xFF2ECC71);
    const Color darkMint = Color(0xFF27AE60);
    const Color lightGray = Color(0xFFF7F7F7);

    return Scaffold(
      backgroundColor: lightGray,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Shopping Cart",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 100),
        child: StreamBuilder<List<CartItem>>(
          stream: CartService().getCartItems(userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final cartItems = snapshot.data ?? [];

            if (cartItems.isEmpty) {
              return const Center(
                child: Text(
                  'No products in cart',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              );
            }

            return ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final cartItem = cartItems[index];
                final qtyController = _qtyControllers.putIfAbsent(
                  cartItem.id,
                      () => TextEditingController(text: cartItem.quantity.toString()),
                );
                final currentPrice = _editedPrices[cartItem.id] ?? cartItem.price;
                final priceController = TextEditingController(text: currentPrice.toString());
                bool isEditingPrice = false;

                return StatefulBuilder(
                  builder: (context, setTileState) => Dismissible(
                    key: Key(cartItem.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => CartService().removeCartItem(cartItem.id),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            // Product Image with Mint Shadow
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: mint.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: cartItem.image,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  errorWidget: (_, __, ___) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Product Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    cartItem.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      if (provider.isAdmin && isEditingPrice)
                                        SizedBox(
                                          width: 70,
                                          child: TextField(
                                            controller: priceController,
                                            keyboardType:
                                            const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              isDense: true,
                                              contentPadding: EdgeInsets.all(6),
                                            ),
                                          ),
                                        )
                                      else
                                        Text(
                                          '${currentPrice.toStringAsFixed(2)} × ${cartItem.quantity}',
                                          style: const TextStyle(
                                            color: mint,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      if (provider.isAdmin)
                                        IconButton(
                                          icon: Icon(isEditingPrice ? Icons.check : Icons.edit,
                                              size: 18),
                                          onPressed: () {
                                            if (isEditingPrice) {
                                              final newPrice =
                                                  double.tryParse(priceController.text) ?? currentPrice;
                                              setState(() {
                                                _editedPrices[cartItem.id] = newPrice;
                                              });
                                            }
                                            setTileState(() => isEditingPrice = !isEditingPrice);
                                          },
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Controls (User/Admin)
                            provider.isAdmin
                                ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 36,
                                    height: 30,
                                    child: TextField(
                                      controller: qtyController,
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                                      ),
                                      onSubmitted: (value) {
                                        final newQuantity = int.tryParse(value);
                                        if (newQuantity == null) return;
                                        if (newQuantity <= 0) {
                                          CartService().removeCartItem(cartItem.id);
                                        } else {
                                          CartService().updateCartItemQuantity(
                                            cartItem.id,
                                            newQuantity,
                                            cartItem.quantity,
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.check,
                                        size: 18, color: Colors.green),
                                    onPressed: () {
                                      final newQuantity =
                                      int.tryParse(qtyController.text);
                                      if (newQuantity == null) return;
                                      if (newQuantity <= 0) {
                                        CartService().removeCartItem(cartItem.id);
                                      } else {
                                        CartService().updateCartItemQuantity(
                                          cartItem.id,
                                          newQuantity,
                                          cartItem.quantity,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add,
                                      size: 20, color: mint),
                                  onPressed: () {
                                    final current =
                                        int.tryParse(qtyController.text) ??
                                            cartItem.quantity;
                                    final updated = current + 1;
                                    CartService().updateCartItemQuantity(
                                      cartItem.id,
                                      updated,
                                      cartItem.quantity,
                                    );
                                    qtyController.text = updated.toString();
                                  },
                                ),
                                Text(
                                  '${cartItem.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_outlined,
                                      size: 20, color: Colors.black54),
                                  onPressed: () {
                                    final current =
                                        int.tryParse(qtyController.text) ??
                                            cartItem.quantity;
                                    if (current <= 1) {
                                      CartService().removeCartItem(cartItem.id);
                                      return;
                                    }
                                    final updated = current - 1;
                                    CartService().updateCartItemQuantity(
                                      cartItem.id,
                                      updated,
                                      cartItem.quantity,
                                    );
                                    qtyController.text = updated.toString();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),

      // ---------- Bottom Checkout Section ----------
      bottomSheet: StreamBuilder<List<CartItem>>(
        stream: CartService().getCartItems(userId),
        builder: (context, snapshot) {
          final cartItems = snapshot.data ?? [];
          final total = cartItems.fold<double>(
              0.0,
                  (prev, e) =>
              prev + ((_editedPrices[e.id] ?? e.price) * e.quantity));

          if (cartItems.isEmpty) return const SizedBox.shrink();

          const shipping = 1.6;
          final subtotal = total - shipping;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Price Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Subtotal",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text(
                      subtotal.toStringAsFixed(1),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Shipping charges",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Text(
                      "1.6",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 0.8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total",
                      style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      total.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Gradient Checkout Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [mint, darkMint],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        Get.defaultDialog(
                          title: "يجب تسجيل الدخول لإتمام العملية",
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                child: const Text("رجوع",
                                    style: TextStyle(color: Colors.black)),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Get.to(const SignIn());
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: mint),
                                child: const Text("تسجيل الدخول",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      } else {
                        final provider =
                        Provider.of<AdminProvider>(context, listen: false);
                        if (provider.isAdmin) {
                          final updatedCartItems = cartItems.map((item) {
                            return CartItem(
                              id: item.id,
                              productName: item.productName,
                              price: _editedPrices[item.id] ?? item.price,
                              quantity: item.quantity,
                              image: item.image,
                              productId: item.productId,
                              productNameEng: item.productNameEng,
                            );
                          }).toList();
                          Get.to(CheckHome(
                              unique: widget.uniqueId,
                              cartItems: updatedCartItems));
                        } else {
                          Get.to(CheckHome(unique: widget.uniqueId, cartItems: []));
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Checkout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
