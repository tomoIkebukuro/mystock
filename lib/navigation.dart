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
    Text("3"),
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<NavigationModel,int>(
      selector: (context,model)=>model.index,
      builder: (context,index,child){
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.green
            ),
            backgroundColor: Colors.white,
            title: Text("mystock"),
          ),
          body: IndexedStack(
            index: index,
            children: bodyList,
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,

            currentIndex: index,
            onTap: (value){context.read<NavigationModel>().index=value;},
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.forum,),
                title: Text("A"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search,),
                title: Text("B"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite,),
                title: Text("C"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person,),
                title: Text("D"),
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