
import 'dart:collection';
import 'dart:ui';

import 'package:flutter/material.dart';

Color kThemeColor= Colors.deepPurpleAccent;
var kProfileTextStyle = TextStyle(
    color: kThemeColor,
    fontSize: 14
);

var kLabelTextStyle = TextStyle(
    color: Colors.grey,
    fontSize: 10
);

const kInputTextStyle=TextStyle(color: Colors.black);

const kInputOutlineBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(
      Radius.circular(5)
  ),
  borderSide: BorderSide(color:Colors.grey, width: 1.5),
);

const kHintStyle= TextStyle(
    color: Colors.grey,
    fontSize: 10
);

const kNavTextStyle=TextStyle(
    color: Colors.white,
    fontSize: 14
);

const kLinedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(
      Radius.circular(5)
  ),
  borderSide: BorderSide(color:Colors.grey, width: 1.5),
);

const kLinedFocusedBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(
      Radius.circular(5)
  ),
  borderSide: BorderSide(color:Colors.blue, width: 1),
);

enum kSendCode {SENT,SENDING, STARTEDSENDING,FAILED }

HashMap<String, int>? kUserColorMap = HashMap();

List<Color> kNameColors=[Colors.green, Colors.purple, Colors.red, Colors.pink, Colors.brown, Colors.deepOrangeAccent,Colors.cyan];

const kDialogLight = Color(0xFFEFEFFF);

const kNameKey='kNameKey';
const kBioKey='kBioKey';
const kAgeKey='kAgeKey';
const kLinkKey='kLinkKey';
const kMailKey='kMailKey';
const kIdkey='kIdkey';
const kPickey='kPickey';
const kPassKey='kPassKey';