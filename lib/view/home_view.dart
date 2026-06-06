import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zezo/constants.dart';
import 'package:zezo/main.dart';
import 'package:zezo/service/cart_service.dart';
import 'package:zezo/view/bottom_nav/cart.dart';
import 'package:zezo/view/bottom_nav/profile.dart';
import 'package:zezo/view_model/auth_view_model.dart';
import 'package:uuid/uuid.dart';

import '../bottom_navbar_provider.dart';
import 'bottom_nav/home.dart';
class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _uniqueId = "";
  final AuthViewModel yourController =
  Get.put(AuthViewModel()..getUserProfile());

  List<Widget> screens = [];

  Future<void> _getUniqueId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? uniqueId = prefs.getString('unique_id');

    if (uniqueId == null) {
      uniqueId = const Uuid().v4();
      await prefs.setString('unique_id', uniqueId);
    }

    setState(() {
      _uniqueId = uniqueId!;
      _initializeScreens();
    });
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      print('⚠️ No user signed in. Cannot change cart items.');
      return;
    }

    CartService().changeCartItems(currentUser.uid, _uniqueId);

  }

  void _initializeScreens() {
    screens = [
      HomePage(uniqueId: _uniqueId),
      Screen2(uniqueId: _uniqueId),
      Settings(uniqueId: _uniqueId),
    ];
  }

  @override
  void initState() {
    _getUniqueId();
    AdminProvider().checkIfAdmin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: context.select<BottomNavbarProvider, int>((p) => p.currentIndex) == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final provider = Provider.of<BottomNavbarProvider>(context, listen: false);
        if (provider.currentIndex != 0) {
          provider.changeIndex(0);
        }
      },
      child: Scaffold(
        body: _uniqueId == ""
            ? const Center(child: CircularProgressIndicator())
            : Selector<BottomNavbarProvider, int>(
                selector: (_, p) => p.currentIndex,
                builder: (context, currentIndex, _) => IndexedStack(
                  index: currentIndex,
                  children: screens,
                ),
              ),
        bottomNavigationBar: Selector<BottomNavbarProvider, int>(
          selector: (_, p) => p.currentIndex,
          builder: (context, currentIndex, _) => Container(
            height: Get.height * 0.102,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40), topLeft: Radius.circular(40)),
                boxShadow: [
                  BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 5)
                ]),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(30), topLeft: Radius.circular(30)),
              child: BottomNavigationBar(
                unselectedItemColor: Colors.black,
                selectedItemColor: Colors.white,
                backgroundColor: mainColor,
                onTap: (val) {
                  Provider.of<BottomNavbarProvider>(context, listen: false)
                      .changeIndex(val);
                },
                currentIndex: currentIndex,
                items: [
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.home_outlined), label: 'home'.tr),
                  BottomNavigationBarItem(
                      icon: StreamBuilder<List<CartItem>>(
                        stream: CartService().getCartItems(
                            FirebaseAuth.instance.currentUser?.uid ?? _uniqueId),
                        builder: (context, snapshot) {
                          final quantity = (snapshot.data == null || snapshot.data!.isEmpty)
                              ? 0
                              : snapshot.data!.map((e) => e.quantity).fold<int>(0, (a, b) => a + b);
                          
                          if (quantity == 0) {
                            return const Icon(Icons.shopping_cart_outlined);
                          }
                          
                          final label = quantity.toString();
                          
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(Icons.shopping_cart_outlined),
                              Positioned(
                                right: -8,
                                top: -8,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      label: 'cart'.tr),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.account_circle_outlined),
                      label: 'my_page'.tr),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}