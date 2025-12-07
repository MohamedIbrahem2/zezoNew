import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:zezo/constants.dart';
import 'package:zezo/main.dart';
import 'package:zezo/service/order_service.dart';

import '../../service/address_service.dart';
import '../../service/cart_service.dart';
import '../addresses_pge.dart';

class CheckHome extends StatefulWidget {
  final String unique;
  final List<CartItem>? cartItems;
  const CheckHome({super.key, required this.unique, required this.cartItems});

  @override
  State<CheckHome> createState() => _CheckHomeState();
}

class _CheckHomeState extends State<CheckHome> {
  DateTime now = DateTime.now();
  DateTime finalDate = DateTime.now();

  final addressController = TextEditingController();
  final dateController = TextEditingController();
  final totalWithTax2Controller = TextEditingController();
  final clientNameController = TextEditingController();
  List<TextEditingController> phoneNumbersController = [TextEditingController()];

  UserProfile? userProfile;

  // Local list to store cart items (either from widget or from Firebase)
  List<CartItem> _cartItems = [];

  final AddressService _addressService = AddressService(
    FirebaseAuth.instance.currentUser!.uid,
  );
  Address? selectedAddress;

  @override
  void initState() {
    AuthService()
        .getUserProfile(FirebaseAuth.instance.currentUser!.uid)
        .then((value) {
      userProfile = value;
      phoneNumbersController[0].text = userProfile?.phone ?? '';
      setState(() {});
    });
    super.initState();
  }

  String formatDate(DateTime date) => date.toString().substring(0, 10);

  Future<void> _selectDate(BuildContext context) async {
    bool _isSelectableDate(DateTime date) => date.weekday != DateTime.friday;

    final nextDay = DateTime.now().add(const Duration(days: 1));
    final initial = nextDay.weekday == DateTime.friday
        ? nextDay.add(const Duration(days: 1))
        : nextDay;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: initial,
      lastDate: DateTime(2026),
      selectableDayPredicate: _isSelectableDate,
    );

    if (picked != null) {
      setState(() {
        finalDate = picked;
        dateController.text = formatDate(finalDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AdminProvider>(context, listen: false);
    const Color mint = Color(0xFF2ECC71);
    const Color darkMint = Color(0xFF27AE60);
    const Color lightBg = Color(0xFFF7F7F7);

    return StreamBuilder<List<CartItem>>(
      stream: CartService().getCartItems(FirebaseAuth.instance.currentUser!.uid.toString()),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // Use the provided cartItems if available, otherwise use Firebase cart items
          _cartItems = widget.cartItems?.isNotEmpty == true ? widget.cartItems! : snapshot.data!;

          int totalQuantity = 0;
          double totalPrice = 0;

          for (var item in _cartItems) {
            totalQuantity += item.quantity;
            totalPrice += item.price * item.quantity;
          }

          return Scaffold(
            backgroundColor: lightBg,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.black),
              title: const Text(
                'الدفع',
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w700),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cart Items (Horizontal)
                    if (_cartItems.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          height: Get.height * .16,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _cartItems.length,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              return Container(
                                width: Get.width * .92,
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                                ),
                                child: Row(
                                  children: [
                                    // Image
                                    Container(
                                      width: Get.width * .27,
                                      height: Get.height * .12,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: mint.withOpacity(0.12),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      clipBehavior: Clip.antiAlias,
                                      child: Image.network(item.image, fit: BoxFit.cover),
                                    ),
                                    const SizedBox(width: 10),
                                    // Name + total price
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: Get.width * .3,
                                            child: AutoSizeText(
                                              item.productName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${(item.quantity * item.price).toStringAsFixed(2)} SR',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                              color: mint,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Delete + qty
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            CartService().removeCartItem(item.id);
                                          },
                                          icon: Icon(Icons.delete, color: Colors.redAccent.withOpacity(.85)),
                                        ),
                                        Container(
                                          width: Get.width * .25,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  CartService().updateCartItemQuantity(
                                                    item.id,
                                                    item.quantity + 1,
                                                    item.quantity,
                                                  );
                                                },
                                                child: const Icon(Icons.add, size: 18),
                                              ),
                                              Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                              GestureDetector(
                                                onTap: () {
                                                  if (item.quantity == 0) {
                                                    CartService().removeCartItem(item.id);
                                                    return;
                                                  }
                                                  CartService().updateCartItemQuantity(
                                                    item.id,
                                                    item.quantity - 1,
                                                    item.quantity,
                                                  );
                                                },
                                                child: const Icon(Icons.remove_outlined, size: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    else
                      Container(
                        height: Get.height * .12,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Text('لا يوجد منتجات في عربة التسوق', textDirection: TextDirection.rtl),
                      ),

                    const SizedBox(height: 18),

                    // Name Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (userProfile != null)
                          Text(
                            userProfile!.name ?? '',
                            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: Colors.black87),
                          ),
                        const SizedBox(width: 8),
                        const Text(
                          'الاسم:',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800, color: Colors.black),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Deliver To
                    _sectionTitle('deliver to'.tr),

                    // Address dropdown
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: StreamBuilder<List<Address>>(
                        stream: _addressService.stream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null && snapshot.data!.isEmpty) {
                            return InkWell(
                              onTap: () => Get.to(AddressesPage(uniqueId: widget.unique)),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [mint.withOpacity(.95), darkMint],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'لا يوجد عنوان، قم بإضافة عنوان',
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return DropdownButtonFormField<Address?>(
                            validator: (value) {
                              if (selectedAddress == null || addressController.text.isEmpty) {
                                return 'اختار العنوان';
                              }
                              return null;
                            },
                            value: selectedAddress,
                            items: snapshot.data == null
                                ? []
                                : snapshot.data!
                                .map((e) => DropdownMenuItem<Address?>(
                              value: e,
                              child: Text(e.city, textDirection: TextDirection.rtl),
                            ))
                                .toList(),
                            onChanged: (value) {
                              selectedAddress = value;
                              addressController.text = selectedAddress?.id ?? '';
                            },
                            decoration: InputDecoration(
                              labelText: 'select_address'.tr,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Deliver Time
                    _sectionTitle('deliver time'.tr),

                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: TextFormField(
                        readOnly: true,
                        controller: dateController,
                        onTap: () => _selectDate(context),
                        decoration: InputDecoration(
                          labelText: 'choose time'.tr,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Phone
                    _sectionTitle('phone'.tr),
                    const SizedBox(height: 8),

                    ...phoneNumbersController.map(
                          (i) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                        ),
                        child: TextFormField(
                          controller: i,
                          decoration: InputDecoration(
                            labelText: 'phone'.tr,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: IconButton(
                        onPressed: () {
                          phoneNumbersController.add(TextEditingController());
                          setState(() {});
                        },
                        icon: Icon(Icons.add_circle, color: mint, size: 28),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Summary Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          _summaryRow(label: 'products'.tr, value: '$totalQuantity${"pieces".tr}', bold: true),
                          const Divider(height: 18, thickness: .7),

                          _summaryRow(
                            label: 'total before tax'.tr,
                            value: '${(totalPrice - (totalPrice * .15)).toStringAsFixed(2)} SR',
                          ),

                          _summaryRow(
                            label: '15%${"tax".tr}',
                            value: '${(totalPrice * .15).toStringAsFixed(2)} SR',
                          ),

                          _summaryRow(label: 'discount'.tr, value: '0 SR'),
                          _summaryRow(label: 'deliver'.tr, value: '0 SR'),

                          const Divider(height: 20, thickness: .9),

                          _summaryRow(
                            label: 'total with tax'.tr,
                            value: '${totalPrice.toStringAsFixed(2)} SR',
                            bold: true,
                            highlight: true,
                          ),

                          const SizedBox(height: 12),

                          // Admin-only Client Name
                          Visibility(
                            visible: provider.isAdmin,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 6),
                                TextField(
                                  controller: clientNameController,
                                  decoration: InputDecoration(
                                    labelText: 'clientName'.tr,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  ),
                                  keyboardType: TextInputType.text,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Get.height * .12),
                  ],
                ),
              ),
            ),

            // Bottom confirm button (logic unchanged)
            bottomSheet: BottomSheet(
              elevation: 12,
              onClosing: () {},
              builder: (context) => GestureDetector(
                onTap: () {
                  Get.defaultDialog(
                    title: 'confirm order'.tr,
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 10,
                            backgroundColor: mainColor,
                          ),
                          onPressed: () async {
                            final String client = clientNameController.text.trim();
                            final bool clientFilled = client.isNotEmpty;

                            // if (!clientFilled) {
                            //   Get.snackbar(
                            //     'error'.tr,
                            //     'typeClientName'.tr,
                            //     backgroundColor: Colors.red,
                            //     colorText: Colors.white,
                            //     duration: const Duration(seconds: 3),
                            //   );
                            //   Navigator.pop(context);
                            //   return;
                            // }
                            Navigator.pop(context);

                            Get.snackbar(
                              'please wait',
                              'تاكد من تشغيل الانترنت وانتظر لحظات  !',
                              leftBarIndicatorColor: Colors.white,
                              showProgressIndicator: true,
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 8),
                            );

                            await OrderService().placeOrder(
                              FirebaseAuth.instance.currentUser!.uid,
                              _cartItems,
                              totalPrice,
                              client,
                              selectedAddress!,
                              finalDate,
                              phoneNumbersController
                                  .map((e) => e.text)
                                  .where((element) => element.isNotEmpty)
                                  .toList(),
                            );
                          },
                          child: const Text(
                            'yes',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(elevation: 10, backgroundColor: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('no', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: Get.width,
                  height: 56,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    gradient: LinearGradient(
                      colors: [mint, darkMint],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'confirm',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6, right: 4),
      child: Text(
        title,
        textDirection: TextDirection.rtl,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.black87),
      ),
    );
  }

  Widget _summaryRow({required String label, required String value, bool bold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: highlight ? const Color(0xFF2ECC71) : Colors.black87,
            ),
          ),
          Text(
            label,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
