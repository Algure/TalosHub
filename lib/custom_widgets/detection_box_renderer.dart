import 'dart:collection';

import 'package:flutter/material.dart';

class DetectionBoxPainter extends CustomPainter {

  Function(Map<String, Color>) onBoxesRendered;
  var boxObjects;
  Map<String, Color> objectColorMap = HashMap();
  List<Color> colorList =[
    Color(0xFFFFAAAA),
    Color(0xFF0000FF),
    Color(0xFFFF0000),
    Color(0xFFFF00AA),
    Color(0xFF00AAFF),
    Color(0xFF00FF00),
    Color(0xFFFF7700),
    Color(0xFFFF5555),
    Color(0xFF55FFAA),
    Color(0xFFDD66FF),
    Color(0xFF9922FF),
    Colors.brown,
    Colors.amber,
    Colors.teal,
    Colors.green,
    Colors.blue,
    Colors.red,
    Colors.deepOrangeAccent,
    Colors.pink
  ];

  DetectionBoxPainter(this.boxObjects, {required this.onBoxesRendered});

  @override
  void paint(Canvas canvas, Size size) {
    var paint ;
    var path ;
    String tag = '';
    double startX, startY, endX, endY;
    for(var imBox in boxObjects){
      tag = imBox['tagName'];
      if(!objectColorMap.containsKey(tag)){
        objectColorMap[tag] = colorList[0];
        colorList.removeAt(0);
      }
      paint = Paint();
      paint.color = objectColorMap[tag]!;
      paint.style = PaintingStyle.stroke;
      path = Path();
      startX = imBox['boundingBox']['left'] * size.width;
      startY = imBox['boundingBox']['top'] * size.height;
      endX = (imBox['boundingBox']['width']) * size.width;
      endY = (imBox['boundingBox']['height']) * size.height;
      Rect rect = Rect.fromLTWH(startX, startY, endX, endY);
      path.addRect(rect);
      canvas.drawPath(path, paint);
    }
    onBoxesRendered(objectColorMap);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}