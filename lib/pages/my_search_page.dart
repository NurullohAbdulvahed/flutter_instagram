import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/user_model.dart';
import '../services/data_service.dart';
import '../view/appBar_widget.dart';

class MySearchPage extends StatefulWidget {
  static String id = "MySearchPage";

  const MySearchPage({Key? key}) : super(key: key);

  @override
  _MySearchPageState createState() => _MySearchPageState();
}

class _MySearchPageState extends State<MySearchPage> {
  List<Users?> items = [];
  bool isLoading = false;
  TextEditingController searchController = TextEditingController();

  void _apiSearchUsers(String keyword){
    setState(() {
      isLoading = true;
    });
    DataService.searchUsers(keyword).then((value) => {
      _respSearchUsers(value),
    });
  }

  void _respSearchUsers(List<Users> users){
    if(mounted) {
      setState(() {
        items = users;
        isLoading = false;
      });
    }
  }
  void _apiFollowUser(Users someone) async{
    setState(() {
      isLoading = true;
    });
    await DataService.followUser(someone);
    setState(() {
      someone.followed = true;
      isLoading = false;
    });
    // await Network.POST(Network.API_LIST, Network.bodyUpload(someone.device_token,someone.fullName))
    //     .then((value) {
    //   if (kDebugMode) {
    //     print(value);
    //   }
    // });
    DataService.storePostToMyFeed(someone);
  }

  void _apiUnfollowUser(Users someone) async{
    setState(() {
      isLoading = true;
    });
    await DataService.unfollowUser(someone);
    setState(() {
      someone.followed = false;
      isLoading = false;
    });
    DataService.removePostsFromMyFeed(someone);
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _apiSearchUsers("");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar(title: "Search", isCenter: true),
        body:Stack(
          children: [
            Container(
              child: Column(
                children: [
                  ///Search User
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height*0.05,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.shade200),
                      child: TextField(
                        onChanged: (input) {
                          if (kDebugMode) {
                            print(input);
                          }
                          _apiSearchUsers(input);
                        },
                        controller: searchController,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: "Search",
                            hintStyle: TextStyle(color: Colors.grey),
                            prefixIcon: Icon(Icons.search,color: Colors.grey,)
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                        itemBuilder: (ctx, index) {
                          return itemOfUser(items[index]!);
                        },
                        itemCount: items.length,
                      )),
                ],
              ),
            ),

            isLoading ? const Center(
              child: CircularProgressIndicator(),
            ) : const SizedBox.shrink()
          ],
        )
    );
  }
  Widget itemOfUser(Users users) {
    return GestureDetector(

      onTap: (){
        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => AnotherPage(users: users,)));
      },
      child: ListTile(
        horizontalTitleGap: 10,
        leading: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: Colors.purpleAccent, width: 2)
          ),
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: users.imgUrl != null ? CachedNetworkImage(
              height: 40,
              width: 40,
              fit: BoxFit.cover,
              imageUrl: users.imgUrl!,
              placeholder: (context, url) => const Image(image: AssetImage("assets/images/ic_person.png")),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ) : const Image(image: AssetImage("assets/images/ic_person.png"), height: 40, width: 40,),
          ),
        ),
        title: Text(users.fullName, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        subtitle: Text(users.email, style: TextStyle(color: Colors.black54,overflow: TextOverflow.ellipsis)),
        trailing: Container(
          height: 30,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: MaterialButton(
            onPressed: () {
              if(users.followed) {
                _apiUnfollowUser(users);
              }
              else{
                _apiFollowUser(users);
              }
            },
            child:users.followed ?  const Text("Following", style: TextStyle(color: Colors.black87,), ) : Text("Follow", style: const TextStyle(color: Colors.black87,), ),
          ),
        ),
      ),
    );
  }
}
