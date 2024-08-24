import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:zezo/service/category_service.dart';
import 'package:zezo/view/categories/products_by_categories_view.dart';

import '../../../constants.dart';
import '../../service/product_service.dart';
import '../../widgets/shimmer.dart';

class Categories extends StatefulWidget {
  final String uniqueId;
  const Categories({super.key, required this.uniqueId});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Container(),
          backgroundColor: Colors.transparent,
          title: const Text("جميع الأصناف"),
          centerTitle: true,
        ),
        body: StreamBuilder<List<Category>>(
            stream: CategoryService().getCategories(),
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
                          Get.to(ProductsByCategories(categoryId: category.id, uniqueId: widget.uniqueId));
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
                                                child: Image.network(category.image,fit: BoxFit.fill,)),
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
                                        category.name,
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
