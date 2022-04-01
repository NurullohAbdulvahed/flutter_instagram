import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/pages/signin_page.dart';

import 'prefs_service.dart';

class AuthService{
  static final _auth = FirebaseAuth.instance;

  static Future<Map<String, User?>> signInUser(BuildContext context, String email, String password) async {
    Map<String,User?> map = {};
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (kDebugMode) {
        print(user.toString());
      }
      map.addAll({"SUCCESS" : user});
    } catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      map.addAll({"ERROR": null});
    }
    return map;
  }

  static Future<Map<String,User?>> signUpUser(BuildContext context, String name, String email, String password) async {
    Map<String,User?> map = {};
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = authResult.user;
      map.addAll({"SUCCESS": user!});
      return map;
    } catch (error) {
      switch(error){
        case "ERROR_EMAIL_ALREADY_IN_USE":
          map.addAll({"ERROR_EMAIL_ALREADY_IN_USE" : null});
          break;
        default :
          map.addAll({"ERROR":null});
      }
    }
    return map;
  }
  static void signOutUser(BuildContext context) {
    _auth.signOut();
    Prefs.removeUserId().then((value) {
      Navigator.pushReplacementNamed(context, SignInPage.id);
    }
    );
  }

}