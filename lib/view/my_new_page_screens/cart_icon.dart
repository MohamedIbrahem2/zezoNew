import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../service/cart_service.dart';

class CartIcon extends StatelessWidget {
  final String uniqueId;
  const CartIcon({Key? key, required this.uniqueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 15, top: 6),
          child: Icon(Icons.shopping_cart_outlined, size: 30, color: Colors.black),
        ),
        StreamBuilder(
          stream: CartService().getCartItems(
            FirebaseAuth.instance.currentUser?.uid ?? uniqueId,
          ),
          builder: (context, snapshot) {
            final quantity = (snapshot.data == null || (snapshot.data as List).isEmpty)
                ? 0
                : (snapshot.data as List)
                .map((e) => e.quantity)
                .reduce((a, b) => a + b);

            return Positioned(
              left: 18,
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                width: 25,
                height: 25,
                child: Center(
                  child: Text(
                    quantity >= 100 ? "99+" : quantity.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
