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
import 'class.dart';
import 'util_func.dart';
import 'util/widget.dart';

class EditProfileModel with ChangeNotifier{

  EditProfileModel(this.profile);

  //nextAvatarは次に設定するアバター
  //新しく写真を撮るなどしてアバターを変更すると代入される
  //nullの場合はアバターが変更されていないことを示す
  File _nextAvatar;
  get nextAvatar => _nextAvatar;
  set nextAvatar(value){
    _nextAvatar=value;
    notifyListeners();
  }

  Profile profile;

}

class EditProfilePage extends StatefulWidget{

  EditProfilePage({Key key}):super(key:key);

  @override
  EditProfileState createState()=>EditProfileState();
}

class EditProfileState extends State<EditProfilePage>{

  //Map<String,Object> nextProfile;
  //Profile originalProfile;
  //TextEditingController nameController=TextEditingController();
  //TextEditingController introductionController=TextEditingController();
  //String defaultAvatarUrl;

  //Formで使う
  final formKey = GlobalKey<FormState>();
  //Profile profile;

  Future<File> cropAvatar(File file) async{
    if(file==null){
      return null;
    }
    return await ImageCropper.cropImage(
      sourcePath: file.path,
      aspectRatio: CropAspectRatio(ratioX: 1,ratioY:1),
      cropStyle: CropStyle.circle,
      androidUiSettings: AndroidUiSettings(
        toolbarWidgetColor: Colors.green,
        hideBottomControls: true,
      ),
    );
  }

  Future<Null> onCameraButtonPressed(BuildContext context)async{
    try{
      context.read<EditProfileModel>().nextAvatar=await cropAvatar(await pickFileFromCamera());
    }catch(e){
      showErrorDialog(context, e.toString());
    }
    return null;
  }

  Future<Null> onGalleryButtonPressed(BuildContext context)async{
    try{
      context.read<EditProfileModel>().nextAvatar=await cropAvatar(await pickFileFromGallery());
    }catch(e){
      showErrorDialog(context, e.toString());
    }
    return null;
  }

  Future<Null> onSaveButtonPressed(BuildContext context) async{

    //formの内容をチェック
    if(!formKey.currentState.validate()) {
      return null;
    }

    var profile=context.read<EditProfileModel>().profile.clone();
    profile.name=name;
    profile.introduction=introduction;

    var avatar=context.read<EditProfileModel>().nextAvatar;

    try{
      await updateMyProfile(context, profile,avatar );
    }catch(e){
    showErrorDialog(context, "");
    return null;
    }

    Navigator.of(context).pop();
  }

  String name;
  String introduction;

  @override
  Widget build(BuildContext context) {

    //initialize(context);

    return ChangeNotifierProvider<EditProfileModel>(
      create: (context) {
        var profile=context.read<GlobalModel>().myProfile.clone();
        name=profile.name;
        introduction=profile.introduction;
        return EditProfileModel(profile);
      },
      builder: (context,child){
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.green
            ),
            backgroundColor: Colors.white,
            actions: <Widget>[
              RaisedButtonModified(
                onPressed: ()=>onSaveButtonPressed(context),
                text: "保存",
              )
            ],
          ),
          body: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  reverse: false,
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:<Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: IconButton(
                              icon: Icon(Icons.camera_alt,),
                              onPressed:  ()async{
                                await onCameraButtonPressed(context);
                              },
                            ),
                          ),
                          Selector<EditProfileModel,File>(
                            selector: (context,model)=>model.nextAvatar,
                            builder: (context,file,child){
                              if(file==null){
                                return NetworkAvatar(
                                  avatarUrl:context.select<EditProfileModel,String>((model)=>model.profile.avatarUrl),
                                  size: 100,
                                );
                              }
                              return FileAvatar(
                                file: file,
                                size: 100,
                              );
                            },
                          ),
                          Expanded(
                            child: IconButton(
                              icon: Icon(Icons.image,),
                              onPressed:  ()async{
                                await onGalleryButtonPressed(context);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: '名前　',
                              ),
                              maxLength: 32,
                              //controller: nameController,
                              initialValue: context.select<EditProfileModel,String>((model) => model.profile.name),
                              validator: (value){
                                if(value.length==0){
                                  return '名前を入力してください。';
                                }
                                return null;
                              },
                              /*
                        onSaved: (value){
                          profile.name=value;
                        },*/
                              autofocus: false,
                            ),
                            TextFormField(
                              initialValue: introduction,
                              keyboardType: TextInputType.multiline,
                              autofocus: false,
                              decoration: InputDecoration(
                                labelText: '紹介文',
                                border: OutlineInputBorder(),

                              ),
                              maxLines: 20,
                              maxLength: 256,
                              validator: (value){
                                if(value.length==0){return '紹介文を入力してください。';}
                                return null;
                              },
                              /*
                        onSaved: (value){
                          profile.introduction=value;
                        },*/
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
          ),
        );
      },
    );
  }
}

/*
Future<File> fixImage(File image) async {
  List<int> imageBytes=await image.readAsBytes();
  int rotationCorrection = 0;
  Map<String, IfdTag> exif = await readExifFromBytes(imageBytes);

  if (exif == null || exif.isEmpty) {
    print("No EXIF information found");
  }
  print("Found EXIF information");
  // http://sylvana.net/jpegcrop/exif_orientation.html
  IfdTag orientation = exif["Image Orientation"];
  int orientationValue = orientation.values[0];
  // in degress
  print("orientation: ${orientation.printable}/${orientation.values[0]}");
  switch (orientationValue) {
    case 6:
      rotationCorrection = 90;
      break;
    case 3:
      rotationCorrection = 180;
      break;
    case 8:
      rotationCorrection = 270;
      break;
    default:
  }
  final originalImage = img.decodeImage(imageBytes);
  img.Image fixedImage;

  fixedImage = img.copyRotate(originalImage, rotationCorrection);
  return  await image.writeAsBytes(img.encodeJpg(fixedImage));
}*/