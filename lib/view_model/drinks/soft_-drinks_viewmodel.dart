import 'package:get/get.dart';
import 'package:zezo/model/drinks/soft_drinks_model.dart';
import 'package:zezo/service/products_service.dart';

class SoftDrinksViewModel extends GetxController {
  List<SoftDrinksModel> softDrinksModel = [];

  SoftDrinksViewModel() {
    getSoftDrinks();
  }

  getSoftDrinks() async {
    ProductService().getSoftDeinks().then((value) {
      for (int i = 0; i < value.length; i++) {
        softDrinksModel.add(SoftDrinksModel.fromjson(value[i].data()));
      }
      update();
    });
  }
}
