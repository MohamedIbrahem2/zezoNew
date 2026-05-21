import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zezo/service/product_service.dart';

import '../../service/category_service.dart';
import '../../service/subcategory_service.dart';
import '../../service/upload_image_service.dart';

class EditProduct extends StatefulWidget {

  const EditProduct({super.key, required this.product});
  final Product product;

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  File? _imageFile;
  String _imageUrl = '';
  final FirebaseStorageService _storageService = FirebaseStorageService();
  final ImagePicker _imagePicker = ImagePicker();
  final nameController = TextEditingController();
  final name2Controller = TextEditingController();
  var priceController = TextEditingController();
  var deiscountController = TextEditingController();
  var discountPercentController = TextEditingController();
  var quantityDiscountController = TextEditingController();
  var defaultcategory;
  @override
  void initState() {
    // priceController.text = '0';
    // deiscountController.text = '0';
    nameController.text = widget.product.title;
    name2Controller.text = widget.product.brand;
    priceController.text = widget.product.regularPrice.toString();
    deiscountController.text = widget.product.discountPrice.toString();
    discountPercentController.text =
        ((widget.product.discountPercentage ?? 0) * 100).toInt().toString();

    quantityDiscountController.text =
        widget.product.quantityDiscount?.toString() ?? '0';
    _imageUrl = widget.product.images.first;
    defaultcategory = widget.product.category;

    // CategoryService().getCategoryById(widget.product.categoryId).then((value) {
    //   setState(() {

    //     category = value;
    //   });
    // });
    // SubCategoryService()
    //     .getSubcategoryById(widget.product.subcategoryId)
    //     .then((value) {
    //   setState(() {
    //     subcategory = value;
    //   });
    // });
    super.initState();
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile != null) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      String imageUrl =
          await _storageService.uploadImage(_imageFile!, fileName);
      setState(() {
        _imageUrl = imageUrl;
      });
    }
  }

  bool isLoading = false;
  String error = '';
  final _fromKey = GlobalKey<FormState>();

  Category? category;
  Subcategory? subcategory;
  @override
  Widget build(BuildContext context) {
    ImageProvider? getImagePovider() {
      if (_imageFile != null) {
        return FileImage(_imageFile!);
      }
      if (widget.product.images.first.isNotEmpty) {
        return NetworkImage(widget.product.images.first);
      }
      return null;
    }

    return Scaffold(
        appBar: AppBar(
          title:  Text('edit product'.tr),
        ),
        body: Form(
          key: _fromKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          height: 100,
                          width: 100,
                          child: const Icon(Icons.image),
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                image: getImagePovider()!,
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  StreamBuilder<List<Category>>(
                      stream: CategoryService().getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('error'),
                          );
                        }
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final categories = snapshot.data;
                        return DropdownButtonFormField<Category>(
                            value: category,
                            decoration: InputDecoration(
                              labelText: widget.product.category,
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            items: categories!
                                .map((e) => DropdownMenuItem<Category>(
                                      child: Text(e.name),
                                      value: e,
                                    ))
                                .toList(),
                            onChanged: (v) {
                              setState(() {
                                category = v;
                                subcategory = null;
                              });
                              print(category);
                            });
                      }),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter products name';
                      }
                      return null;
                    },
                    decoration:  InputDecoration(
                      labelText: 'product name'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: name2Controller,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter products name';
                      }
                      return null;
                    },
                    decoration:  InputDecoration(
                      labelText: 'product name'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    controller: priceController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter price';
                      }
                      return null;
                    },
                    decoration:  InputDecoration(
                      labelText: 'price'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: deiscountController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter price';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,

                    decoration:  InputDecoration(
                      labelText: 'discount'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: discountPercentController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter discount percentage';
                      }

                      final v = int.tryParse(value);
                      if (v == null || v < 0 || v > 100) {
                        return 'Value must be between 0 and 100';
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'discount percentage (0 - 100)%'.tr,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: quantityDiscountController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter quantity discount';

                      final v = int.tryParse(value);
                      if (v == null || v < 0) {
                        return 'Invalid quantity';
                      }

                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'quantity discount'.tr,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // add button
                  if (isLoading)
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                  else
                    ElevatedButton(
                      onPressed: () async {
                        if (_fromKey.currentState!.validate()) {
                          print(category);
                          if (category == null) {
                            Get.snackbar('Error', 'Please select category');
                            return;
                          }

                          try {
                            setState(() {
                              isLoading = true;
                            });

                            // Initialize image upload
                            await _uploadImage();

                            if (_imageUrl.isNotEmpty) {
                              // Update the product
                              await ProductsService().updateProduct(widget.product.copyWith(
                                title: nameController.text,
                                brand: name2Controller.text,
                                regularPrice: double.parse(priceController.text),
                                discountPrice: double.parse(deiscountController.text),
                                images: [_imageUrl],
                                categoryId: category!.id,
                                discountPercentage: double.parse(discountPercentController.text) / 100,
                                quantityDiscount: int.parse(quantityDiscountController.text),
                              ));

                              setState(() {
                                isLoading = false;
                              });

                              // Close the current Snackbar if open and navigate
                              if (Get.isSnackbarOpen) {
                                Get.closeCurrentSnackbar();
                              }

                              // Add navigation delay to ensure everything is set up
                              Future.delayed(Duration(milliseconds: 200), () {
                                Get.back();
                                Get.snackbar('Success', 'Product updated successfully');
                              });
                            }
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              error = e.toString();
                            });
                            print("Error: $error");
                          }
                        }
                      },
                      child:  Text('update category'.tr),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
