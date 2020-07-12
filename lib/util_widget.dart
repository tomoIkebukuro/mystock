import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';
import 'global_model.dart';

import 'util_func.dart';



class ImageNetworkExtended extends StatelessWidget{

  final String url;

  ImageNetworkExtended(this.url);

  Future<bool> cacheImage(String url,BuildContext context) async {
    bool hasNoError=true;
    await precacheImage(
      NetworkImage(url),
      context,
      onError: (e,stackTrace)=>hasNoError=false,
    );
    return hasNoError;
  }

  @override
  Widget build(context){

    return FutureBuilder(
      future:cacheImage(url, context),
      builder: (context,snapshot){
        if(snapshot.hasError||snapshot.data==false){
          return Container(
            decoration: BoxDecoration(
                color: Colors.grey
            ),
            child: Center(
              child: Text('Error',),
            ),
          );
        }
        if(snapshot.connectionState==ConnectionState.waiting){
          return Container(
            decoration: BoxDecoration(
                color: Colors.grey
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Image.network(url);
      },
    );
  }
}