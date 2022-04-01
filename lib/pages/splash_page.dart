import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/pages/home_page.dart';

import '../services/prefs_service.dart';


class SplashPage extends StatefulWidget {
  static String id = "SplashPage";
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  _initTimer(){
    Timer(const Duration(seconds: 2), (){
      _callHomePage();
    });
  }

  void _callHomePage(){
    Navigator.pushReplacementNamed(context, HomePage.id);
  }
  initNotification() async {
    await _firebaseMessaging
        .requestPermission(sound: true, badge: true, alert: true);
    _firebaseMessaging.getToken().then((String? token) {
      assert(token != null);
      print("Token $token shu yerda tugaydi");
      Prefs.saveFCM(token!);
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initTimer();
    initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(193, 53, 132, 1),
              Color.fromRGBO(131, 58, 180, 1),
            ]
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
             Expanded(
                 child: Center(
                   child: Text("Instagram",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Billabong'),),
                 )
             ),


            Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text("All rights reserved",style: TextStyle(color: Colors.white,fontSize: 16),),
            )
          ],
        ),
      ),
    );
  }
}
