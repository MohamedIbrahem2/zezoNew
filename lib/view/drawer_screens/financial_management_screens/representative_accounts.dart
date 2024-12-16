import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zezo/view/drawer_screens/financial_management_screens/representative_screen.dart';

class RepresentativeAccounts extends StatefulWidget {
  const RepresentativeAccounts({super.key});

  @override
  State<RepresentativeAccounts> createState() => _RepresentativeAccountsState();
}

class _RepresentativeAccountsState extends State<RepresentativeAccounts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: Text("حسابات المناديب", style: TextStyle(color: Colors.white)),
      ), // Remove the app bar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                // Navigate to the second screen when the first button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RepresentativeScreen(name: "ضياء",)),
                );
              },
              child: const Text(
                'ضياء',
                style: TextStyle(fontSize: 18,color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                // Navigate to the second screen when the second button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RepresentativeScreen(name: 'محمد',)),
                );
              },
              child: const Text(
                'محمد',
                style: TextStyle(fontSize: 18,color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                minimumSize: Size(200, 50),
              ),
              onPressed: () {
                // Navigate to the second screen when the third button is pressed
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RepresentativeScreen(name: 'احمد',)),
                );
              },
              child: const Text(
                'احمد',
                style: TextStyle(fontSize: 18,color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
