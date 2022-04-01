import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/pages/my_feed_page.dart';
import 'package:flutter_instagram/pages/my_likes_page.dart';
import 'package:flutter_instagram/pages/my_profile_page.dart';
import 'package:flutter_instagram/pages/my_search_page.dart';
import 'package:flutter_instagram/pages/my_upload_page.dart';

import '../services/utils.dart';


class HomePage extends StatefulWidget {
  static String id = "HomePage";
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController _pageController = PageController();
  int _currentTap = 0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initNotification();
    _pageController = PageController();

  }
  _initNotification(){
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Utils.showLocalNotification(message, context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Utils.showLocalNotification(message, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          MyFeedPage(pageController: _pageController,),
          const MySearchPage(),
          const MyUploadPage(),
          const LikesPage(),
          const MyProfilePage(),
        ],
        onPageChanged: (int index){
          setState(() {
            _currentTap = index;
          });
        },
      ),
      bottomNavigationBar: CupertinoTabBar(
        onTap: (int index){
          setState(() {
            _currentTap = index;
            _pageController.animateToPage(index, duration: const Duration(microseconds: 200), curve: Curves.easeIn);

          });
        },
        currentIndex: _currentTap,
        activeColor: const Color.fromRGBO(131, 58, 180, 1),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home,size: 25,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search,size: 25,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box,size: 25,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite,size: 25,),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,size: 25,),
          ),
        ],
      ),
    );
  }
}
