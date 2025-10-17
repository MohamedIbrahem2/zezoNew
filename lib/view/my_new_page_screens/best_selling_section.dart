
// Best selling products section extracted
import 'package:flutter/material.dart';
import '../../../service/product_service.dart';

class BestSellingSection extends StatelessWidget {
  const BestSellingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: ProductsService().getBestSellingProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        final best = snapshot.data!;
        return ListView.builder(
          itemCount: best.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (_, i) => ListTile(title: Text(best[i].brand)),
        );
      },
    );
  }
}
