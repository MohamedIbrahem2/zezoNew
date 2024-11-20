import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zezo/constants.dart';
import 'package:zezo/main.dart';
import 'package:zezo/service/order_service.dart';
import 'package:zezo/view/my_page_screens/orders_management_provider.dart';

import 'oreder_history.dart';

String formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

class OrdersManagement extends StatefulWidget {
  const OrdersManagement({super.key});
  static _OrdersManagementState of(BuildContext context) =>
      context.findAncestorStateOfType<_OrdersManagementState>()!;
  @override
  State<OrdersManagement> createState() => _OrdersManagementState();
}

class _OrdersManagementState extends State<OrdersManagement> {
  @override
  void initState() {
    context.read<OrdersManagementProvider>().fetchOrders();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime date) =>
        '${date.day}/${date.month}/${date.year}';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(
          'orders Management'.tr,
          style: const TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: const StatusTaps(),
    );
  }
}

class DottedLine extends StatelessWidget {
  const DottedLine({super.key});

  @override
  Widget build(BuildContext context) {
    double dotWidth = 7;
    // get the parent width
    Widget buildDot() {
      return Container(
        width: dotWidth,
        height: 1,
        color: Colors.black,
      );
    }

    double space = 10.0;

    return LayoutBuilder(builder: (context, constraints) {
      double parentWidth = constraints.maxWidth;
      int dottesCount = parentWidth ~/ (dotWidth + space);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i in List.generate(dottesCount, (index) => buildDot()))
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                i,
                SizedBox(
                  width: space,
                )
              ],
            ),
        ],
      );
    });
  }
}

// status taps
class StatusTaps extends StatefulWidget {
  const StatusTaps({super.key});

  @override
  State<StatusTaps> createState() => _StatusTapsState();
}

class _StatusTapsState extends State<StatusTaps> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final OrdersManagement = context.watch<OrdersManagementProvider>();
    return Column(
      children: [
        SizedBox(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  for (var status in OrdersManagement.statuses)
                    InkWell(
                      onTap: () {
                        OrdersManagement.status = (status);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: context
                                        .watch<OrdersManagementProvider>()
                                        .status ==
                                    status
                                ? mainColor
                                : Colors.grey,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  color: Colors.black)
                            ]),
                        child: Text(status),
                      ),
                    ),
                ],
              ),
            )),
        Expanded(
          child: OrdersManagement.isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : OrdersManagement.orders
                      .where((element) => element.address != null)
                      .isEmpty
                  ? Center(
                      child: Text('No Orders Yet'.tr),
                    )
                  : ListView.separated(
                      separatorBuilder: (context, index) {
                        return Container(
                          height: 20,
                          color: mainColor,
                        );
                      },
                      itemCount: OrdersManagement.orders
                          .where((element) => element.address != null)
                          .length,
                      itemBuilder: (context, index) {
                        final order = OrdersManagement.orders
                            .where((element) => element.address != null)
                            .toList()[index];
                        // UserProfile? userProfile;
                        // if (userSnapHot.data != null) {
                        //   userProfile = userSnapHot.data!
                        //       .where((element) => element.id == order.userId)
                        //       .first;
                        // }

                        return OrderItem(order: order);
                      },
                    ),
        ),
      ],
    );
  }
}

class OrderItem extends StatefulWidget {
  const OrderItem({super.key, required this.order});
  final Order order;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  late Order order;
  @override
  void initState() {
    order = widget.order;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int totalQuantity = 0;

    double totalPrice = 0;
    double discount = 0;

    // Calculate total quantity and price
    for (var item in order.items) {
      totalQuantity += item.quantity;
      totalPrice += item.price * item.quantity;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ...widget.order.items
              .where((element) => element.image.isNotEmpty)
              .map((cartItem) => ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: cartItem.image,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                    title: Text(cartItem.productName.toString()),
                    subtitle: Text('${cartItem.price} SAR'),
                    trailing: CircleAvatar(
                        radius: 15, child: Text(cartItem.quantity.toString())),
                  )),
          if (order.userProfile != null)
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: mainColor,
                  boxShadow: const [
                    BoxShadow(
                        blurRadius: 2, spreadRadius: 1, color: Colors.black)
                  ]),
              child: Column(
                children: [
                  Row(
                    children: [
                       Text(
                        'customer name'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(order.userProfile!.name,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w400)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                       Text(
                        'customer email'.tr,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Text(order.userProfile!.email ?? '',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w400)),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    children: [
                       Text(
                        'customer phone'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(order.userProfile!.phone ?? '',
                          style: const TextStyle(
                              fontSize: 14 , fontWeight: FontWeight.w400)),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Text(
                        'other phone'.tr,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      order.phones != null
                          ? order.phones!.isEmpty
                              ? const Text('Not Provided')
                              : Column(
                                  children: order.phones!
                                      .map((e) => Text(e))
                                      .toList(),
                                )
                          : const Text('Not Provided'),
                    ],
                  ),

                ],
              ),
            ),

          const SizedBox(
            height: 20,
          ),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('address'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  GestureDetector(
                    onTap: (){
                      launch('https://wa.me/${order.userProfile!.phone}');
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 20),
                        width: 30,height: 30,
                        child: Image.asset('images/whatsapp.png')),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 15),
                    alignment: Alignment.topRight,
                    child: IconButton(
                        onPressed: () {
                          launchUrl(Uri.parse(
                              'tel:${order.userProfile!.phone}'));
                        },
                        icon: const Icon(
                          Icons.phone,
                          color: Colors.blue,
                          size: 30,
                        )),
                  ),
                ],
              ),

            ],
          ),

          AddressItem(
            address: widget.order.address!,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Text('deliver date'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: mainColor,
                    boxShadow: const [
                      BoxShadow(
                          blurRadius: 2, spreadRadius: 1, color: Colors.black)
                    ]),
                child: Text(formatDate(widget.order.deliveryDate),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400)),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
               Text('status'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: mainColor,
                    boxShadow: const [
                      BoxShadow(
                          blurRadius: 2, spreadRadius: 1, color: Colors.black)
                    ]),
                child: Text(widget.order.status!,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400)),
              ),
            ],
          ),

          // user photo
          // Row(
          //   children: [
          //     CircleAvatar(
          //       radius: 20,
          //       child:
          //           (userProfile == null || userProfile.photo != null)
          //               ? Text(userProfile!.name.substring(0, 1))
          //               : null,
          //       backgroundImage: userProfile.photo != null
          //           ? NetworkImage(userProfile.photo!)
          //           : null,
          //     ),

          //     // user name
          //     Text(userProfile.name),
          //   ],
          // ),
          ListTile(
            title:  Text('total quantity'.tr),
            trailing: Text(totalQuantity.toString()),
          ),
          // doted line
          const DottedLine(),

          ListTile(
            title: const Text('Total Price'),
            trailing: Text(totalPrice.toString()),
          ),
          ListTile(
            title:  Text('discount'.tr),
            trailing: Text(discount.toString()),
          ),
          ListTile(
            title:  Text('total'.tr),
            trailing: Text((totalPrice - discount).toStringAsFixed(2)),
          ),
          ListTile(
            title:  Text('order date'.tr),
            trailing: Text(formatDate(widget.order.orderDate)),
          ),
          if (widget.order.invoiceNumber != null)
            ListTile(
              title:  Text('invoice number'.tr),
              trailing: Text(widget.order.invoiceNumber!),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (context.watch<OrdersManagementProvider>().status !=
                  'delivered')
                ElevatedButton(
                    onPressed: () async {
                      context
                          .read<OrdersManagementProvider>()
                          .updateOrderStatusAction(order.id, order.userId);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                    child: Text(context
                        .watch<OrdersManagementProvider>()
                        .getActionText(order.status!),style: TextStyle(color: Colors.white),)),
              if (!context.watch<AdminProvider>().isAdmin &&
                  order.status == 'pending')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: mainColor),
                    onPressed: () async {
                      context
                          .read<OrdersManagementProvider>()
                          .updateOrderStatusAction(order.id, order.userId);
                    },
                    child: Text(context
                        .watch<OrdersManagementProvider>()
                        .getActionText(order.status!),style: TextStyle(color: Colors.white))),
              if (order.status == 'pending' || order.status == 'processing')
                const SizedBox(
                  width: 10,
                ),
              if (order.status == 'pending' || order.status == 'processing')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                  ),
                    onPressed: () async {
                      context
                          .read<OrdersManagementProvider>()
                          .cancelOrder(order.id);
                    },
                    child:  Text('cancel'.tr,style: TextStyle(color: Colors.black),))
            ],
          ),
        ],
      ),
    );
  }
}
