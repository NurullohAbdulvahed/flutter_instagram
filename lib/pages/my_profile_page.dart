import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/model/post_model.dart';
import 'package:flutter_instagram/services/auth_service.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/services/file_service.dart';
import 'package:image_picker/image_picker.dart';
import '../model/user_model.dart';


class MyProfilePage extends StatefulWidget {
  static String id = "MyProfilePage";
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  bool isLoading = false;
  List<Post> items = [];
  Users? users;
  File? _image;
  int countPosts = 0;

  ///Picker Camera
  _imgFromCamera() async {
    XFile? image = await ImagePicker().pickImage(
        source: ImageSource.camera, imageQuality: 50
    );

    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }
  ///Picker Gallery
  _imgFromGallery() async {
    XFile? image = await  ImagePicker().pickImage(
        source: ImageSource.gallery, imageQuality: 50
    );
    setState(() {
      _image = File(image!.path);
    });
    _apiChangePhoto();
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title:const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        }
    );
  }
  void _apiChangePhoto() {
    if(_image == null) return;

    setState(() {
      isLoading = true;
    });
    FileService.uploadImage(_image!, FileService.folderUserImg).then((value) => _apiUpdateUser(value));
  }

  void _apiUpdateUser(String imgUrl) async{
    setState(() {
      isLoading = false;
      users!.imgUrl = imgUrl;
    });
    await DataService.updateUser(users!);
  }


  void _apiLoadUser() async {
    setState(() {
      isLoading = true;
    });
    DataService.loadUser().then((value) => _showUserInfo(value));
  }

  void _showUserInfo(Users user) {
    setState(() {
      users = user;
      isLoading = false;
    });
  }

  void _apiLoadPost() {
    DataService.loadPosts().then((posts) => {
      _resLoadPost(posts)
    });
  }
  void _resLoadPost(List<Post> post){
    setState(() {
      items = post;
      countPosts = items.length;
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiLoadUser();
    _apiLoadPost();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: (){
            AuthService.signOutUser(context);
          },
            icon: const Icon(Icons.exit_to_app),color: Colors.black,)
        ],
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title:const Text("Profile",style: TextStyle(color: Colors.black,fontSize: 30,fontFamily: 'Billabong'),),
      ),
      body: Container(
        width: double.infinity,
        padding:const EdgeInsets.all(10),

        child: Column(
          children: [
            ///MyPhoto
            Stack(
              children: [
                Container(
                  padding:const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(70),
                      border: Border.all(width: 1.5,color: Color.fromRGBO(193, 53, 132, 1))
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child:users?.imgUrl == null || users!.imgUrl!.isEmpty  ?  const Image(
                      image: AssetImage("assets/images/ic_person.png"),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ) : Image.network(users!.imgUrl!,height: 70,width: 70,fit: BoxFit.cover,)
                  ),
                ),
                Container(
                  height: 80,
                  width: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [

                      GestureDetector(
                          onTap: (){
                            // showMaterialModalBottomSheet(
                            //
                            //   context: context,
                            //   builder: (context) =>
                            //       itemsModalSheet(context),
                            // );
                            _showPicker(context);
                          },
                          child: Icon(Icons.add_circle,color: Colors.purple,),)
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 10,),
            Text(users == null ? "": users!.fullName.toUpperCase(),style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
            const SizedBox(height: 3,),
            Text(users == null ? "": users!.email,style: TextStyle(color: Colors.black54,fontSize: 14,fontWeight: FontWeight.normal),),

            ///mycounts
            SizedBox(
              height: 80,
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(countPosts.toString(),style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                          const SizedBox(height: 3,),
                          const Text("Posts",style: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.normal),),

                        ],
                      ),
                    ),
                  ),
                  Container(width: 1,height: 20,color: Colors.grey.withOpacity(0.5),),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children:[
                          Text(users == null ? "0" : users!.followersCount.toString(),style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                          const SizedBox(height: 3,),
                          const Text("Followers",style: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.normal),),

                        ],
                      ),
                    ),
                  ),
                  Container(width: 1,height: 20,color: Colors.grey.withOpacity(0.5),),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                           Text(users == null ? "0" : users!.followingCount.toString(),style: TextStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.bold),),
                          SizedBox(height: 3,),
                          Text("Following",style: TextStyle(color: Colors.grey,fontSize: 14,fontWeight: FontWeight.normal),),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child:GridView.builder(
                shrinkWrap: true,
                  gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
                  itemCount: items.length,
                  itemBuilder: (ctx,index){
                     return itemOfPost(items[index]);
                  }
                  ) ,
            )
          ],
        ),
      ),
    );
  }
  Widget itemOfPost(Post post){
    return Container(
      margin: EdgeInsets.all(5),
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              width: double.infinity,
              imageUrl: post.postImage,
              fit: BoxFit.cover,
              placeholder: (context,url) =>const CircularProgressIndicator(),
              errorWidget: (ctx,url,error)=>const Icon(Icons.error),
            ),
          ),
          const SizedBox(height: 3,),
          Text(post.caption,style: TextStyle(color: Colors.black87.withOpacity(0.7)),maxLines: 2,),
        ],
      ),
    );
  }
  Container itemsModalSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height*0.16,
      width: double.infinity,
      color: Colors.white,
      child: Column(
        children: [
          MaterialButton(
            onPressed: () {
              _imgFromGallery();
              _apiChangePhoto();
              Navigator.of(context).pop();

            },
            child:const  ListTile(
              leading: Icon(Icons.image),
              title: Text("Pick Photo"),
            ),
          ),
          MaterialButton(
            onPressed: () {
             _imgFromCamera();
             _apiChangePhoto();
              Navigator.of(context).pop();

            },
            child:const  ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text("Take Photo"),
            ),
          ),
        ],
      ),
    );
  }
}