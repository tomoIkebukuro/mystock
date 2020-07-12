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
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'class.dart';

Future<String> uploadImage({File file,String collectionName,String fileName}) async {
  final StorageReference ref = FirebaseStorage.instance.ref().child(collectionName).child(fileName);
  final StorageUploadTask uploadTask = ref.putFile(file);
  StorageTaskSnapshot snapshot = await uploadTask.onComplete;
  return await snapshot.ref.getDownloadURL();

  if (snapshot.error == null) {
    return await snapshot.ref.getDownloadURL();
  }
  else{
    return null;
  }
}

Future<Null> uploadProfile(BuildContext context,Profile profile,File nextAvatar) async {

  if (nextAvatar != null) {
    profile.avatarUrl = await uploadImage(
        file: nextAvatar,
        collectionName: 'images',
        fileName: "dummy"
    );
  }
  await Firestore.instance.collection('profile').document(profile.userId).setData(profile.toData());

  return null;

}

Future<Null> updateMyProfile(BuildContext context,Profile profile,File nextAvatar)async{
  await uploadProfile(context, profile, nextAvatar);
  context.read<GlobalModel>().myProfile=profile;
  return null;
}

Future<Profile> resetMyProfile(BuildContext context,String id)async{
  var initialProfile=Profile.getInitialProfile(id);
  await updateMyProfile(context, initialProfile, null);
  return initialProfile;
}



// サーバの状態を取得する関数
//　そもそもサーバに接続できなければnullを返す
Future<Map<String,String>> getServerState()async{
  var stateDocument=await Firestore.instance.collection('talks').document('document-name').get();
  if(stateDocument == null){
    throw Exception("getServerState:サーバに接続できません。\nネットワークの接続を確認してください。");
  }
  if(stateDocument.exists==false){
    throw Exception("getServerState:サーバのstateを確認できません。");
  }
  return stateDocument.data;
}

//プロフィールを取得
Future<Profile> getProfile(String uid)async{
  DocumentSnapshot snapshot;

  snapshot=await Firestore.instance.collection('profile').document(uid).get();

  if(snapshot == null || snapshot.exists==false){
    return null;
  }
  return Profile(snapshot.data);
}

Future<Null> deleteProfile(BuildContext context,String uid) async{
  await Firestore.instance.collection('profile').document(uid).delete();

  return null;
}


//カメラで撮影した写真(File)を選択する
Future<File> pickFileFromCamera() async {

  //pickImageには例外処理が必要
  var pickedFile= await ImagePicker().getImage(source: ImageSource.camera);
  if(pickedFile==null){
    return null;
  }
  return File(pickedFile.path);
}

Future<File> pickFileFromGallery() async {

  //pickImageには例外処理が必要
  var pickedFile= await ImagePicker().getImage(source: ImageSource.gallery);
  if(pickedFile==null){
    return null;
  }
  return File(pickedFile.path);
}


Future<FirebaseUser> loadUser()async{
  return await FirebaseAuth.instance.currentUser();
}



void showErrorDialog(BuildContext context,String message){
  showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: Text("エラーが発生しました。"),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text("OK"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
  );
}