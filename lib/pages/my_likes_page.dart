import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../model/post_model.dart';
import '../services/data_service.dart';
import '../services/utils.dart';
import '../view/appBar_widget.dart';



class LikesPage extends StatefulWidget {
  static String id = "LikesPage";
  const LikesPage({Key? key}) : super(key: key);

  @override
  _LikesPageState createState() => _LikesPageState();
}

class _LikesPageState extends State<LikesPage> {
  List items = [];
  bool isLoading = false;
  @override



  void initState() {
    super.initState();
    _apiLoadLikes();
  }

  void _apiLoadLikes() {
    setState(() {
      isLoading = true;
    });
    DataService.loadLikes().then((value) => {
      _resLoadLikes(value),
    });
  }
  void _resLoadLikes(List<Post> posts){
    setState(() {
      items = posts;
      isLoading = false;
    });
  }



  void _apiPostUnlikes(Post post){
    setState(() {
      isLoading = true;
      post.isLiked = false;
    });
    DataService.likePost(post, false).then((value) => {
      _apiLoadLikes()
    });
  }

  ///Remove your post
  void _actionRemovePost(Post post) async{
    var result = await Utils.dialogCommon(context, "Instagram Clone", "Do you want to remove this post?", false);
    if(result){
      setState(() {
        isLoading = true;
      });
      DataService.removePost(post).then((value) => {
        _apiLoadLikes(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(title: "Likes", isCenter: true,icon: Icon(Icons.camera_alt,color: Colors.black,)),
        body: Stack(
          children: [
            items.isNotEmpty ?
            ListView.builder(
                itemCount: items.length,
                itemBuilder:(ctx,index){
                  return _itemOfPost(items[index]);
                }
            ): const Center(
              child: Text("No liked Posts"),
            ),

            isLoading ? const Center(
              child: CircularProgressIndicator(),
            ) : SizedBox.shrink()
          ],
        )
    );
  }
  Widget _itemOfPost(Post post){
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
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
                      child: (post.imageUser == null || post.imageUser!.isEmpty)?
                      const Image(
                        image: AssetImage("assets/images/ic_person.png"),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ) : Image.network(
                        post.imageUser!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10,),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:  [
                        Text(post.fullName == null ? " " : post.fullName,style:TextStyle(fontWeight: FontWeight.bold,color: Colors.black),),
                        Text(post.createdDate == null ? " " : post.createdDate,style: TextStyle(fontWeight: FontWeight.normal),),
                      ],
                    )
                  ],
                ),
                post.isMine ? IconButton(onPressed: (){
                  _actionRemovePost(post);
                },
                    icon: const Icon(Icons.more_horiz)) : const SizedBox.shrink()
              ],
            ),
          ),

          ///Image
          //Image.network(post.postImage,fit: BoxFit.cover,),
          CachedNetworkImage(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            imageUrl:post.postImage,
            placeholder: (context,url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (ctx,url,error)=>const Icon(Icons.error),
            fit: BoxFit.cover,
          ),
          ///likeshare



          Row(
            children: [
              IconButton(onPressed: (){
                _apiPostUnlikes(post);
              }, icon: const Icon(FontAwesomeIcons.solidHeart,color: Colors.red,)),
              IconButton(onPressed: (){

              }, icon: const Icon(FontAwesomeIcons.telegramPlane)),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            margin:const EdgeInsets.only(left: 10,right: 10,bottom: 10),
            child: RichText(
              softWrap: true,
              overflow: TextOverflow.visible,
              text: TextSpan(
                  children: [
                    TextSpan(text: post.caption,style: TextStyle(color: Colors.black))
                  ]
              ),
            ),
          )
        ],
      ),
    );
  }
}