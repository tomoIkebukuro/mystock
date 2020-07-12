import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';
import 'class.dart';
import 'edit_profile.dart';


class GlobalModel with ChangeNotifier{

  GlobalModel(){
    favoriteMap={};
  }

  Profile _myProfile;
  Profile get myProfile=>this._myProfile;
  set myProfile(value){
    this._myProfile=value;
    notifyListeners();
  }

  Map<String,Object> favoriteMap;

  void addFavorite(String userId){
    favoriteMap[userId]=true;
    notifyListeners();
  }

  void deleteFavorite(String userId){
    favoriteMap.remove(userId);
    notifyListeners();
  }

  FirebaseUser user;

/*

  Future<bool> loadUser()async{
    user=await FirebaseAuth.instance.currentUser();
    return user!=null;
  }

  Future<bool> loadProfile()async{
    if(user?.uid==null){
      throw Exception("user.uidがnullです。\nloadProfile関数を実行する前にloadUser関数を完了させてください。");
    }
    myProfile=getProfile(user.uid);
    return myProfile!=null;
  }
  */

}