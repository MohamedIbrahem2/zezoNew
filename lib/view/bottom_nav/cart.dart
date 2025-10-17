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
  // Map to store locally edited prices (itemId -> editedPrice)
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
    final provider = Provider.of<AdminProvider>(
        context,
        listen: false);
    String userId = FirebaseAuth.instance.currentUser?.uid ?? widget.uniqueId;

    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("cart".tr, style: const TextStyle(color: Colors.white))),
        backgroundColor: mainColor,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 100),
        child: StreamBuilder<List<CartItem>>(
          stream: CartService().getCartItems(userId),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('Something went wrong'));
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());

            final cartItems = snapshot.data ?? [];

            if (cartItems.isEmpty) {
              return Center(child: Text('no_products'.tr, textDirection: TextDirection.rtl));
            }

            return ListView.separated(
              separatorBuilder: (_, __) => SizedBox(height: Get.height * 0.03),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {

                final cartItem = cartItems[index];
                final qtyController = _qtyControllers.putIfAbsent(
                  cartItem.id,
                      () => TextEditingController(text: cartItem.quantity.toString()),
                );
                // Use edited price if available, otherwise use the original price
                final currentPrice = _editedPrices[cartItem.id] ?? cartItem.price;
                final priceController = TextEditingController(text: currentPrice.toString());
                bool isEditingPrice = false;

                return StatefulBuilder(
                  builder: (context, setStateTile) => SizedBox(
                    height: Get.height * 0.18,
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Product Image
                            SizedBox(
                              width: 60,
                              height: 60,
                              child: CachedNetworkImage(
                                imageUrl: cartItem.image,
                                placeholder: (_, __) =>
                                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorWidget: (_, __, ___) => const Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Title + Price
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Product Name
                                  Text(
                                    cartItem.productName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  // Price (admin editable or normal)
                                  Row(
                                    children: [
                                      if (provider.isAdmin && isEditingPrice)
                                        SizedBox(
                                          width: 80,
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
                                          '${currentPrice.toStringAsFixed(2)} SAR',
                                          style: const TextStyle(fontSize: 13, color: Colors.black87),
                                        ),

                                      if (provider.isAdmin)
                                        IconButton(
                                          icon: Icon(isEditingPrice ? Icons.check : Icons.edit),
                                          onPressed: () {
                                            if (isEditingPrice) {
                                              final newPrice =
                                                  double.tryParse(priceController.text) ?? currentPrice;
                                              setState(() {
                                                _editedPrices[cartItem.id] = newPrice;
                                              });
                                            }
                                            setStateTile(() => isEditingPrice = !isEditingPrice);
                                          },
                                          iconSize: 20,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Controls
                            SizedBox(
                              width: 92,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Plus button
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.add, size: 20),
                                    onPressed: () {
                                      final current = int.tryParse(qtyController.text) ?? cartItem.quantity;
                                      final updated = current + 1;
                                      CartService().updateCartItemQuantity(
                                        cartItem.id,
                                        updated,
                                        cartItem.quantity,
                                      );
                                      qtyController.text = updated.toString();
                                    },
                                  ),


                                  provider.isAdmin ? Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 2),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 36,
                                          height: 28,
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
                                          icon: const Icon(Icons.check, size: 18, color: Colors.green),
                                          onPressed: () {
                                            final newQuantity = int.tryParse(qtyController.text);
                                            if (newQuantity == null) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Please enter a valid number')),
                                              );
                                              return;
                                            }
                                            if (newQuantity <= 0) {
                                              CartService().removeCartItem(cartItem.id);
                                            } else {
                                              CartService().updateCartItemQuantity(
                                                cartItem.id,
                                                newQuantity,
                                                cartItem.quantity,
                                              );
                                              qtyController.text = newQuantity.toString();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ) : Text('${cartItem.quantity}'),

                                  // Minus button
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: const Icon(Icons.remove_outlined, size: 20),
                                    onPressed: () {
                                      final current = int.tryParse(qtyController.text) ?? cartItem.quantity;
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
      bottomSheet: StreamBuilder<List<CartItem>>(
        stream: CartService().getCartItems(userId),
        builder: (context, snapshot) {
          final cartItems = snapshot.data ?? [];

          // Calculate total using edited prices where available
          final total = cartItems.fold<double>(0.0, (prev, e) {
            final price = _editedPrices[e.id] ?? e.price;
            return prev + (price * e.quantity);
          });

          if (total == 0) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: BottomSheet(
                elevation: 20,
                onClosing: () {},
                builder: (_) => InkWell(
                  onTap: () {
                    BottomNavbarProvider.instance(context, listen: false).changeIndex(0);
                    Get.offAll(const HomeView());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: Get.width,
                    height: Get.height * 0.07,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_shopping_cart, color: Colors.white),
                        const SizedBox(width: 10),
                        Text(
                          'go_main_screen'.tr,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return BottomSheet(
            elevation: 20,
            onClosing: () {},
            builder: (_) => Container(
              padding: const EdgeInsets.only(top: 10),
              width: Get.width,
              height: Get.height * 0.09,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text('all'.tr, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 19, color: Colors.grey)),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: total.toStringAsFixed(2),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: mainColor)),
                        const TextSpan(text: '  SAR', style: TextStyle(fontSize: 18, color: Colors.black)),
                      ])),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (FirebaseAuth.instance.currentUser == null) {
                        Get.defaultDialog(
                          title: "لا يمكن اتمام العمليه\nيجب تسجيل الدخول",
                          content: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('go_back'.tr, style: const TextStyle(color: Colors.black)),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, elevation: 10),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Get.to(const SignIn());
                                },
                                child: Text('login'.tr, style: const TextStyle(color: Colors.white)),
                                style: ElevatedButton.styleFrom(backgroundColor: mainColor, elevation: 10),
                              ),
                            ],
                          ),
                        );
                      } else {
                        // Create updated cart items with edited prices
                        if (provider.isAdmin) {
                          final updatedCartItems = cartItems.map((item) {
                            // Create a copy of the item with the edited price if available
                            return CartItem(
                              id: item.id,
                              productName: item.productName,
                              price: _editedPrices[item.id] ?? item.price, // Use edited price if available
                              quantity: item.quantity,
                              image: item.image,
                              productId: item.productId,
                              productNameEng: item.productNameEng,
                              // Include other properties as needed
                            );
                          }).toList();
                          // Pass updated cartItems list to CheckHome
                          Get.to(CheckHome(unique: widget.uniqueId, cartItems: updatedCartItems));
                        }else{
                          Get.to(CheckHome(unique: widget.uniqueId, cartItems: []));
                        }


                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainColor,
                      fixedSize: const Size(150, 45),
                    ),
                    child: Text(
                      'checkout'.tr,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}