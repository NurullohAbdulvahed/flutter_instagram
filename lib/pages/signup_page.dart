import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/model/user_model.dart';
import 'package:flutter_instagram/pages/home_page.dart';
import 'package:flutter_instagram/services/auth_service.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/services/prefs_service.dart';
import 'package:flutter_instagram/services/utils.dart';

import 'signin_page.dart';

class SignUpPage extends StatefulWidget {
  static String id = "SignUpPage";
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void _callSignInPage(){
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  void doSignUp(){
    String email = emailController.text.toString().trim();
    String name = fullNameController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String confirmPassword = confirmPasswordController.text.toString().trim();

    if(email.isEmpty || name.isEmpty ||password.isEmpty ||confirmPassword.isEmpty) return;
    if(!(RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email))) {
       Utils.fireToast("This email is not valid.Please check your email");
      return;
    }
    if(confirmPassword != password) {
      Utils.fireToast("Password and confirm does not match");
      return;
    }
    if(!(RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(password))){
      Utils.fireToast("This password is not valid.Please check your password");
      return;
    }

    setState(() {
      isLoading = true;
    });
    Users users = Users(fullName: name, email: email, password: password);
    AuthService.signUpUser(context, name, email, password,).then((value) => {
      _getFirebaseUser(users,value),
    });

  }
  void _getFirebaseUser(Users users,Map<String,User?> map)async{
    User? firebaseUser;

    if(!(map.containsKey("SUCCESS"))){
      if(map.containsKey("ERROR_EMAIL_ALREADY_IN_USE")) {
        Utils.fireToast("Email already in use");
      }
      if(map.containsKey("ERROR")) {
        Utils.fireToast("Try again later");
      }
      return;
    }
    firebaseUser = map["SUCCESS"];
    if(firebaseUser == null) return;

    await Prefs.saveUserId(firebaseUser.uid);
    DataService.storeUser(users).then((value) => {
      Navigator.pushReplacementNamed(context, HomePage.id),
    });


  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(20),
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
                children: [
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Instagram",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Billabong'),),
                          const SizedBox(height: 20,),
                          ///FullName
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              controller: fullNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  hintText: "Fullname",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 17.0,color: Colors.white54)
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          ///EMAIL
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              controller: emailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                  hintText: "Email",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 17.0,color: Colors.white54)
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          ///Password
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              controller: passwordController,
                              style:const  TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: const InputDecoration(
                                  hintText: "Password",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 17.0,color: Colors.white54)
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),
                          ///ConfirmPassword
                          Container(
                            height: 50,
                            padding: const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              controller: confirmPasswordController,
                              style: const TextStyle(color: Colors.white),
                              obscureText: true,
                              decoration: const InputDecoration(
                                  hintText: "Confirm Password",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 17.0,color: Colors.white54)
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),

                          ///SIGNIn
                          GestureDetector(
                            onTap: doSignUp,
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white54.withOpacity(0.2),width: 2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Center(
                                child: Text("Sign Up",style: TextStyle(color: Colors.white,fontSize: 17),),
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account?",style: TextStyle(color: Colors.white,fontSize: 16),),
                      const SizedBox(width: 10,),
                      GestureDetector(
                        onTap: _callSignInPage,
                        child: const Text("Sign In",style: TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                  const SizedBox(height: 20,)
                ],
              ),
            ),
            isLoading ? const Center(
              child: CircularProgressIndicator(),
            ) : const SizedBox.shrink()
          ]

        ),
      ),
    );
  }
}
