import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';
import 'global_model.dart';
import 'edit_profile.dart';
import 'util_func.dart';
import 'load.dart';

class LoginPage extends StatelessWidget{

  Future<Null> googleSignIn(BuildContext context) async {

    await GoogleSignIn().signOut();

    try{
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      if(googleUser==null){
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      FirebaseUser user=(await FirebaseAuth.instance.signInWithCredential(credential)).user;
      context.read<GlobalModel>().user=user;

      if(user!=null){
        Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => LoadPage(),
        ));
      }
    }catch(e){
      showErrorDialog(context, "アカウントを認証できませんでした。\n${e.toString()}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          child: Text("login"),
          onPressed: ()async {
            await googleSignIn(context);
          },
        ),
      ),
    );
  }
}