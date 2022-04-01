import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram/model/post_model.dart';
import 'package:flutter_instagram/services/data_service.dart';
import 'package:flutter_instagram/services/utils.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../model/user_model.dart';


class MyFeedPage extends StatefulWidget {
  static String id = "MyFeedPage";
  PageController pageController;
   MyFeedPage({Key? key,required this.pageController}) : super(key: key);


  @override
  _MyFeedPageState createState() => _MyFeedPageState();
}

class _MyFeedPageState extends State<MyFeedPage> {
  bool isLoading = false;
  Users? users;
  List<Users> story = [];
  List items = [];


  @override
  void initState() {
    super.initState();
    _apiLoadUser();
    _apiLoadFeeds();
  }

  void _apiLoadUser() async {
    setState(() {
      isLoading = true;
    });
    await DataService.loadUser().then((value) => {
      _showUserInfo(value),
    });
    //_loadFollowings();
  }

  // void _loadFollowings() async {
  //   await DataService.loadFollowings(uid: users!.uid).then((value) => {
  //     _showFollowings(value),
  //   });
  // }

  void _showFollowings(List<Users> followingUsers) {
    if(mounted) {
      setState(() {
        story = followingUsers;
      });
    }
  }

  void _showUserInfo(Users user) {
    if (mounted) {
      setState(() {
        users = user;
        isLoading = false;
      });
    }
  }

  void _apiLoadFeeds() async {
    setState(() {
      isLoading = true;
    });
    await DataService.loadFeeds().then((posts) => {_resLoadFeeds(posts)});
  }

  void _resLoadFeeds(List<Post> posts) {
    if(mounted){
      setState(() {
        isLoading = false;
        items = posts;
      });
    }
  }

  void _apiPostLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, true);
    setState(() {
      isLoading = false;
      post.isLiked = true;
    });
  }

  void _apiPostUnLike(Post post) async {
    setState(() {
      isLoading = true;
    });
    await DataService.likePost(post, false);
    setState(() {
      isLoading = false;
      post.isLiked = false;
    });
  }

  ///Remove your post
  void _actionRemovePost(Post post) async {
    var result = await Utils.dialogCommon(
        context, "Instagram Clone", "Do you want to remove this post?", false);
    if (result) {
      DataService.removePost(post).then((value) => {
        _apiLoadFeeds(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: (){
               widget.pageController.animateToPage(2, duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
          },
              icon: const Icon(Icons.camera_alt,color: Colors.black,))
        ],
        title:const Text("Instagram",style: TextStyle(color: Colors.black,fontSize: 30,fontFamily: 'Billabong'),),
      ),
      body: Stack(
        children: [
          ListView.builder(
              itemCount: items.length,
              itemBuilder:(ctx,index){
                return _itemOfPost(items[index]);
              }
          ),
          isLoading ? const Center(child: CircularProgressIndicator()) :
              const SizedBox.shrink()
        ],
      )
    );
  }
  Widget _itemOfPost(Post post){
    return Container(
      margin:const EdgeInsets.only(bottom: 1),
      color: Colors.white,
      child: Column(
        children: [
          const Divider(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset("assets/images/ic_person.png",width: 40,height: 40,fit: BoxFit.cover,),
                    ),
                    const SizedBox(width: 10,),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.fullName,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                        Text(post.createdDate.substring(0,16),style:const  TextStyle(fontWeight: FontWeight.normal),),
                      ],
                    )
                  ],
                ),
                post.isMine ? IconButton(onPressed: (){
                  _actionRemovePost(post);
                }, icon: const Icon(Icons.more_horiz)) :
                 const SizedBox.shrink()
              ],
            ),
          ),

          ///Image
          //Image.network(post.postImage,fit: BoxFit.cover,),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
              imageUrl: post.postImage,
              placeholder: (context,url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (ctx,url,error)=> const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
          ///likeshare



          Row(
            children: [
              IconButton(onPressed: (){
                if(post.isLiked) {
                  _apiPostUnLike(post);
                }
                else{
                  _apiPostLike(post);
                }
              },
                  icon: post.isLiked ? const Icon(FontAwesomeIcons.solidHeart,color: Colors.red,) : const Icon(FontAwesomeIcons.heart)),
              IconButton(onPressed: (){}, icon: const Icon(FontAwesomeIcons.telegramPlane)),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(left: 10,right: 10,bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                children: [
                  TextSpan(text: post.caption,style: const TextStyle(color: Colors.black))
                ]
              ),
            ),
          )
        ],
      ),
    );
  }
}
