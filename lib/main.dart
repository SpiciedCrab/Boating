import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ocean_clock/scene.dart';

class OceanTheme {
  static ThemeData buildTheme() {
    return ThemeData(
        fontFamily: 'HanaleiFill-Regular',
        textTheme: TextTheme(
          title: TextStyle(
            fontSize: 90,
            color: Colors.white,
          ),
          subtitle: TextStyle(
            fontSize: 40,
            color: Colors.white.withOpacity(0.5),
          ),
        )
    );
  }
}

void main(){
  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight])
      .then((_) {
    runApp(new MyApp());
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: OceanTheme.buildTheme(),
      home: Scence(),
    );
  }
}