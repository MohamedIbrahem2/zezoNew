import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart' hide TextDirection;
class DepositsInfo extends StatefulWidget {
  final String clientId;
  final String name;
  const DepositsInfo({super.key, required this.clientId, required this.name});

  @override
  State<DepositsInfo> createState() => _DepositsInfoState();
}

class _DepositsInfoState extends State<DepositsInfo> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text("معاملات العميل: ${widget.name}", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(child:
          Column(
            children: [
              SizedBox(height: Get.height * 0.04),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('depsitsClients')
                      .doc(widget.clientId)
                      .collection("transactions").snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No data available'));
                    }
                    final numbers = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: numbers.length,
                      itemBuilder: (context, index) {
                        final number = numbers[index];
                        final Timestamp timestamp = number['date'];
                        final DateTime dateTime = timestamp.toDate(); // Convert Timestamp to DateTime
                        final formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(dateTime);
                        return Card(
                          margin: const EdgeInsets.all(10),
                          elevation: 5,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(10),
                            title: Text('  المعاملة:  ${number['number']} ريال',textDirection: TextDirection.rtl,),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(' النوع:  ${number['type']}',textDirection: TextDirection.rtl,),
                                Text(' ملحوظه:  ${number['description']}',textDirection: TextDirection.rtl,),
                                Text(' التاريخ:  $formattedDate',textDirection: TextDirection.rtl,),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )
      ),
    );
  }
}
