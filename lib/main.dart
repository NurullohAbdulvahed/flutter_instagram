import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_instagram/pages/home_page.dart';
import 'package:flutter_instagram/pages/signin_page.dart';
import 'package:flutter_instagram/pages/signup_page.dart';
import 'package:flutter_instagram/pages/splash_page.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'services/prefs_service.dart';


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WidgetsFlutterBinding.ensureInitialized();
  // notification
  var initAndroidSetting = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initIosSetting = const IOSInitializationSettings();
  var initSetting = InitializationSettings(android: initAndroidSetting, iOS: initIosSetting);
  await FlutterLocalNotificationsPlugin().initialize(initSetting);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
  // const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //   'high_importance_channel', // id
  //   'High Importance Notifications', // title
  //   description: 'This channel is used for important notifications.', // description
  //   importance: Importance.max,
  // );
  // var initAndroidSetting =
  // const AndroidInitializationSettings("@mipmap/ic_launcher");
  // var initIosSetting = const IOSInitializationSettings();
  // var initSetting =
  // InitializationSettings(android: initAndroidSetting, iOS: initIosSetting);
  // await FlutterLocalNotificationsPlugin().initialize(initSetting);
  // await FlutterLocalNotificationsPlugin()
  //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);
  // SystemChrome.setPreferredOrientations(
  //     [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp])
  //     .then((value) => runApp(const MyApp()));


}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);


  Widget _startPage(){
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context,snapshot){
        if(snapshot.hasData){
          Prefs.saveUserId(snapshot.data!.uid);
          return const SplashPage();
        }
        else{
          Prefs.removeUserId();
          return const SignInPage();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:_startPage(),
      routes: {
        SignUpPage.id : (context)=> const SignUpPage(),
        SignInPage.id : (context)=> const SignInPage(),
        SplashPage.id : (context)=> const SplashPage(),
        HomePage.id : (context)=> const HomePage(),
      },
    );
  }
}


