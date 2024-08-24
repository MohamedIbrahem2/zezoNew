import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:zezo/constants.dart';
import 'package:zezo/view/bottom_nav/edit_product.dart';

import '../../main.dart';
import '../../service/cart_service.dart';
import '../../service/product_service.dart';
import '../my_page_screens/qr_product_view.dart';
import 'cart.dart';

class ProductDetails extends StatefulWidget {
  final Product product;
  final String uniqueId;

  const ProductDetails(
      {super.key, required this.product, required this.uniqueId});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late Product product;

  @override
  void initState() {
    product = widget.product;

    ProductsService().getProductById(product.id).then((event) {
      setState(() {
        product = event;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'تفاصيل المنتج',
          textDirection: TextDirection.rtl,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: CarouselSlider(
                    options: CarouselOptions(height: Get.height * 0.36),
                    items: product.images.map((url) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                                width: Get.width,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.fill,
                                  ),
                                )),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // edit product button
                      Row(
                        children: [
                          provider.isAdmin
                              ? IconButton(
                                  onPressed: () async {
                                    await Get.to(EditProduct(product: product));
                                    print('product id: ${product.id}');
                                    ProductsService()
                                        .getProductById(product.id)
                                        .then((event) {
                                      setState(() {
                                        product = event;
                                      });
                                    });
                                  },
                                  icon: const Icon(Icons.edit),
                                )
                              : Container(),
                          SizedBox(width: Get.width * 0.03),
                          provider.isAdmin
                              ? IconButton(
                                  onPressed: () async{
                                    if (product.favorite) {
                                      await ProductsService()
                                          .removeProductFromFavorite(product);
                                      Get.defaultDialog(
                                        middleText: "",
                                        title: product.brand.tr +
                                            " Removed successfully from Favorite",
                                      );
                                    } else {
                                      await ProductsService()
                                          .addProductToFavorite(product);
                                      Get.defaultDialog(
                                        middleText: "",
                                        title: product.brand.tr +
                                            " Added successfully to Favorite.",
                                      );
                                    }
                                  },
                                  icon:  Icon(
                                      product.favorite ? Icons.favorite_outlined: Icons.favorite_outline_outlined))
                              : Container()
                          // qr code button

                          // provider.isAdmin ? IconButton(
                          //     onPressed: () {
                          //       Get.to(ProductQrImageView(
                          //           id: product.id,
                          //           productName: product.brand));
                          //     },
                          //     icon: const Icon(Icons.qr_code_scanner_outlined)):
                          //     Container()

                          // IconButton(
                          //   onPressed: () {
                          //     // ProductService().deleteProduct(product.id);
                          //     Navigator.pop(context);
                          //   },
                          //   icon: const Icon(Icons.delete),
                          // ),
                        ],
                      ),

                      Text(
                        product.title,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        product.brand,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                            fontSize: 19, color: Colors.black45),
                      ),
                      SizedBox(height: Get.height * 0.03),
                      Text(
                        textDirection: TextDirection.rtl,
                        product.description,
                        style: const TextStyle(
                          fontSize: 17,
                        ),
                      ),
                      SizedBox(height: Get.height * 0.03),
                      Text(
                        textDirection: TextDirection.rtl,
                        'السعر: SR ${product.regularPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: Get.height * 0.03),
                      Text(
                        textDirection: TextDirection.rtl,
                        'التخفيض: ${product.discountPrice}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(height: Get.height * 0.03),
                      // Text(
                      //   'Category: ${product.categoryId}',
                      //   style: const TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.normal,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   'Subcategory: ${product.subcategoryId}',
                      //   style: const TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.normal,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   'Sales Count: ${product.salesCount}',
                      //   style: const TextStyle(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.normal,
                      //   ),
                      // ),
                      SizedBox(height: Get.height * 0.03),
                      // total price
                      Text(
                        textDirection: TextDirection.rtl,
                        'السعر الكلي: SR ${(product.regularPrice - product.discountPrice).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: Get.height * 0.03),
            Row(
              children: [
                provider.isAdmin
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor),
                              onPressed: () async {
                                await ProductsService()
                                    .addProductToBestSelling(product);
                                if (product.isbestselling) {
                                  Get.defaultDialog(
                                    middleText: "",
                                    title: product.brand.tr +
                                        " Already in bestSelling",
                                  );
                                } else {
                                  Get.defaultDialog(
                                    middleText: "",
                                    title: product.brand.tr +
                                        " Added successfully to BestSelling.",
                                  );
                                }
                              },
                              child: const Text(
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(color: Colors.white),
                                  "أضافه الي الأعلي مبيعا")),
                        ),
                      )
                    : Container(),
                provider.isAdmin
                    ? Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black),
                              onPressed: () async {
                                await ProductsService()
                                    .removeProductFromBestSelling(product);
                                if (product.isbestselling) {
                                  Get.defaultDialog(
                                    middleText: "",
                                    title: product.brand.tr +
                                        " Removed successfully from BestSelling.",
                                  );
                                } else {
                                  Get.defaultDialog(
                                    middleText: "",
                                    title: product.brand.tr +
                                        " Already not in bestSelling",
                                  );
                                }
                              },
                              child: const Text(
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(color: Colors.white),
                                  "حذف من الأعلي مبيعا")),
                        ),
                      )
                    : Container(),
              ],
            ),
            SizedBox(height: Get.height * 0.03),
            Row(
              children: [
                provider.isAdmin
                    ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: mainColor),
                        onPressed: () async {
                          await ProductsService()
                              .productNotAvailable(product.id);
                          if (!product.available) {
                            Get.defaultDialog(
                              middleText: "",
                              title: product.brand.tr +
                                  " Already in UnavialableProducts",
                            );
                          } else {
                            Get.defaultDialog(
                              middleText: "",
                              title: product.brand.tr +
                                  " Added successfully to UnavialableProducts.",
                            );
                          }
                        },
                        child: const Text(
                            textDirection: TextDirection.rtl,
                            style: TextStyle(color: Colors.white),
                            "أضافه الي غير المتاحه")),
                  ),
                )
                    : Container(),
                provider.isAdmin
                    ? Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black),
                        onPressed: () async {
                          await ProductsService()
                              .productAvailable(product.id);
                          if (!product.available) {
                            Get.defaultDialog(
                              middleText: "",
                              title: product.brand.tr +
                                  " Removed successfully from UnavialableProducts.",
                            );
                          } else {
                            Get.defaultDialog(
                              middleText: "",
                              title: product.brand.tr +
                                  " Already not in UnavialableProducts",
                            );
                          }
                        },
                        child: const Text(
                            textDirection: TextDirection.rtl,
                            style: TextStyle(color: Colors.white),
                            "حذف من الغير المتاحه")),
                  ),
                )
                    : Container(),
              ],
            ),
            SizedBox(height: Get.height * 0.04),
            StreamBuilder<List<CartItem>>(
                stream: CartService().getCartItemsByProductId(
                    FirebaseAuth.instance.currentUser != null
                        ? FirebaseAuth.instance.currentUser!.uid
                        : widget.uniqueId,
                    product.id),
                builder: (context, snapshot) {
                  final quantity =
                      (snapshot.data == null || snapshot.data!.isEmpty)
                          ? 0
                          : snapshot.data
                              ?.map((e) => e.quantity)
                              .reduce((value, element) => value + element);
                  final items = snapshot.data;
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: mainColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                        SizedBox(width: Get.width * 0.06),
                        GestureDetector(
                          onTap: () {
                            Get.to(Screen2(
                              uniqueId: widget.uniqueId,
                            ));
                          },
                          child: const Text(
                            textDirection: TextDirection.rtl,
                            'الذهاب الي عربه التسوق',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        //       await CartService().addToCart(
                        //   FirebaseAuth.instance.currentUser!.uid,
                        //   product,
                        // );
                        Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  if(!product.available){
                                    Get.snackbar("لا يمكن اتمام العمليه", "هذا المنتج غير متاح حاليا");
                                  }else{
                                    CartService().addToCart(
                                      productId: product.id,
                                      userId: FirebaseAuth.instance.currentUser !=
                                          null
                                          ? FirebaseAuth.instance.currentUser!.uid
                                          : widget.uniqueId,
                                      quantity: 0,
                                      productName: product.brand,
                                      image: product.images.first,
                                      price: product.regularPrice,

                                      // product: product,
                                    );
                                  }

                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                )),
                            Text(
                              quantity.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  if (items != null) {
                                    CartService().updateCartItemQuantity(
                                        items[0].id, quantity! - 1, quantity);
                                  }
                                },
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                )),
                          ],
                        )
                      ],
                    ),
                  );
                })
            // add to cart button
            ,
          ],
        ),
      ),
    );
  }
}
