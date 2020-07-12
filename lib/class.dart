class Profile{
  //final Map<String,String> data;
  String name;
  String introduction;
  String userId;
  List<String> predictions;
  String avatarUrl;

  Profile(data){
    print(data["id"]);
    name=data["name"];
    introduction=data["introduction"];
    userId=data["id"];
    predictions=data["predictions"].split(" ");
    avatarUrl=data["avatarUrl"];
  }

  Map<String,dynamic> toData(){
    Map<String,dynamic> data={};
    data["name"]=this.name;
    data["introduction"]=this.introduction;
    data["id"]=this.userId;
    data["predictions"]=this.predictions.join(" ");
    data["avatarUrl"]=this.avatarUrl;
    return data;
  }

  static Profile getInitialProfile(String userId){
    return Profile({
      "name":"",
      "introduction":"",
      "id":userId,
      "predictions":"",
      "avatarUrl":"https://cdn4.iconfinder.com/data/icons/logos-brands-5/24/flutter-512.png",

    });
  }

  Profile clone(){
    return Profile(this.toData());

  }
}
