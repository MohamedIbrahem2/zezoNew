import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants.dart';

class TechnicalSupport extends StatelessWidget {
  const TechnicalSupport({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  backgroundColor: Colors.greenAccent.shade100,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: mainColor,
        iconTheme: const IconThemeData(color: Colors.black),
        title:  Text(
          'technical_support'.tr,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: Get.height * .02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Text(
                'contact_us'.tr,
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(
                width: 15,
              ),
              Image.asset(
                'images/smiling.png',
                width: 25,
                height: 25,
              )
            ],
          ),
          SizedBox(
            height: Get.height * .03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const CircleAvatar(
              //     backgroundImage: NetworkImage(
              //         'https://pps.whatsapp.net/v/t61.24694-24/307317711_1262426030998902_748495295193957793_n.jpg?ccb=11-4&oh=01_AdRsJ3K3jcq5Fbt0bh5Phc_5aKAozMhq491lTdw4dgTY2A&oe=644D7F0C')),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  launch('https://wa.me/+0555808297');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: Get.width * .6,
                  height: Get.height * .08,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            spreadRadius: 1, blurRadius: 3, color: Colors.grey)
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: 35,
                          height: 35,
                          child: Image.asset('images/whatsapp.png')),
                      GestureDetector(
                          onTap: () {
                            launch("tel://+0555808297");
                          },
                          child: const Icon(Icons.call)),
                       Expanded(
                         child: Text(
                          'technical_support'.tr,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                                               ),
                       ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const CircleAvatar(
              //     backgroundImage: NetworkImage(
              //         'https://pps.whatsapp.net/v/t61.24694-24/307317711_1262426030998902_748495295193957793_n.jpg?ccb=11-4&oh=01_AdRsJ3K3jcq5Fbt0bh5Phc_5aKAozMhq491lTdw4dgTY2A&oe=644D7F0C')),
              const SizedBox(
                width: 20,
              ),
              GestureDetector(
                onTap: () {
                  launch('https://wa.me/+0542788505');
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: Get.width * .6,
                  height: Get.height * .08,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            spreadRadius: 1, blurRadius: 3, color: Colors.grey)
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                          width: 35,
                          height: 35,
                          child: Image.asset('images/whatsapp.png')),
                      GestureDetector(
                          onTap: () {
                            launch("tel://+0542788505");
                          },
                          child: const Icon(Icons.call)),
                      Expanded(
                        child: Text(
                          'technical_support'.tr,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          Container(
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.all(7),
            width: Get.width * .8,
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: Get.width * .6,
                    height: Get.height * .08,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: mainColor,
                        boxShadow: const [
                          BoxShadow(
                              spreadRadius: 1,
                              blurRadius: 3,
                              color: Colors.grey)
                        ]),
                    child:  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'contact sales'.tr,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () async {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: 'tarekalmoder@miftaahalwadi.com',
              );

              await launchUrl(
                emailUri,
                mode: LaunchMode.externalApplication,
              );
            },

            child: Container(
              width: Get.width * .6,
              height: Get.height * .05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    spreadRadius: 1,
                    blurRadius: 3,
                    color: Colors.grey,
                  )
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'tarekalmoder@miftaahalwadi.com',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue, // Make it look clickable
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      ],
            ),
          )
        ],
      ),
    );
  }
}
