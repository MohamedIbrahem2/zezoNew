import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:zezo/service/category_service.dart';

import '../../../constants.dart';
import '../../main.dart';
import '../../service/cart_service.dart';
import '../../service/product_service.dart';
import '../../widgets/shimmer.dart';
import '../bottom_nav/peoduct_details.dart';

class ProductsByCategories extends StatefulWidget {
  final String categoryId;
  final String uniqueId;
  const ProductsByCategories({super.key, required this.categoryId, required this.uniqueId});

  @override
  State<ProductsByCategories> createState() => _ProductsByCategoriesState();
}
int count = 1;
class _ProductsByCategoriesState extends State<ProductsByCategories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Container(),
          backgroundColor: Colors.transparent,
          title: const Text("المنتجات"),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Product>>(
          stream: ProductsService().getProductsByCategory(widget.categoryId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return buildShimmer(2);
            }
            final products = snapshot.data!;

            return GridView.builder(
              //  physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              shrinkWrap: true,
              gridDelegate:
              const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: .7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onLongPress: () {
                      final provider = Provider.of<AdminProvider>(
                          context,
                          listen: false);
                      if (provider.isAdmin) {
                        Get.defaultDialog(
                            title: 'Do you want to delete ' +
                                product.brand.tr +
                                " product ?",
                            content: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceAround,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'no'.tr,
                                    style: const TextStyle(
                                        color: Colors.black),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      Colors.white,
                                      elevation: 10),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await ProductsService()
                                        .deleteProductFromBestSelling(
                                        product.id);
                                    ProductsService()
                                        .deleteProduct(
                                        product.id);
                                    Navigator.pop(context);
                                  },
                                  child: Text('yes'.tr,
                                      style: const TextStyle(
                                          color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      elevation: 10),
                                ),
                              ],
                            ));
                      }
                    },
                    onTap: () {
                      final provider = Provider.of<AdminProvider>(
                          context,
                          listen: false);
                      Get.to(ProductDetails(
                        product: product,
                        uniqueId: widget.uniqueId,
                      ));
                    },
                    child: Container(
                      height: Get.height * 0.09,
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
                          borderRadius:
                          BorderRadius.circular(13)),
                      child: Column(
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CachedNetworkImage(
                              imageUrl: product.images.first,
                              //fit: BoxFit.fill,
                              imageBuilder:
                                  (context, imageProvider) =>
                                  Container(
                                    //  width: Get.width * .35,
                                    height: Get.height * .115,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                        )),
                                  ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Container(
                              child: Text(
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                                product.title,
                                maxLines: 2,
                                style: const TextStyle(
                                    height: .95,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              product.brand,
                              maxLines: 2,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45),
                            ),
                          ),
                          Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                  padding:
                                  const EdgeInsets.all(1.0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      if (product.discountPrice >
                                          0)
                                        Stack(
                                          alignment:
                                          Alignment.center,
                                          children: [
                                            Text(
                                              product.regularPrice
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight:
                                                  FontWeight
                                                      .bold,
                                                  color: Colors
                                                      .black),
                                            ),
                                            Container(
                                              width: 15,
                                              height: 1.5,
                                              color: mainColor,
                                            )
                                          ],
                                        ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      if (product.discountPrice >
                                          0)
                                        Text(
                                          (product.regularPrice -
                                              product
                                                  .discountPrice)
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 17,
                                              fontWeight:
                                              FontWeight.bold,
                                              color:
                                              mainColor),
                                        ),
                                      if (product.discountPrice ==
                                          0)
                                        Text(
                                          product.regularPrice
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight:
                                              FontWeight.bold,
                                              color:
                                              mainColor),
                                        ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    width: Get.width * 0.065,
                                    height: Get.height * 0.03,
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        // if(FirebaseAuth.instance.currentUser == null){
                                        //   Get.snackbar("لا يمكن اتمام العمليه", "لأتمام العمليه يجب تسجيل الدخول");
                                        //   Get.to(const SignIn());
                                        // }else{
                                        if(!product.available){
                                          Get.snackbar("لا يمكن اتمام العمليه", "هذا المنتج غير متاح حاليا");
                                        }else{
                                          final result = await CartService()
                                              .isProductInCart(
                                              product.id,
                                              FirebaseAuth.instance
                                                  .currentUser !=
                                                  null
                                                  ? FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid
                                                  : widget
                                                  .uniqueId);
                                          // if (result != null && result > 0) {
                                          //   // remove snakebar

                                          //   Get.snackbar(
                                          //       'Sorry', 'Product already in cart');
                                          // }
                                          CartService().addToCart(
                                            productId: product.id,
                                            productName:
                                            product.brand,
                                            price: product
                                                .regularPrice -
                                                product
                                                    .discountPrice,
                                            quantity: count,
                                            userId: FirebaseAuth
                                                .instance
                                                .currentUser !=
                                                null
                                                ? FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid
                                                : widget.uniqueId,
                                            image: product
                                                .images.first,
                                          );
                                        }

                                      },
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton
                                          .styleFrom(
                                          padding:
                                          EdgeInsets.zero,
                                          backgroundColor:
                                          mainColor),
                                    ),
                                  ),
                                )
                              ])
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
