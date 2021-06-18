import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:talos_hub/screens/vision_screen.dart';
import '../utitlities/statics.dart';
import 'package:talos_hub/data_objects/ai_object.dart';
import 'package:talos_hub/screens/chat_screen.dart';

class AiLitem extends StatelessWidget {

  AiLitem(this.aiObject,[ this.onTap]);
  AiObject aiObject;
  Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          elevation: 15,
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(20)),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all( Radius.circular(15))
            ),
            height: 100,
            child: GestureDetector(
              onTap: onTap ?? (){
               aiObject.category=='vision'? Navigator.push(context, MaterialPageRoute(builder: (context)=>VisionScreen(aiObject))) :Navigator.push(context, MaterialPageRoute(builder: (context)=>ChatScreen(aiObject)));
              },
              child: ListTile(
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image:AssetImage(aiObject.category=='vision'?'images/vision.png':'images/bot.jpg'),
                          fit: BoxFit.fill)
                  ),
                ),
                contentPadding: EdgeInsets.all(5),
                hoverColor: Colors.blueGrey,
                tileColor: Colors.white,
                title: Hero(
                    tag:aiObject.id ,
                    child: Text(aiObject.aiName??'', style: kNavTextStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold),)),
                subtitle: Container(
                  height: double.maxFinite,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(aiObject.aiDescription??'', overflow: TextOverflow.ellipsis, style: kNavTextStyle.copyWith(color: Colors.grey),),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }



}
