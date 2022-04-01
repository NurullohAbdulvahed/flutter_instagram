import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../model/post_model.dart';
import '../model/user_model.dart';
import 'prefs_service.dart';
import 'utils.dart';

class DataService {
  static final instance = FirebaseFirestore.instance;
  static String folderUsers = 'users';
  static String folderPosts = "posts";
  static String folderFeeds = "feeds";
  static String folderFollowing = "following";
  static String folderFollowers = "followers";
  static String folderlikers = "likers";

  static Future storeUser(Users user) async {
    user.uid = (await Prefs.loadUserId())!;
    Map<String, String> params = await Utils.deviceParams();
    if (kDebugMode) {
      print(params.toString());
    }

    user.device_id = params["device_id"] ?? "";
    user.device_type = params["device_type"]?? "";
    user.device_token = params["device_token"]?? "";

    return instance.collection(folderUsers).doc(user.uid).set(user.toJson());
  }

  static Future<Users> loadUser() async {
    String? uid = await Prefs.loadUserId();
    var value = await instance.collection("users").doc(uid).get();
    Users user = Users.fromJson(value.data()!);

    QuerySnapshot querySnapshot1 = await instance.collection(folderUsers).doc(
        uid).collection(folderFollowers).get();
    user.followersCount = querySnapshot1.docs.length;

    QuerySnapshot querySnapshot2 = await instance.collection(folderUsers).doc(
        uid).collection(folderFollowing).get();
    user.followingCount = querySnapshot2.docs.length;

    return user;
  }

  static Future<List<Users>> loadFollowings({required String uid}) async {
    List<Users> usersList = [];
    var querySnapshot = await instance.collection(folderUsers).doc(uid)
        .collection(folderFollowing).where("uid", isNotEqualTo: "1")
        .get();
    for (var element in querySnapshot.docs) {
      usersList.add(Users.fromJson(element.data()));
    }
    return usersList;
  }


  static Future updateUser(Users users) async {
    var value = await instance
        .collection(folderUsers)
        .doc(users.uid)
        .update(users.toJson());
    return value;
  }

  static Future<List<Users>> searchUsers(String keyword) async {
    List<Users> users = [];
    String? uid = await Prefs.loadUserId();
    var querySnapshot = await instance.collection(folderUsers)
        .orderBy("email")
        .startAt([keyword])
        .get();
    for (var result in querySnapshot.docs) {
      Users newUser = Users.fromJson(result.data());
      if (newUser.uid != uid) {
        users.add(newUser);
      }
    }

    List<Users> following = [];
    var querySnapshot2 = await instance.collection(folderUsers)
        .doc(uid)
        .collection(folderFollowing)
        .get();
    for (var result in querySnapshot2.docs) {
      following.add(Users.fromJson(result.data()));
    }

    for (Users user in users) {
      if (following.contains(user)) {
        user.followed = true;
      } else {
        user.followed = false;
      }
    }

    return users;
  }

  static Future<Post> storePost(Post post) async {
    ///Filled Post
    Users me = await loadUser();
    post.uid = me.uid;
    post.fullName = me.fullName;
    post.imageUser = me.imgUrl;
    post.createdDate = DateTime.now().toString();

    String postId = instance
        .collection(folderUsers)
        .doc(me.uid)
        .collection(folderPosts)
        .doc()
        .id;
    post.id = postId;

    await instance
        .collection(folderUsers)
        .doc(me.uid)
        .collection(folderPosts)
        .doc(postId)
        .set(post.toJson());

    return post;
  }

  static Future<Post> storeFeed(Post post) async {
    String? uid = await Prefs.loadUserId();
    await instance
        .collection(folderUsers)
        .doc(uid)
        .collection(folderFeeds)
        .doc(post.id)
        .set(post.toJson());
    if (kDebugMode) {
      print(post.toJson().toString());
    }
    return post;
  }

  static Future<List<Post>> loadFeeds() async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();
    var querySnapshot = await instance
        .collection(folderUsers)
        .doc(uid)
        .collection(folderFeeds)
        .get();
    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      if (post.uid == uid) post.isMine = true;
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Post>> loadPosts() async {
    List<Post> posts = [];
    String? uid = await Prefs.loadUserId();
    var querySnapshot = await instance
        .collection(folderUsers)
        .doc(uid)
        .collection(folderPosts)
        .get();
    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      posts.add(post);
    }
    return posts;
  }

  static Future<List<Post>> loadSomeOnePosts(
      {required String someOneuid}) async {
    List<Post> posts = [];
    var querySnapshot = await instance
        .collection(folderUsers)
        .doc(someOneuid)
        .collection(folderPosts)
        .get();
    for (var result in querySnapshot.docs) {
      Post post = Post.fromJson(result.data());
      posts.add(post);
    }
    return posts;
  }

  static Future<Post?> likePost(Post post, bool liked) async {
    String? uid = await Prefs.loadUserId();
    post.isLiked = liked;
    await instance.collection(folderUsers).doc(uid).collection(folderFeeds).doc(
        post.id).set(post.toJson());

    if (uid == post.uid) {
      await instance
          .collection(folderUsers)
          .doc(uid)
          .collection(folderPosts)
          .doc(post.id)
          .set(post.toJson());
    }
    return null;
  }


  static Future<List<Post>> loadLikes() async {
    String? uid = await Prefs.loadUserId();
    List<Post> posts = [];
    var querySnapshot = await instance
        .collection(folderUsers)
        .doc(uid)
        .collection(folderFeeds)
        .where("isLiked", isEqualTo: true)
        .get();
    for (var element in querySnapshot.docs) {
      Post post = Post.fromJson(element.data());
      if (post.uid == uid) post.isMine = true;
      posts.add(post);
    }
    return posts;
  }

  ///Follower and Following Related
  static Future<Users> followUser(Users someone) async {
    Users me = await loadUser();

    ///I followed to someone
    await instance
        .collection(folderUsers)
        .doc(me.uid)
        .collection(folderFollowing)
        .doc(someone.uid)
        .set(someone.toJson());

    ///I am in someone`s followers
    await instance
        .collection(folderUsers)
        .doc(someone.uid)
        .collection(folderFollowers)
        .doc(me.uid)
        .set(me.toJson());
    return someone;
  }

  static Future<Users> likedBy(Users someone) async {
    Users me = await loadUser();
    await instance
        .collection(folderUsers)
        .doc(someone.uid)
        .collection(folderlikers)
        .doc(me.uid)
        .set(me.toJson());

    return someone;
  }

  ///unFollower and unFollowing Related
  static Future<Users> unfollowUser(Users someone) async {
    Users me = await loadUser();

    ///I unfollowed to someone
    await instance
        .collection(folderUsers)
        .doc(me.uid)
        .collection(folderFollowing)
        .doc(someone.uid)
        .delete();

    ///I am in someone`s unfollowers
    await instance
        .collection(folderUsers)
        .doc(someone.uid)
        .collection(folderFollowers)
        .doc(me.uid)
        .delete();
    return someone;
  }

  static Future storePostToMyFeed(Users someone) async {
    ///Store someone`s posts to my feed
    List<Post> posts = [];
    var querySnapshot = await instance
        .collection(folderUsers)
        .doc(someone.uid)
        .collection(folderPosts)
        .get();
    for (var element in querySnapshot.docs) {
      var post = Post.fromJson(element.data());
      post.isLiked = false;
      posts.add(post);
    }
    for (Post post in posts) {
      storeFeed(post);
    }
  }


  static Future removePostsFromMyFeed(Users someone) async {
    ///Remove someone1s posts from my feed

    List<Post> posts = [];
    var querySnapshot = await instance
        .collection(folderUsers)
        .doc(someone.uid)
        .collection(folderPosts)
        .get();
    for (var element in querySnapshot.docs) {
      posts.add(Post.fromJson(element.data()));
    }
    for (Post post in posts) {
      removeFeed(post);
    }
  }

  static Future removeFeed(Post post) async {
    String? uid = await Prefs.loadUserId();

    return await instance.collection(folderUsers).doc(uid).collection(
        folderFeeds).doc(post.id).delete();
  }

  static Future removePost(Post post) async {
    String? uid = await Prefs.loadUserId();
    await removeFeed(post);
    return await instance.collection(folderUsers).doc(uid)
        .collection(folderPosts).doc(post.id).delete();
  }
}