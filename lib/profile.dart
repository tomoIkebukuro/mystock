import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mystock/global_model.dart';
import 'package:provider/provider.dart';
import 'dart:io';
//import 'package:simple_image_crop/simple_image_crop.dart';
import 'util_widget.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:exif/exif.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';

import 'util_func.dart';
import 'util/widget.dart';
import 'class.dart';
import 'favorite.dart';
import 'edit_profile.dart';

class ProfilePage extends StatelessWidget{

  final String userId;

  ProfilePage(this.userId);

  Future<Null> onChangeButtonPressed(BuildContext context) async{
    // プロフィール作成画面へ移動
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) => EditProfilePage(),
    ));

    return null;
  }

  @override
  Widget build(BuildContext context) {
    print("$userId       userId");
    return FutureBuilder<Profile>(
      future:getProfile(userId),
      builder: (context,snapshot){
        if(snapshot.hasError||snapshot.connectionState==ConnectionState.none){
          return Scaffold(
            body: Center(
              child: Text("ERROR"),
            ),
          );
        }
        if(snapshot.connectionState==ConnectionState.waiting){
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if(snapshot.data==null){
          return Scaffold(
            body: Center(
              child: Text("プロフィールが存在しません。"),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              Provider.of<GlobalModel>(context,listen: false).myProfile.userId==this.userId
                  ?RaisedButtonModified(text: "変更",onPressed: ()=>onChangeButtonPressed(context),)
                  :FavoriteButton(snapshot.data.userId),
            ],
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    RaisedButtonModified(text: "変更",),
                    RaisedButtonModified(text: "変更",),
                  ],
                ),
                Container(
                  width: 100,
                  height: 100,
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: snapshot.data.avatarUrl,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                  ),
                ),
                Text(snapshot.data.name),
                Text(snapshot.data.introduction),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MyProfilePage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ProfilePage(context.watch<GlobalModel>().myProfile.userId);
  }
}