import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../main.dart';
import '../../service/cart_service.dart';
import '../../service/product_service.dart';
import '../../widgets/shimmer.dart';
import '../bottom_nav/peoduct_details.dart';
class UnavailableProduct extends StatefulWidget {
  const UnavailableProduct({super.key});

  @override
  State<UnavailableProduct> createState() => _UnavailableProductState();
}

class _UnavailableProductState extends State<UnavailableProduct> {
  int count = 1;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.transparent,
          title: const Text("المنتجات الغير متاحه"),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Product>>(
            stream: ProductsService().getUnavailableProducts(),
            builder: (context, snapshot) {

              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return buildShimmer(2);
              }
              final categories = snapshot.data!;
              return Directionality(
                textDirection: TextDirection.rtl,
                child: GridView.builder(
                    gridDelegate:
                    const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: .7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemCount: categories.length,
                    itemBuilder: (BuildContext context, int index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: (){
                          Get.to(ProductDetails(product: category, uniqueId: ""));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: Get.height * 0.08,
                            width: Get.width * 0.4,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 6.0,
                                ),
                              ],
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(0.0, 1.0), //(x,y)
                                              blurRadius: 3.0,
                                            ),
                                          ],
                                          color: mainColor,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child:
                                        SizedBox(
                                            height: Get.height * 0.2,
                                            width: Get.width,
                                            child: Image.network(category.images.first,fit: BoxFit.fill,)),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: Get.height * 0.02,
                                ),
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Container(
                                      child: Text(
                                        textAlign: TextAlign.center,
                                        textDirection: TextDirection.rtl,
                                        category.title,
                                        style: const TextStyle(
                                          height: .5,
                                          overflow: TextOverflow.ellipsis,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
              );
            }));
  }
}
