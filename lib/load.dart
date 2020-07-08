import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';

import 'global_model.dart';
import 'login.dart';
import 'edit_profile.dart';
import 'test.dart';
import 'util_func.dart';


class LoadPage extends StatelessWidget{

  Future<Null> load(BuildContext context)async{

    FirebaseUser user;
    try{
      user = await FirebaseAuth.instance.currentUser();
    }catch(e){
      showErrorDialog(context,"ユーザの取得に失敗しました。\n${e.toString()}");
      return null;
    }
    if(user==null){
      // ユーザが登録されていない
      // ログイン画面へ移動
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => LoginPage(),
      ));
      return null;
    }
    context.read<GlobalModel>().user=user;

    Map<String,Object> profile;
    try{
      profile=await getProfile(context,user.uid);
    }catch(e){
      showErrorDialog(context, "プロフィールの取得に失敗しました。\n${e.toString()}");
      return null;
    }

    if(profile==null){
      // プロフィールがそもそも存在しないのでプロフィールを初期化
      //　初期化したプロフィールをprofileに代入
      try{
        profile=await resetMyProfile(context, user.uid);
      }catch(e){
        showErrorDialog(context, "プロフィールの初期化に失敗しました。\n${e.toString()}");
        return null;
      }


      // プロフィール作成画面へ移動
      await Navigator.push(context, MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider<EditProfileModel>(
          create: (context)=>EditProfileModel(),
          child: EditProfilePage(),
        ),
      ));
    }
    //プロフィールが存在したので、
    context.read<GlobalModel>().myProfile=profile;
    // すべての準備が完了
    //　本画面へ移動
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => TestPage(),
    ));
    return null;

  }


  @override
  Widget build(BuildContext context) {

    load(context);

    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}