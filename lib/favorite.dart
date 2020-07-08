import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mystock/util_widget.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';
import 'global_model.dart';

import 'load.dart';
import 'edit_profile.dart';


class Favorite extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Selector<GlobalModel,List>(
      selector: (context,model)=>model.favoriteMap.keys.toList(),
      builder: (context,lst,child){
        return ListView.builder(
          itemCount: lst.length,
          itemBuilder: (context,index){
            return ListTile(
              title: Text(lst[index]),
            );
          },
        );
      },
    );
  }
}