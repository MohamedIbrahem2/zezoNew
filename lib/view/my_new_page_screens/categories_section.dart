
// Categories section extracted
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../service/category_service.dart';
import '../../../constants.dart';
import '../categories/categories_view.dart';

class CategoriesSection extends StatelessWidget {
  final String uniqueId;
  const CategoriesSection({Key? key, required this.uniqueId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CategoryService().getCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final categories = snapshot.data!;
        return SizedBox(
          height: Get.height * 0.16,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (_, i) {
              final category = categories[i];
              return GestureDetector(
                onTap: () => Get.to(Categories(uniqueId: uniqueId)),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: mainColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.network(category.image, width: 100, height: 100),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
