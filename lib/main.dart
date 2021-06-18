import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'utitlities/statics.dart';
import 'package:talos_hub/providers/chat_upload_provider.dart';
import 'package:talos_hub/screens/home_screen.dart';

void main() {
  kUserColorMap= HashMap();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context)=> ChatUploadProvider()),
      ],
      child: OverlaySupport(
        child: MaterialApp(
          title: '',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: kThemeColor
          ),
          home: MyHomePage(title: 'Flutter Demo Home Page'),
        ),
      ),
    );
  }
}


