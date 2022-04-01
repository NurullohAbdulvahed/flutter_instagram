// import 'dart:io';
//
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter_instagram/services/prefs_service.dart';
//
// class FileService{
//   static final Reference _storage = FirebaseStorage.instance.ref();
//   static const folder_post = "post_images";
//   static const folder_user = "user_images";
//
//
//   static Future<String?> uploadUserImage(File? _image) async {
//     String? img_name = "image_" + DateTime.now().toString();
//     Reference reference = _storage.child(folder_user).child(img_name);
//     UploadTask uploadTask = reference.putFile(_image!);
//     TaskSnapshot taskSnapshot = await uploadTask;
//     final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//     return downloadUrl;
//   }
//
//   static Future<String?> uploadPostImage(File? _image) async {
//     String? uid = await Prefs.loadUserId();
//     String? img_name = uid! + "_" + DateTime.now().toString();
//     Reference reference = _storage.child(folder_user).child(img_name);
//     UploadTask uploadTask = reference.putFile(_image!);
//     TaskSnapshot taskSnapshot = await uploadTask;
//     if(taskSnapshot != null){
//       final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//       return downloadUrl;
//     }
//     return null;
//   }
// }

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FileService {
  static final Reference _storage = FirebaseStorage.instance.ref();
  static const String folderUserImg = "user_image";
  static const String folderPostImg = "post_image";

  static Future<String> uploadImage(File image, String folder) async {
    // image name
    String imgName = "image_" + DateTime.now().toString();
    Reference storageRef = _storage.child(folder).child(imgName);
    UploadTask uploadTask = storageRef.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;

    final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}