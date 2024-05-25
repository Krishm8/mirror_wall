import 'package:flutter/material.dart';
import 'package:mirror_wall/controller/home_provider.dart';
import 'package:mirror_wall/view/home.dart';
import 'package:provider/provider.dart';

void main(){
  runApp(MyApp());
}





class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => HomeProvider(),),
    ],
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: Provider.of<HomeProvider>(context).theme,
          home: HomePage(),
        );
      },
    );
  }
}
