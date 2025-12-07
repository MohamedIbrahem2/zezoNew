import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:zezo/constants.dart';
import '../view_model/auth_view_model.dart';

class SignUp extends GetWidget<AuthViewModel> {
  TextEditingController name = TextEditingController();
  TextEditingController? vatNum = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController cr = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  var controller = Get.put(AuthViewModel());

  SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: GetBuilder<AuthViewModel>(
        init: AuthViewModel(),
        builder: (_) => SingleChildScrollView(
          child: Column(
            children: [
              // ---------- Header with Logo ----------
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
                      'images/logo2.png',
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // ---------- Signup Card ----------
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Sign up to get started",
                        style: TextStyle(fontSize: 15, color: Colors.black45),
                      ),
                      const SizedBox(height: 25),

                      // ---------- Name ----------
                      TextFormField(
                        controller: name,
                        onChanged: (value) => controller.name = value,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                          hintText: 'Name (Shop name)',
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) return 'Please enter name';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // ---------- Phone ----------
                      IntlPhoneField(
                        controller: phone,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.phone_outlined, color: Colors.grey),
                          hintText: 'Phone',
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        initialCountryCode: 'SA',
                        onChanged: (value) => controller.phone = value.completeNumber,
                        validator: (value) {
                          if (value!.number.isEmpty) return 'Please enter phone';
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // ---------- Email ----------
                      TextFormField(
                        controller: email,
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
                      const SizedBox(height: 15),

                      // ---------- Password ----------
                      TextFormField(
                        controller: password,
                        obscureText: true,
                        onChanged: (value) => controller.password = value,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                          suffixIcon:
                          const Icon(Icons.visibility_off_outlined, color: Colors.grey),
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
                      const SizedBox(height: 25),

                      // ---------- Register Button ----------
                      GestureDetector(
                        onTap: () {
                          formKey.currentState!.save();
                          if (formKey.currentState!.validate()) {
                            controller.signUp();
                          }
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
                              "Register",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ---------- Already have account ----------
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 15, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF27AE60),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
