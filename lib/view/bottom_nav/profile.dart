import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../main.dart';
import '../../reset_password.dart';
import '../addresses_pge.dart';
import '../my_page_screens/edit_profile.dart';
import '../my_page_screens/notifications_page.dart';
import '../my_page_screens/oreder_history.dart';
import '../sign_in.dart';

class Settings extends StatefulWidget {
  final dynamic uniqueId;
  const Settings({super.key, required this.uniqueId});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String? name, email, pic;
  bool isLoading = false;
  UserProfile? userProfile;
  final _authService = AuthService();

  getUserProfile() async {
    try {
      isLoading = true;
      setState(() {});
      userProfile = await _authService
          .getUserProfile(FirebaseAuth.instance.currentUser!.uid);
      isLoading = false;
      setState(() {});
    } catch (e) {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const Color mint = Color(0xFF27AE60);
    const Color lightGray = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser != null
            ? FirebaseAuth.instance.currentUser!.uid
            : widget.uniqueId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading user data'));
          }

          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final name = data['name'] ?? 'User';
          final photo = data['photo'];
          final email = FirebaseAuth.instance.currentUser?.email ?? 'no email';

          return Directionality(
            textDirection: TextDirection.ltr,
            child: Container(
              color: lightGray,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // Profile Photo
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage:
                          photo != null ? NetworkImage(photo) : null,
                          child: photo == null
                              ? const Icon(Icons.person,
                              size: 60, color: Colors.grey)
                              : null,
                        ),
                        Positioned(
                          bottom: 4,
                          right: 6,
                          child: Container(
                            height: 26,
                            width: 26,
                            decoration: BoxDecoration(
                              color: mint,
                              borderRadius: BorderRadius.circular(50),
                              border:
                              Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Name & Email
                    Text(
                      name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey, height: 1.2),
                    ),

                    const SizedBox(height: 30),

                    // Settings List
                    Container(
                      color: lightGray,
                      child: Column(
                        children: [
                          _buildTile(
                            icon: Icons.person_outline,
                            title: 'Edit Profile'.tr,
                            onTap: () => Get.to(Form(
                                child: Editprofile(uniqueId: widget.uniqueId))),
                          ),
                          _buildTile(
                            icon: Icons.lock_outline,
                            title: 'Reset Password'.tr,
                            onTap: () => Get.to(ResetPasswordView()),
                          ),
                          _buildTile(
                            icon: Icons.location_on_outlined,
                            title: 'shipping_address'.tr,
                            onTap: () =>
                                Get.to(AddressesPage(uniqueId: widget.uniqueId)),
                          ),
                          _buildTile(
                            icon: Icons.history,
                            title: 'Order History'.tr,
                            onTap: () {
                              if (FirebaseAuth.instance.currentUser == null) {
                                Get.snackbar('', 'please_login'.tr);
                                Get.to(const SignIn());
                              } else {
                                Get.to(const OrderHistory());
                              }
                            },
                          ),
                          _buildTile(
                            icon: Icons.notifications_none_outlined,
                            title: 'notifications'.tr,
                            onTap: () {
                              if (FirebaseAuth.instance.currentUser == null) {
                                Get.snackbar('', 'please_login'.tr);
                                Get.to(const SignIn());
                              } else {
                                Get.to(NotificationsPage(
                                    userId: FirebaseAuth
                                        .instance.currentUser!.uid));
                              }
                            },
                          ),
                          _buildTile(
                            icon: Icons.logout,
                            title: 'logout'.tr,
                            onTap: () {
                              if (FirebaseAuth.instance.currentUser == null) {
                                Get.snackbar('', 'please_login'.tr);
                                Get.to(const SignIn());
                              } else {
                                Get.defaultDialog(
                                  title: 'Are you sure?'.tr,
                                  content: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 3),
                                        child: Text('No'.tr,
                                            style: const TextStyle(
                                                color: Colors.black)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Get.to(const SignIn());
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            elevation: 3),
                                        child: Text('yes'.tr,
                                            style: const TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
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
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    const Color mint = Color(0xFF27AE60);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: mint, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87),
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                color: Colors.black26, size: 18),
          ],
        ),
      ),
    );
  }
}