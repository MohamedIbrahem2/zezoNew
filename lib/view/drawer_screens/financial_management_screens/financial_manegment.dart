import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_common/get_reset.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:zezo/view/drawer_screens/financial_management_screens/representative_accounts.dart';

import 'deposits_accounts.dart';
class FinancialManegment extends StatefulWidget {
  const FinancialManegment({super.key});

  @override
  State<FinancialManegment> createState() => _FinancialManegmentState();
}

class _FinancialManegmentState extends State<FinancialManegment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
          Column(
            children: [
              SizedBox(
                height: Get.height * 0.03,
              ),
              Center(child: Text("مرحبا بك في شاشه الحسابات",
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 25,color: Colors.blue,fontWeight: FontWeight.bold),)),
              SizedBox(
                height: Get.height * 0.17,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: Get.width * 0.5,
                  height: Get.height * 0.12,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>const RepresentativeAccounts()));
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      minimumSize: Size(double.infinity, 0),
                    ),
                    child: Text(
                      'حسابات المناديب',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: Get.height * 0.17,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: Get.width * 0.5,
                  height: Get.height * 0.12,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>DepositsAccounts()));
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 8,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      minimumSize: Size(double.infinity, 0),
                    ),
                    child: Text(
                      'حسابات عملاء الأجل',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}
