import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io';
//import 'package:simple_image_crop/simple_image_crop.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'global_model.dart';

import 'load.dart';
import 'edit_profile.dart';
import 'forum.dart';
import 'favorite.dart';
import 'profile.dart';
//chat

//search

//chat

//favorite

//profile

//

class NavigationPage extends StatelessWidget{

  final List<Widget> bodyList=[
    Forum(),
    Favorite(),
    Text("2"),
    MyProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>NavigationModel(),
      builder: (context,child){
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.green
            ),
            backgroundColor: Colors.white,
            title: Text("mystock"),
          ),
          body: IndexedStack(
            index: context.select<NavigationModel,int>((model)=>model.index),
            children: bodyList,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: context.select<NavigationModel,int>((model)=>model.index),
            onTap: (value){context.read<NavigationModel>().index=value;},
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.forum,),
                title: Text("Forum"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search,),
                title: Text("Search"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite,),
                title: Text("Favorite"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person,),
                title: Text("Profile"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NavigationModel with ChangeNotifier{
  int _index=0;
  get index=>_index;
  set index(value) {
    _index = value;
    notifyListeners();
  }
}