class Users {
 String uid = "";
 late String fullName;
 late String email;
 late String password;
 String device_id = "";
 String device_type = "";
 String device_token = "";
 String? imgUrl;
 bool followed = false;
 int? followersCount = 0;
 int? followingCount = 0;

 Users({required this.fullName, required this.email, required this.password});

 Users.fromJson(Map<String, dynamic> json) {
  uid = json["uid"];
  fullName = json["fullName"] ?? "";
  email = json["email"];
  password = json["password"];
  imgUrl = json["imageUrl"];
  followersCount = json["followersCount"];
  followingCount = json["followingCount"];
  device_id = json["device_id"] ?? " ";
  device_type = json["device_type"] ?? " ";
  device_token = json["device_token"] ?? " ";
 }

 Map<String, dynamic> toJson() => {
  "uid": uid,
  "fullName": fullName,
  "email": email,
  "password": password,
  "imageUrl": imgUrl,
  "followingCount": followingCount,
  "followersCount": followersCount,
  "device_id": device_id,
  "device_type": device_type,
  "device_token": device_token,
 };

 @override
 bool operator ==(Object other) {
  return other is Users && other.uid == uid;
 }

 @override
 int get hashCode => uid.hashCode;
}