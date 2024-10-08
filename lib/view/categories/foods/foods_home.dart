import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zezo/view/categories/foods/indome.dart';
import 'package:zezo/view/categories/foods/macarona.dart';
import 'package:zezo/view/categories/foods/rice.dart';

class FoodsHome extends StatelessWidget {
  const FoodsHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Foods',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade50,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: Get.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: Get.height * .02,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 30,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 1),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(const Indomie());
                },
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.grey)
                          ]),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Image.network(
                        'https://cdnprod.mafretailproxy.com/sys-master-root/h14/h23/17010310643742/478324_main.jpg_480Wx480H',
                        fit: BoxFit.fill,
                      ),
                      width: Get.width * .4,
                      height: Get.height * .15,
                    ),
                    const Text(
                      'Indomie',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(const Macarona());
                },
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.grey)
                          ]),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Image.network(
                        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGvOYa8ufkHGf45SyX2BnNWb53ZZ8t6aVpnChefMtW6rtEzxjdehQKHePdTWumH5b6vos&usqp=CAU',
                        fit: BoxFit.fill,
                      ),
                      width: Get.width * .4,
                      height: Get.height * .15,
                    ),
                    const Text(
                      'Macarona',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              GestureDetector(
                onTap: () {
                  Get.to(const Rice());
                },
                child: Column(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 5,
                                color: Colors.grey)
                          ]),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Image.network(
                        'https://www.filloffer.com/storage/resized_ahr0chm6ly9hc2hpywutynvja2v0lnmzlmv1lxdlc3qtmy5hbwf6b25hd3muy29tl3byb2r1y3rzl3vuz0vkc2nfrevuzjjjd0n1yzh1mdhmruthbzlxcmj0z0rtvethzmeuanbn.jpg',
                        fit: BoxFit.fill,
                      ),
                      width: Get.width * .4,
                      height: Get.height * .15,
                    ),
                    const Text(
                      'Rice',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
