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

class Forum extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>ForumModel(),
      child: Selector<ForumModel,int>(
        selector: (context,model)=>model.count,
        builder: (context,count,child){
          return ListView.builder(
            itemCount: count,
            itemBuilder: (context,index){
              if(index==0){
                return Container(
                  height: 50,
                  margin: EdgeInsets.all(30),
                  child:RaisedButton(
                    shape: StadiumBorder(),
                    child: Icon(Icons.add),
                    onPressed: (){
                      context.read<ForumModel>().count+=1;
                    },
                  ),
                );
              }
              return ForumTile(Comment(index.toString()));
            },
          );
        },
      ),
    );
  }
}

class ForumModel with ChangeNotifier{
  int _count;
  get count=>_count;
  set count(value){
    _count=value;
    notifyListeners();
  }

  ForumModel(){
    count=1;
  }
}



class Comment{
  double initialPrice;
  String profileId;
  String avatarUrl;
  String userId;
  Comment(this.userId);

}

class ForumTile extends StatelessWidget{



  ForumTile(this.comment);
  final Comment comment;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(5),
      child: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 60,



              child: Row(
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 1,
                    child: GestureDetector(
                      child: ClipOval(
                        child: ImageNetworkExtended(
                          //comment.avatarUrl
                          "https://image.freepik.com/free-vector/businessman-character-avatar-icon-vector-illustration-design_24877-18271.jpg",
                        ),
                      ),
                      onTap: (){
                        //Navigator.push(context, MaterialPageRoute(builder: (context) => TestPage()),);
                      },
                    ),
                  ),
                  SizedBox(width: 5,),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("山田太郎",),
                          RichText(
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: "総戦績:",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                    text: "+1000000%",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20
                                    )
                                )
                              ],
                            ),

                          ),
                        ],
                      ),
                    ),
                  ),
                  FavoriteButton(comment.userId),
                  IconButton(
                    icon: Icon(Icons.more_horiz),
                    onPressed: (){

                    },
                  ),
                ],
              ),
            ),
            Divider(),
            Row(
              children: <Widget>[
                Icon(Icons.trending_up,color: Colors.red,size: 60,),
                SizedBox(width: 5,),
                Text("FGHJKL+")
              ],
            ),
            Container(
              child: Text(
                "ここの株は上がりますね。\n上がってくれえええええ",
                style:TextStyle(height:2),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

















