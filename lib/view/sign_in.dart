import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:zezo/view/home_view.dart';
import 'package:zezo/view/sign_up.dart';
import '../constants.dart';
import '../view_model/auth_view_model.dart';
import 'complete_profile_page.dart';
import 'forget_password_page.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var controller = Get.put(AuthViewModel());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  var isloading = false;

  Future<void> _signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    user = (await _auth.signInWithCredential(credential)).user;
    if (user != null) {
      _checkUserProfile();
    }
  }

  Future<void> _checkUserProfile() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('name') && data.containsKey('phone')) {
        Get.offAll(const HomeView());
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CompleteProfilePage(user: user)),
        );
      }
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CompleteProfilePage(user: user)),
      );
    }
  }

  Future<UserCredential> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    if (loginResult.status == LoginStatus.success) {
      final AccessToken accessToken = loginResult.accessToken!;
      final OAuthCredential facebookAuthCredential =
      FacebookAuthProvider.credential(accessToken.tokenString);
      return FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
    } else {
      throw FirebaseAuthException(
        code: loginResult.status.toString(),
        message: loginResult.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: ModalProgressHUD(
        opacity: 0.5,
        color: Colors.grey,
        progressIndicator: const CircularProgressIndicator(),
        dismissible: true,
        inAsyncCall: isloading,
        child: GetBuilder<AuthViewModel>(
          init: AuthViewModel(),
          builder: (_) => SingleChildScrollView(
            child: Column(
              children: [
                // ---------- Header (Logo area) ----------
                Stack(
                  children: [
                    Container(
                      height: Get.height * 0.35,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFeafaf1), Color(0xFFf9fafb)],
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Image.asset(
                            'images/logo2.png', // your logo here
                            height: 160,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // ---------- White Card ----------
                Container(
                  transform: Matrix4.translationValues(0, -40, 0),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: formKey,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back !",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Sign in to your account",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black45,
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Email Field
                          TextFormField(
                            onChanged: (value) => controller.email = value,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                              hintText: 'Email Address',
                              filled: true,
                              fillColor: const Color(0xFFF8F8F8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return 'Please enter email';
                              const pattern =
                                  r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$';
                              final regExp = RegExp(pattern);
                              if (!regExp.hasMatch(value)) {
                                return 'Please enter valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            obscureText: true,
                            onChanged: (value) => controller.password = value,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                              suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey),
                              hintText: 'Password',
                              filled: true,
                              fillColor: const Color(0xFFF8F8F8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (value) {
                              if (value!.isEmpty) return 'Please enter password';
                              if (value.contains(' ')) {
                                return 'Password must not contain spaces';
                              }
                              if (value.length < 8) {
                                return 'Password must be more than 8 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),

                          // Forgot Password + Remember
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: true,
                                    onChanged: (_) {},
                                    activeColor: const Color(0xFF27AE60),
                                  ),
                                  const Text(
                                    "Remember me",
                                    style: TextStyle(fontSize: 14, color: Colors.black54),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () => Get.to(const ForgetPasswordPage()),
                                child: const Text(
                                  "Forgot password",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2F80ED),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          // Login Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isloading = true;
                                formKey.currentState!.save();
                                if (formKey.currentState!.validate()) {
                                  controller.signIn();
                                }
                                isloading = false;
                              });
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF6FCF97),
                                    Color(0xFF27AE60),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Sign Up
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don’t have an account? ",
                                style: TextStyle(fontSize: 15, color: Colors.black54),
                              ),
                              GestureDetector(
                                onTap: () => Get.to(SignUp()),
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF27AE60),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

