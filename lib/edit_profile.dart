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

class EditProfileModel with ChangeNotifier{

  //nextAvatarは次に設定するアバター
  //新しく写真を撮るなどしてアバターを変更すると代入される
  //nullの場合はアバターが変更されていないことを示す
  File _nextAvatar;
  get nextAvatar => _nextAvatar;
  set nextAvatar(value){
    _nextAvatar=value;
    notifyListeners();
  }


  bool _wasSaveButtonPressed=false;
  get wasSaveButtonPressed => _wasSaveButtonPressed;
  set wasSaveButtonPressed(value){
    _wasSaveButtonPressed=value;
    notifyListeners();
  }

  bool _wasCameraButtonPressed=false;
  get wasCameraButtonPressed => _wasCameraButtonPressed;
  set wasCameraButtonPressed(value){
    _wasCameraButtonPressed=value;
    notifyListeners();
  }

  bool _wasGalleryButtonPressed=false;
  get wasGalleryButtonPressed => _wasGalleryButtonPressed;
  set wasGalleryButtonPressed(value){
    _wasGalleryButtonPressed=value;
    notifyListeners();
  }
}

class EditProfilePage extends StatefulWidget{

  EditProfilePage({Key key}):super(key:key);

  @override
  EditProfileState createState()=>EditProfileState();
}

class EditProfileState extends State<EditProfilePage>{

  //Map<String,Object> nextProfile;
  TextEditingController nameController=TextEditingController();
  TextEditingController introductionController=TextEditingController();
  //String defaultAvatarUrl;

  //Formで使う
  final formKey = GlobalKey<FormState>();
  Map<String,Object> profile;

  bool isInitialized=false;

  void initialize(BuildContext context){
    if(!isInitialized){
      profile??={...context.select<GlobalModel,Map<String,Object>>((model)=>model.myProfile)};
      nameController.text=profile["name"];
      introductionController.text=profile["introduction"];
    }
  }

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
    context.read<EditProfileModel>().wasCameraButtonPressed=true;
    try{
      context.read<EditProfileModel>().nextAvatar=await cropAvatar(await pickFileFromCamera());
    }catch(e){
      showErrorDialog(context, e.toString());
    }
    context.read<EditProfileModel>().wasCameraButtonPressed=false;
    return null;
  }

  Future<Null> onGalleryButtonPressed(BuildContext context)async{
    context.read<EditProfileModel>().wasGalleryButtonPressed=true;
    try{
      context.read<EditProfileModel>().nextAvatar=await cropAvatar(await pickFileFromGallery());
    }catch(e){
      showErrorDialog(context, e.toString());
    }
    context.read<EditProfileModel>().wasGalleryButtonPressed=false;
    return null;
  }

  @override
  Widget build(BuildContext context) {

    initialize(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.green
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          Container(
            margin: EdgeInsets.all(10),
            width: 60,
            child: Selector<EditProfileModel,bool>(
              selector: (context,model)=>model.wasSaveButtonPressed,
              builder: (context,isPressed,child){
                return RaisedButton(
                  child: Text('保存',style: TextStyle(fontWeight: FontWeight.bold),),
                  textColor: Colors.white,
                  padding: EdgeInsets.all(3),
                  shape: StadiumBorder(),
                  onPressed: isPressed ? null :() async {

                    context.read<EditProfileModel>().wasSaveButtonPressed=true;

                    //formの内容をチェック
                    if(!formKey.currentState.validate()) {
                      return ;
                    }

                    //model.nextProfileに保存される
                    formKey.currentState.save();

                    try{
                      await updateMyProfile(
                          context,
                          profile,
                          context.read<EditProfileModel>().nextAvatar
                      );
                    }catch(e){
                      showErrorDialog(context, "");
                      return ;
                    }

                    Navigator.of(context).pop();
                  },
                );
              },
            ),
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
                      child: Selector<EditProfileModel,bool>(
                        selector: (context,model)=>model.wasCameraButtonPressed,
                        builder: (context,wasPressed,child){
                          return FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.greenAccent[400],
                            child: Icon(Icons.camera_alt,),
                            onPressed: wasPressed ? null : ()async{
                              await onCameraButtonPressed(context);
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      height: 100,
                      width: 100,
                      child: ClipOval(
                        child: Selector<EditProfileModel,File>(
                          selector: (context,model)=>model.nextAvatar,
                          builder: (context,file,child){
                            if(file==null){
                              return ImageNetworkExtended(profile["avatarUrl"]);
                            }
                            return Image.file(file);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Selector<EditProfileModel,bool>(
                        selector: (context,model)=>model.wasGalleryButtonPressed,
                        builder: (context,wasPressed,child){
                          return FloatingActionButton(
                            mini: true,
                            backgroundColor: Colors.greenAccent[400],
                            child: Icon(Icons.image,),
                            onPressed: wasPressed ? null : ()async{
                              await onGalleryButtonPressed(context);
                            },
                          );
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
                        controller: nameController,
                        validator: (value){
                          if(value.length==0){
                            return '名前を入力してください。';
                          }
                          return null;
                        },
                        onSaved: (value){
                          profile["name"]=value;
                        },
                        autofocus: false,
                      ),
                      TextFormField(
                        controller: introductionController,
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
                        onSaved: (value){
                          profile["introduction"]=value;
                        },
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