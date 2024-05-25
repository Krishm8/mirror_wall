import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier{
  bool isLoad=true;
  double webProgress=0;
  String searchengine="https://www.google.com/";
  ThemeMode theme=ThemeMode.light;

  List bookmarklist=[];

  void onChangeLoad(bool isLoad){
    this.isLoad=isLoad;
    notifyListeners();
  }
  void onWebProgress(double webProgress){
    this.webProgress=webProgress;
    notifyListeners();
  }

  void changeweb(value){
    searchengine=value;
    notifyListeners();
  }


  void changetheme(){
    if(theme==ThemeMode.light){
      theme=ThemeMode.dark;
    }
    else if(theme==ThemeMode.dark){
      theme=ThemeMode.light;
    }
    notifyListeners();
  }
}