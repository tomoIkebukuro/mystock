import '../global_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class FavoriteButton extends StatelessWidget{

  final String userId;

  FavoriteButton(this.userId);

  @override
  Widget build(BuildContext context) {
    return Selector<GlobalModel,Object>(
      selector: (context,model)=>model.favoriteMap[userId],
      builder: (context,isChoosed,child){
        if(isChoosed==true){
          return IconButton(
            icon: Icon(Icons.favorite,color: Colors.red,),
            onPressed: (){
              Provider.of<GlobalModel>(context,listen: false).deleteFavorite(userId);
            },
          );
        }
        else{
          return IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: (){
              Provider.of<GlobalModel>(context,listen: false).addFavorite(userId);
            },
          );
        }
      },
    );
  }
}

class RaisedButtonModified extends StatelessWidget{

  final Function onPressed;
  final String text;


  RaisedButtonModified({this.onPressed,this.text});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context)=>RaisedButtonModifiedModel(),
      builder: (context,child){
        return Container(
          margin: EdgeInsets.all(10),
          //width: 60,
          child: RaisedButton(
            child: Text(text,style: TextStyle(fontWeight: FontWeight.bold),),
            textColor: Colors.white,
            padding: EdgeInsets.all(3),
            shape: StadiumBorder(),
            onPressed: context.watch<RaisedButtonModifiedModel>().disabled ? null :() async {
              context.read<RaisedButtonModifiedModel>().disabled=true;
              await onPressed();
              context.read<RaisedButtonModifiedModel>().disabled=false;
            },
          ),
        );
      },
    );
  }
}

class RaisedButtonModifiedModel with ChangeNotifier{
  bool _disabled=false;
  get disabled => _disabled;
  set disabled(value){
    _disabled=value;
    notifyListeners();
  }
}



class NetworkAvatar extends StatelessWidget{

  final String avatarUrl;
  final double size;

  NetworkAvatar({this.size,this.avatarUrl});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.size,
      width: this.size,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: this.avatarUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}

class FileAvatar extends StatelessWidget{

  final File file;
  final double size;

  FileAvatar({this.size,this.file});


  @override
  Widget build(BuildContext context) {
    return Container(
      height: this.size,
      width: this.size,
      child: ClipOval(
        child: Image.file(file),
      ),
    );
  }
}