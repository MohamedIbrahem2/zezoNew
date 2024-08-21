import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:developer' as devtools show log;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:zezo/notifications_db.dart';

class FcmProvider {
  static final FcmProvider _instance = FcmProvider._internal();

  factory FcmProvider() => _instance;

  FcmProvider._internal();

  final _firestore = FirebaseFirestore.instance;

  final String serverKey =
      'AAAAqPzP7mI:APA91bFp0h8aIwpfIOEqYcA49RBidh8uDg_ns7hGy9ketdNmQZsysXSeak7mbjCLhuVF9Pv0YBfLl-tXwHOq9nuYoRPc8CIuzu38sEYt9XGFsYYdMBT2iKB74LbBgAxfs8SOYBODNNKs';

  Future<bool> sendPushMessage({
    required String recipientToken,
    required String title,
    required String body,
    required auth.AutoRefreshingAuthClient client,
  }) async {
    final notificationData = {
      'message': {
        'token': recipientToken,
        'notification': {'title': title, 'body': body}
      },
    };

    const String senderId = '970646820738'; // Replace with your project ID
    final response = await client.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/$senderId/messages:send'),
      headers: {
        'content-type': 'application/json',
      },
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 200) {
      return true; // Success!
    }

    devtools.log(
        'Notification Sending Error Response status: ${response.statusCode}');
    devtools.log('Notification Response body: ${response.body}');
    return false;
  }

  Future<void> sendMessage(String title, String body) async {
    // Step 1: Fetch the list of tokens from Firestore
    List<String> tokens = [];

    await FirebaseFirestore.instance.collection('users').get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        if (doc.data().containsKey('fcm')) {
          String? token = doc['fcm'];
          if (token != null) {
            tokens.add(token);
          }
        } else {
          print('Document ${doc.id} does not contain "fcm"');
        }
      }
    });

    if (tokens.isEmpty) {
      print('No valid tokens found.');
      return;
    }

    // Step 2: Obtain OAuth 2.0 credentials and client
    final jsonCredentials = await rootBundle.loadString('data/zezo-6778a-674cf09cf39d.json');
    final creds = auth.ServiceAccountCredentials.fromJson(jsonCredentials);

    final client = await auth.clientViaServiceAccount(
      creds,
      ['https://www.googleapis.com/auth/cloud-platform'],
    );

    // Step 3: Send the message to each token
    for (String token in tokens) {
      bool success = await sendPushMessage(
        recipientToken: token,
        title: title,
        body: body,
        client: client,
      );

      if (success) {
        print('Message sent successfully to $token');
      } else {
        print('Failed to send message to $token');
      }
    }

    client.close(); // Close the OAuth client
  }
  Future<void> sendMessage1(List<String> tokens, String message,String title,Function(bool) setLoading) async {
    final body = {
      "registration_ids": tokens,
      "notification": {
        "title": title,
        "body": message,
      },
    };

    try {
      setLoading(true);

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Get.snackbar('تم الأرسال', 'بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green);
      } else {
        Get.snackbar('فشل', 'حدث خطأ ما',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red);
      }
    } catch (e) {
      print('An error occurred while sending the message: $e');
    } finally {
      setLoading(false);
    }
  }
  Future<void> sendHttppNotification(
    String token,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=$serverKey'
    };
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          body: json.encode(
            {
              'notification': {
                'title': title,
                'body': body,
                'sound': 'default',
                'badge': '1',
              },
              'priority': 'high',
              'data': data,
              'to': token,
            },
          ),
          headers: headers);
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // send notification to topic

  Future<void> sendToTopic(
    String tpic,
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: json.encode(
          {
            'notification': {
              'title': title,
              'body': body,
              'sound': 'default',
              'badge': '1',
            },
            'priority': 'high',
            'data': data,
            'to': '/topics/$tpic',
          },
        ),
      );
    } catch (e) {
      print(e);
    }
  }

// subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } catch (e) {
      print(e);
    }
  }

  // unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (e) {
      print(e);
    }
  }

  String? token;

  Future<void> initialize() async {
    // initialize firebase messaging

    await FirebaseMessaging.instance.requestPermission();

    final _token = await FirebaseMessaging.instance.getToken();

    if (_token != null) {
      token = _token;

      saveTokenToFirestore(FirebaseAuth.instance.currentUser!.uid);
    }
  
    FirebaseMessaging.instance.onTokenRefresh.listen((event) async {
      token = event;
      await saveTokenToFirestore(FirebaseAuth.instance.currentUser!.uid);
    });
    listenToNotification();
  }

  Future<void> saveTokenToFirestore(String userId) async {
    // save token to firestore

    try {
      await _firestore.collection('users').doc(userId).update({'fcm': token});
    } catch (e) {
      print('Error adding token: $e');
    }
  }

  // get token
  Future<String?> getUserToken(
    String userId,
  ) async {
    try {
      final _token = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .then((value) => value.data()!['fcm']);
      return _token;
    } catch (e) {
      print('Error getting token: $e');
    }
    return null;
  }

  // send notification
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      final _token = await getUserToken(userId);
      print('token is');
      print(_token);
      if (_token != null) {
        await sendHttppNotification(
          _token,
          title,
          body,
          data ??
              {
                'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                'id': '1',
                'status': 'done',
              },
        );
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

// listen to notification
  Future<void> listenToNotification() async {
    try {
      await FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage? message) {
        if (message != null) {
          AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: message.notification!.title,
              body: message.notification!.body,
            ),
          );
        }
      });
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: message.notification!.title,
            body: message.notification!.body,
          ),
        );
        print('''
********** onMessage **********
${message.notification!.title}
${message.notification!.body}
${message.data}
********** onMessage **********




''');
        if (message.data['orderId'] != null) {
          NotificationsDB.instance.addNotification(
            notification: OrderNotification.fromRemoteMessage(message),
          );
        }
      });
    } catch (e) {
      print('Error listening to notification: $e');
    }
  }
}
