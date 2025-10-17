import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../constants.dart';
import '../drawer_screens/language.dart';
import '../drawer_screens/obout_us.dart';
import '../drawer_screens/prfile_screen.dart';
import '../drawer_screens/technical_support.dart';
import '../drawer_screens/wallet.dart';
import '../my_page_screens/our_location_page.dart';
import '../sign_in.dart';

class HomeDrawer extends StatelessWidget {
  final String uniqueId;
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  const HomeDrawer({
    Key? key,
    required this.uniqueId,
    required this.auth,
    required this.googleSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              child: Image.asset('images/logo_zezo.png'),
              height: Get.height * .2,
              color: Colors.blue.shade50,
            ),
            ListTile(
              title: Text('account_points'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Get.to(const Wallet()),
            ),
            ListTile(
              title: Text('technical_support'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Get.to(const TechnicalSupport()),
            ),
            ListTile(
              title: Text('profile'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Get.to(const PrfileScreen()),
            ),
            ListTile(
              title: Text('language'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.language_outlined),
              onTap: () => Get.to(const Language()),
            ),
            ListTile(
              title: Text('who_we_are'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Get.to(const AboutUs()),
            ),
            ListTile(
              title: Text('our_location'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
              onTap: () => Get.to(const OurLocationPage()),
            ),
            FirebaseAuth.instance.currentUser == null
                ? ListTile(
              title: Text('login'.tr, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
              onTap: () => Get.to(const SignIn()),
            )
                : ListTile(
              title: Text('logout'.tr, style: TextStyle(color: mainColor, fontWeight: FontWeight.bold)),
              onTap: () {
                Get.defaultDialog(
                  title: 'are you sure?'.tr,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('no'.tr, style: const TextStyle(color: Colors.black)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          auth.signOut();
                          googleSignIn.disconnect();
                          Get.offAll(const SignIn());
                        },
                        child: Text('yes'.tr, style: const TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
