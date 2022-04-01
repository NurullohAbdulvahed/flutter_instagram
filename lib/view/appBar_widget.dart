import 'package:flutter/material.dart';
import '../services/theme_service.dart';

AppBar appBar({required String title, Icon? icon, void Function()? onPressed,required bool isCenter}) {
  return AppBar(
    automaticallyImplyLeading: false,
    elevation: 0,
    backgroundColor: Colors.white,
    centerTitle: isCenter,
    title: Text(title, style: ThemeService.appBarStyle,),
    actions: [
      if(icon != null) IconButton(onPressed: onPressed, icon: icon)
    ],
  );
}