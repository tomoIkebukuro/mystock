import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:progress_dialog/progress_dialog.dart';
import 'global_model.dart';
import 'load.dart';
import 'pick_avatar.dart';
import 'navigation.dart';

import 'edit_profile.dart';
import 'test.dart';


void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GlobalModel>(
      create: (context)=>GlobalModel(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.green,

          buttonTheme:ButtonThemeData(
            buttonColor: Colors.greenAccent[400],
            disabledColor: Colors.grey,
          )
          //visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TestPage(),
      ),
    );
  }
}

/*
ChangeNotifierProvider<NavigationModel>(
          create: (context)=>NavigationModel(),
          child: NavigationPage(),
        )
 */









/*

class NavigationModel with ChangeNotifier{
  int _currentIndex = 0;
  get currentIndex => _currentIndex;
  set currentIndex(int index) {
    _currentIndex = index;
    // View側に変更を通知
    notifyListeners();
  }
}

class TestPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("GOAL"),
      ),
    );
  }
}

class NavigationPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {

    final allTab=<Widget>[
      ChangeNotifierProvider<TestStreamModelA>(
        create: (context)=>TestStreamModelA("A"),
        child: TestStream(),
      ),
      ChangeNotifierProvider<TestStreamModelB>(
        create: (context)=>TestStreamModelB("B"),
        child: TestStreamB(),
      ),
    ];

    return Selector<NavigationModel,int>(
      selector: (context,model)=>model.currentIndex,
      builder: (context,index,child){
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
          ),
          body: IndexedStack(
            index: index,
            children: allTab,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: index,
            onTap: (index){
              Provider.of<NavigationModel>(context,listen: false).currentIndex=index;
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance),
                title: Text("A"),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.ac_unit),
                title: Text("B"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TestStreamModelA with ChangeNotifier{
  String name;
  TestStreamModelA(this.name);
}

class TestStreamModelB with ChangeNotifier{
  String name;
  TestStreamModelB(this.name);
}

class TestStream extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (context,index){
          return ListTile(
            title: Text(Provider.of<TestStreamModelA>(context,listen: false).name+" "+index.toString()),
          );
        }
    );
  }
}

class TestStreamB extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (context,index){
          return ListTile(
            title: Text(Provider.of<TestStreamModelB>(context,listen: false).name+" "+index.toString()),
          );
        }
    );
  }
}

class LoginPage extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: FlutterLogo(),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Selector<TestModel,String>(
              builder: (context,text,child)=> Text(text),
              selector: (context,model)=> model.user?.uid ,
            ),
            FlatButton(
              child: Text("sign in"),
              onPressed: (){
                Provider.of<TestModel>(context,listen: false)
                    .handleSignIn()
                    .catchError((e) {

                      return showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            content: Text("ログインできませんでした。"),
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
                    });
              },
            ),
            FlatButton(
              child: Text("logout"),
              onPressed: ()async{

                Provider.of<TestModel>(context,listen: false)
                    .logOut()
                    .catchError((e) {
                  print("GHJKLJFGHJ");
                  print(e);
                });
              },
            )
          ],
        ),
      ),
    );
  }
}

class EditProfileModel with ChangeNotifier{
  File _avatar;
  get avatar => _avatar;
  set avatar(value){
    _avatar=value;
    notifyListeners();
  }
}

class EditProfilePage extends StatefulWidget{

  //EditProfilePage({Key key}):super(key:key);

  @override
  EditProfileState createState()=>EditProfileState();
}

class EditProfileState extends State<EditProfilePage>{

  //Formで使う
  final formKey = GlobalKey<FormState>();





  void onSavePressed(Profile myProfile)async{

    //formの内容をチェック
    if(!formKey.currentState.validate()) {
      return ;
    }

    //問題なければ保存
    formKey.currentState.save();

    //プログレスバー表示
    var progressDialog=ProgressDialog(context,type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    progressDialog.style(message: 'アップロード中');
    progressDialog.show();

    String avatarUrl;

    if(api?.user?.uid==null){
      return;
    }

    //アバターが選択されていればアップロード
    if(choosedAvatarSubject.value!=null){
      avatarUrl=await api.uploadImage(
          file: choosedAvatarSubject.value,
          collectionName: 'images',
          fileName: api.user.uid
      );
    }

    //アップロードが成功した場合キャッシュを消す
    //これをしないと画像が変更されない
    //ついでにプロフィールのアバターのurlを変更
    if(avatarUrl!=null){
      PaintingBinding.instance.imageCache.clear();
      myProfile.avatarUrl=avatarUrl;
    }

    //Profileもアップロード
    await Provider.of<Api>(context).uploadProfile(avatar:choosedAvatarSubject.value,profile:myProfile);

    //Provider.of<Api>(context).indexSubject.add(Provider.of<Api>(context).indexSubject.value);

    //プログレスバー非表示
    progressDialog.hide();

    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {

    Map<String,String> profile={};

    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          FlatButton(
            color: Colors.white,
            child: Text('保存'),
            onPressed: () async {
              onSavePressed(profile);
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:<Widget>[
              Container(
                height: 40.0,
                width: 40.0,
                child: Selector<EditProfileModel,File>(
                  selector: (context,model){
                    return model.avatar;
                  },
                  builder: (context,file,child){
                    if(file==null){
                      return ClipOval(child: NetworkImageModified(profile["avatarUrl"]),);
                    }
                    return ClipOval(child: Image.file(file),);
                  },
                ),
              ),
              SizedBox(
                child: IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: () async {
                    File file=await Provider.of<Api>(context).takeFileFromCamera();
                    if(file!=null){
                      choosedAvatarSubject.add(file);
                    }
                  },
                ),
              ),
              Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: '名前　'),
                      maxLength: 32,
                      initialValue: profile["name"],
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
                      keyboardType: TextInputType.multiline,
                      autofocus: false,
                      decoration: InputDecoration(
                        labelText: '紹介文',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 20,
                      maxLength: 256,
                      initialValue: profile["introduction"],
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
      ),
    );


    //アップロード用のProfileを準備
    var myProfile=Provider.of<Api>(context).createMyProfileToEdit();

    Widget initialAvatar=myProfile.avatarUrl.length==0
        ?ClipOval(child: Image.asset('images/flutter_logo.png'),)
        :ClipOval(child: NetworkImageModified(myProfile.avatarUrl),);

    return StreamBuilder<File>(
      stream: choosedAvatarSubject,
      initialData: choosedAvatarSubject.value,
      builder: (context,snapshot){

        if(snapshot.hasError||snapshot.connectionState==ConnectionState.none){
          return ErrorOccurredPage(widgetName: 'EditProfilePage',);
        }

        if(snapshot.connectionState==ConnectionState.waiting){
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            actions: <Widget>[
              FlatButton(
                color: Colors.white,
                child: Text('保存'),
                onPressed: () async {
                  onSavePressed(myProfile);
                },
              )
            ],
          ),
          body: Center(
            child: SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:<Widget>[
                  Container(
                    height: 40.0,
                    width: 40.0,
                    child: snapshot.data==null ?
                    initialAvatar :
                    ClipOval(
                      child: Image.file(snapshot.data),
                    ),
                  ),
                  SizedBox(
                    child: IconButton(
                      icon: Icon(Icons.photo),
                      onPressed: () async {
                        File file=await Provider.of<Api>(context).takeFileFromCamera();
                        if(file!=null){
                          choosedAvatarSubject.add(file);
                        }
                      },
                    ),
                  ),
                  Form(
                    key: formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '名前　'),
                          maxLength: 32,
                          initialValue: '${myProfile.name}',
                          validator: (value){
                            if(value.length==0){
                              return '名前を入力してください。';
                            }
                            return null;
                          },
                          onSaved: (value){
                            myProfile.name=value;
                          },
                          autofocus: false,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: '紹介文',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 20,
                          maxLength: 256,
                          initialValue: '${myProfile.introduction}',
                          validator: (value){
                            if(value.length==0){return '紹介文を入力してください。';}
                            return null;
                          },
                          onSaved: (value){
                            myProfile.introduction=value;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose(){
    choosedAvatarSubject.close();
    super.dispose();
  }
}

class NetworkImageModified extends StatelessWidget{

  final String url;

  NetworkImageModified(this.url);

  Future<bool> cacheImage(String url,BuildContext context) async {
    if(url==null){
      return false;
    }

    bool succeedCaching=true;
    await precacheImage(
      NetworkImage(url),
      context,
      onError: (e,stackTrace)=>succeedCaching=false,
    );
    return succeedCaching;
  }

  @override
  Widget build(context){

    return FutureBuilder(
      future:cacheImage(url, context),
      builder: (context,snapshot){

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

        if(snapshot.data==false || snapshot.hasError){
          return Container(
            height: 80.0,
            decoration: BoxDecoration(
                color: Colors.grey
            ),
            child: Center(
              child: Text('Error',style: TextStyle(fontSize: 10.0),),
            ),
          );
        }
        return Image.network(url);
      },
    );
  }
}


class TestModel with ChangeNotifier{

  FirebaseUser user;
  GoogleSignIn googleSignIn=GoogleSignIn();

  Future<void> handleSignIn() async {
    var googleUser=await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseUser _user = (await FirebaseAuth.instance.signInWithCredential(credential)).user;
    if(_user!=null){
      user=_user;
      notifyListeners();
    }
  }

  Future<void> logOut()async{
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
  }

}
*/