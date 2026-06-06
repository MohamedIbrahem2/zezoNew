import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;

class RepresentativeScreen extends StatefulWidget {
  final String name;
  const RepresentativeScreen({super.key, required this.name});

  @override
  _RepresentativeScreenState createState() => _RepresentativeScreenState();
}

class _RepresentativeScreenState extends State<RepresentativeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new number to Firebase
  Future<void> _addNumberToFirestore(String number, String description) async {
    try {
      await _firestore.collection('representative').add({
        'name' : widget.name,
        'number': number,
        'description': description,
        'date': Timestamp.now(), // Store current date
      });
    } catch (e) {
      print('Error adding number: $e');
    }
  }

  // Show dialog to input number and description
  void _showAddNumberDialog() {
    final TextEditingController numberController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اضافه رقم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberController,
              decoration: const InputDecoration(labelText: 'رقم'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'ملحوظه'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('الغاء'),
          ),
          TextButton(
            onPressed: () {
              final number = numberController.text.trim();
              final description = descriptionController.text.trim();

              if (number.isNotEmpty) {
                _addNumberToFirestore(number, description ?? "لا يوجد");
                Navigator.pop(context);
              }
            },
            child: const Text('اضافة'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'معلومات ${widget.name}',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('representative').where('name',isEqualTo: widget.name).snapshots(),
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
                    final formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(dateTime); // Format the date
                    return Card(
                      margin: const EdgeInsets.all(10),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        title: Text('  المعاملة:  ${number['number']} ريال',textDirection: TextDirection.rtl,),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                minimumSize: Size(200, 50),
              ),
              onPressed: _showAddNumberDialog,
              child: const Text('اضافة معامله',style: TextStyle(color: Colors.white),),
            ),
          ),
        ],
      ),
    );
  }
}
