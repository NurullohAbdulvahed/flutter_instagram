import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/pages/home_page.dart';
import 'package:flutter_instagram/services/auth_service.dart';
import 'package:flutter_instagram/services/utils.dart';
import '../services/prefs_service.dart';
import 'signup_page.dart';

class SignInPage extends StatefulWidget {
  static String id = "SignInPage";
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  var emailController = TextEditingController();
  bool isLoading = true;
  var passwordController = TextEditingController();

  void _callSignUpPage(){
    Navigator.pushReplacementNamed(context, SignUpPage.id);
  }

  void doLogin(){
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    if(email.isEmpty || password.isEmpty) return ;
    setState(() {
      isLoading = true;
    });
    AuthService.signInUser(context, email, password).then((value) => {
      _getFirebaseUser(value),
    });


  }
  void _getFirebaseUser(Map<String,User?> map)async{
    setState(() {
      isLoading = false;
    });
    User? user;
    if(!(map.containsKey("SUCCESS"))) {
      if(map.containsKey("ERROR")){
        Utils.fireToast("Check your email or password");
        return;
      }
    }
    user = map["SUCCESS"];
    if(user==null) return;

    await Prefs.saveUserId(user.uid);
    Navigator.pushReplacementNamed(context, HomePage.id);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
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
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Instagram",style: TextStyle(color: Colors.white,fontSize: 45,fontFamily: 'Billabong'),),
                          const SizedBox(height: 20,),

                          ///EMAIL
                          Container(
                            height: 50,
                            padding:const EdgeInsets.only(left: 10,right: 10),
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
                            padding:const EdgeInsets.only(left: 10,right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: TextField(
                              controller: passwordController,
                              style: const TextStyle(color: Colors.white),
                              decoration:const InputDecoration(
                                  hintText: "Password",
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(fontSize: 17.0,color: Colors.white54)
                              ),
                            ),
                          ),
                          const SizedBox(height: 10,),

                          ///SIGNIn
                          GestureDetector(
                            onTap: doLogin,
                            child: Container(
                              height: 50,
                              padding:const EdgeInsets.only(left: 10,right: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white54.withOpacity(0.2),width: 2),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Center(
                                child: Text("Sign In",style: TextStyle(color: Colors.white,fontSize: 17),),
                              ),
                            ),
                          )
                        ],
                      )
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don`t have an account?",style: TextStyle(color: Colors.white,fontSize: 16),),
                      const SizedBox(width: 10,),
                      GestureDetector(
                        onTap: _callSignUpPage,
                        child: const Text("Sign Up",style: TextStyle(color: Colors.white,fontSize: 17,fontWeight: FontWeight.bold),),
                      )
                    ],
                  ),
                  const SizedBox(height: 20,)
                ],
              ),
              // isLoading ? const Center(
              //   child: CircularProgressIndicator(),
              // ) : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }
}
