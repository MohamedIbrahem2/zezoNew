// reset password service
import 'package:firebase_auth/firebase_auth.dart';
// reset password view

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zezo/view/sign_in.dart';

import '../view_model/auth_view_model.dart';
import 'constants.dart';

class ResetPasswordView extends StatelessWidget {
  ResetPasswordView({Key? key}) : super(key: key);
  final AuthViewModel _authViewModel = Get.put(AuthViewModel());

  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('إعادة تعيين كلمة السر'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              SizedBox(height: 50,),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الالكتروني',
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                  onPressed: () async {
                    if(FirebaseAuth.instance.currentUser == null){
                      Get.defaultDialog(
                          title: "لا يمكن اتمام العمليه\n"
                              "يجب تسجيل الدخول",
                          content: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'الرجوع'.tr,
                                  style: const TextStyle(
                                      color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    Colors.white,
                                    elevation: 10),
                              ),
                              ElevatedButton(
                                onPressed: (){
                                  Navigator.pop(context);
                                  Get.to(const SignIn());
                                },
                                child: Text('تسجيل الدخول'.tr,
                                    style: const TextStyle(
                                        color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: mainColor,
                                    elevation: 10),
                              ),
                            ],
                          ));
                    }else{
                      await ResetPasswordService()
                          .resetPassword(_emailController.text.trim());
                      Get.back();
                    }

                  },
                  child: const Text('اعاده تعيين كلمه السر',style: TextStyle(
                    color: Colors.white
                  ),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResetPasswordService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // forgot password

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error resetting password: $e');
    }
  }
}


// forget password service


