import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
class WhatsAppSenderScreen extends StatefulWidget {
  @override
  _WhatsAppSenderScreenState createState() => _WhatsAppSenderScreenState();
}

class _WhatsAppSenderScreenState extends State<WhatsAppSenderScreen> {
  TextEditingController messageController = TextEditingController();
  List<String> phoneNumbers = [ "+201021097989" ,"+201149659764" , "+201021097989"];

  /// Fetch phone numbers from Firestore
  Future<void> fetchPhoneNumbers() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();

      List<String> numbers = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>) // Cast to Map
          .where((data) => data.containsKey('phone')) // Ensure 'phone' field exists
          .map((data) => data['phone'].toString()) // Convert to String
          .toList();

      setState(() {
        // phoneNumbers = numbers;
      });

      print("Fetched Phone Numbers: $phoneNumbers");
    } catch (e) {
      print("Error fetching phone numbers: $e");
    }
  }

  /// Send WhatsApp messages one by one
  Future<void> sendMessages() async {
    if (phoneNumbers.isEmpty) {
      print("No phone numbers available.");
      return;
    }

    String message = Uri.encodeComponent(messageController.text);

    for (int i = 0; i < phoneNumbers.length; i++) {
      String number = phoneNumbers[i];
      Uri url = Uri.parse("https://wa.me/$number?text=$message");

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication); // Opens in WhatsApp
      } else {
        print("Could not launch $url");
      }

      await Future.delayed(Duration(seconds: 3)); // Delay between messages
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPhoneNumbers(); // Fetch phone numbers on app start
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WhatsApp Bulk Sender")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: messageController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Enter Message",
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendMessages,
              child: Text("Send to WhatsApp"),
            ),
          ],
        ),
      ),
    );
  }
}