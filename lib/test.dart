import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';
import 'global_model.dart';

import 'load.dart';
import 'edit_profile.dart';

class TestModel with ChangeNotifier{
  int _count=0;
  int get count=>_count;
  set count(int value){
    _count=value;
    notifyListeners();
  }
}
int rcount=0;
class TestPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider(
      create: (context)=>TestModel(),
      builder:(context,child){
        rcount+=1;
        print(rcount);
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              context.read<TestModel>().count+=1;
            },
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(context.select<TestModel,int>((model)=>model.count).toString()),
                Text(context.select<TestModel,int>((model)=>model.count).toString()),
              ],
            ),
          ),
        );
      },
    );
  }
}




