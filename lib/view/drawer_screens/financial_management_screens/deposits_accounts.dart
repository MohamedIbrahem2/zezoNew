import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zezo/view/drawer_screens/financial_management_screens/deposits_info.dart';

import '../../../constants.dart';
class DepositsAccounts extends StatefulWidget {
  const DepositsAccounts({super.key});

  @override
  State<DepositsAccounts> createState() => _DepositsAccountsState();
}

class _DepositsAccountsState extends State<DepositsAccounts> {
  final TextEditingController searchValue = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> allNumbers = [];
  void _showAddNumberDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController costController = TextEditingController();

    Future<void> _addNumberToFirestore(String name, String cost) async {
      try {
        await _firestore.collection('depsitsClients').add({
          'name': name,
          'cost': int.parse(cost),
          'date': Timestamp.now(), // Store current date
        });
      } catch (e) {
        print('Error adding number: $e');
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اضافه عميل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'اسم العميل'),
              keyboardType: TextInputType.text,
            ),
            TextField(
              keyboardType: TextInputType.number,
              controller: costController,
              decoration: const InputDecoration(labelText: 'الرصيد'),
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
              final name = nameController.text.trim();
              final cost = costController.text.trim();

              if (name.isNotEmpty) {
                _addNumberToFirestore(name, cost ?? "لا يوجد");
                Navigator.pop(context);
              }
            },
            child: const Text('اضافة'),
          ),
        ],
      ),
    );
  }
  void _showMixedDialog(String action, String clientId, int currentCost){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختيار الطريقه'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showDialogAndUpdateCostPLus(action, clientId, currentCost);
            },
            child: const Text('اضافة'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
             _showDialogAndUpdateCostMines(action, clientId, currentCost);
            },
            child: const Text('خصم'),
          ),
        ],
      ),
    );
  }
  void _showDialogAndUpdateCostMines(String action, String clientId, int currentCost) async{
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String? selectedRepresentative;

    // Fetch representative names from Firebase
    List<String> representativeNames = [];

    try {
      // Assuming you're using Firestore to fetch representative names
      final snapshot = await FirebaseFirestore.instance
          .collection('representativeName') // Your collection
          .get();

      // Populate the list of names
      representativeNames = snapshot.docs
          .map((doc) => doc['name'] as String) // Assuming 'name' is the field holding the representative name
          .toList();
    } catch (e) {
      print("Error fetching representative names: $e");
      // You can handle errors here if needed
    }
    // Show the dialog to enter the number
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('$action - إدخال المبلغ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'ملحوظه'),
                ),
                // Dropdown to select representative name
                if (representativeNames.isNotEmpty)
                  DropdownButton<String>(
                    value: selectedRepresentative,
                    hint:  Text("اختار اسم المندوب"),
                    onChanged: (String? newValue) {
                      setState(() {

                        selectedRepresentative = newValue;
                        print(selectedRepresentative);
                      });
                    },
                    items: representativeNames.map((String representative) {
                      return DropdownMenuItem<String>(
                        value: representative,
                        child: Text(representative),
                      );
                    }).toList(),
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
                  final amount = int.tryParse(amountController.text.trim());
                  if (amount != null && amount > 0) {
                    _updateCostInFirestore(clientId, currentCost - amount,
                        descriptionController.text,action,amount,selectedRepresentative!,);
                    Navigator.pop(context);
                  } else {
                    // Show an error message if the amount is invalid
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('يرجى إدخال مبلغ صالح')),
                    );
                  }
                },
                child: const Text('اضافة'),
              ),
            ],
          );
        }
      ),
    );
  }
  void _showDialogAndUpdateCostPLus(String action, String clientId, int currentCost) async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String? selectedRepresentative;

    // Fetch representative names from Firebase
    List<String> representativeNames = [];

    try {
      // Assuming you're using Firestore to fetch representative names
      final snapshot = await FirebaseFirestore.instance
          .collection('representativeName') // Your collection
          .get();

      // Populate the list of names
      representativeNames = snapshot.docs
          .map((doc) => doc['name'] as String) // Assuming 'name' is the field holding the representative name
          .toList();
    } catch (e) {
      print("Error fetching representative names: $e");
      // You can handle errors here if needed
    }

    // Show the dialog
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('$action - إدخال المبلغ'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'ملحوظه'),
                ),
                // Dropdown to select representative name
                if (representativeNames.isNotEmpty)
                  DropdownButton<String>(
                    value: selectedRepresentative,
                    hint: const Text('اختار اسم المندوب'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedRepresentative = newValue;
                      });
                    },
                    items: representativeNames.map((String representative) {
                      return DropdownMenuItem<String>(
                        value: representative,
                        child: Text(representative),
                      );
                    }).toList(),
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
                  final amount = int.tryParse(amountController.text.trim());
                  if (amount != null && amount > 0 && selectedRepresentative != null) {
                    _updateCostInFirestore(
                      clientId,
                      currentCost + amount,
                      descriptionController.text,
                      action,
                      amount,
                      selectedRepresentative!,
                    );
                    Navigator.pop(context);
                  } else {
                    // Show an error message if the amount is invalid or no representative is selected
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('يرجى إدخال مبلغ صالح واختيار المندوب')),
                    );
                  }
                },
                child: const Text('اضافة'),
              ),
            ],
          );
        }
      ),
    );
  }


  void _updateCostInFirestore(String clientId, int newCost,String description,String type,int currentCost,String representativeName) async {
    try {
      await _firestore.collection('depsitsClients').doc(clientId).update({
        'cost': newCost,
      });
    } catch (e) {
      print('Error updating cost: $e');
    }
    try {
      await _firestore.collection('depsitsClients').doc(clientId).collection('transactions').add({
        'representativeName' : representativeName,
        'type' : type,
        'number': currentCost,
        'description': description,
        'date': Timestamp.now(), // Store current date
      });
    } catch (e) {
      print('Error adding number: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text("حسابات عملاء الأجل", style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: Get.height * 0.04),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: searchValue,
                  onChanged: (value) {
                    setState(() {
                      if (value.isEmpty) {
                        searchValue.text = "";
                      } else {
                        searchValue.text = value;
                      }
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "بحث عن عميل",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search_rounded, color: Colors.black, size: 25),
                    contentPadding: const EdgeInsets.symmetric(vertical: 1),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2, color: mainColor),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 3, color: mainColor),
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: Get.height * 0.04),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('depsitsClients').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }
                  final numbers = snapshot.data!.docs;
                  allNumbers = numbers; // Store all numbers for search filtering
                  List<QueryDocumentSnapshot> filteredNumbers = numbers.where((element) {
                    var name = element['name'].toString().toLowerCase();
                    return name.contains(searchValue.text.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredNumbers.length,
                    itemBuilder: (context, index) {
                      final number = filteredNumbers[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Container(
                            width: 350,
                            height: Get.height * 0.33,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>DepositsInfo(clientId: number.id,
                                            name: number['name'],)));
                                        },
                                        icon: Icon(Icons.info_outline_rounded, color: Colors.red),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'اسم العميل:  ${number['name']}',
                                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      '${number['cost']}  : الرصيد',
                                      style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _showDialogAndUpdateCostMines('سداد', number.id, number['cost']);
                                          },
                                          child: Text('سداد', style: TextStyle(fontSize: 18, color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _showDialogAndUpdateCostPLus('فاتورة', number.id, number['cost']);
                                          },
                                          child: Text('فاتورة', style: TextStyle(fontSize: 18, color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            _showMixedDialog('تسوية', number.id, number['cost']);
                                          },
                                          child: Text('تسوية', style: TextStyle(fontSize: 18, color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            _showDialogAndUpdateCostMines('مرتجع', number.id, number['cost']);
                                          },
                                          child: Text('مرتجع', style: TextStyle(fontSize: 18, color: Colors.white)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                ),
                onPressed: _showAddNumberDialog,
                child: const Text(' اضافة عميل جديد +', style: TextStyle(fontSize: 18,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
