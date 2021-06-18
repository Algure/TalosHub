import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utitlities/constants.dart';
import 'package:talos_hub/data_objects/message_object.dart';
import 'package:talos_hub/providers/chat_upload_provider.dart';
import 'package:url_launcher/url_launcher.dart';


class ChatTextWidget extends StatelessWidget {
  bool progress=false;
  bool shouldAutoDownloadImage=true;
  bool shouldUpload;
  bool initiateFlash=false;
  int? colorChoice=0;
  String userId;
  String mediaPath='';
  String timeText='';
  String senderName='';
  Function onChatSelected;
  Function onChatSent;
  Function onChatNotSent;
  kSendCode messageSent;
  MessageObject messageObject;
  Widget? auxWidget;
  Widget mediaImage=Container(height: 0,);

  ChatTextWidget({required this.messageObject, required this.userId,  this.shouldUpload=false,
    this.messageSent=kSendCode.SENT, required this.onChatNotSent, required this.onChatSent, required this.onChatSelected});

  @override
  void initState() {
    resolveNameTimeDisplay();
    resolveSenderNameColor();
  }
  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        onHorizontalDragEnd: (_){
          if(onChatSelected != null)onChatSelected.call();
        },
        child: Container(
          constraints: BoxConstraints(
            minHeight: 100,
          ),
          child: Column(
              crossAxisAlignment: userId=='user'?CrossAxisAlignment.end: CrossAxisAlignment.start,
              children:[
                Container(
                    decoration: BoxDecoration(
                        color:  initiateFlash?Colors.blue:(userId=='user'?kThemeColor:Colors.grey.shade100),
                        borderRadius:userId=='user'?
                        BorderRadius.only(topLeft: Radius.circular(25), topRight:Radius.circular(25), bottomLeft: Radius.circular(25)):
                        BorderRadius.only(topRight: Radius.circular(25), bottomLeft:Radius.circular(25), bottomRight:Radius.circular(25),)
                    ),
                    padding: EdgeInsets.all(15),
                    child:Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: userId!='user'?12:0,
                              child: Text(userId!='user'?senderName:'', style: TextStyle(color: kNameColors[colorChoice!],
                                  fontSize: 10, fontWeight: FontWeight.bold), )),
                          SizedBox(height: userId!=messageObject.userId?12:0,),
                          SelectableLinkify(text:messageObject.chat_text,
                            options: LinkifyOptions(humanize: false),
                            linkStyle: TextStyle(color: Colors.blue),
                            onOpen: (link) async {
                              if (await canLaunch(link.url)) {
                                await launch(link.url);
                              } else {

                              }
                            },
                            style: TextStyle(color: userId=='user'?Colors.white:kThemeColor, fontSize: 16),),
                          if(messageObject.userId=='user')Padding(
                              padding: const EdgeInsets.only(top:15.0),
                              child: Text(Provider.of<ChatUploadProvider>(context).kSendStatMap![messageObject.id]==kSendCode.SENT?
                              (userId==messageObject.userId?timeText+'✔':timeText):
                              ((Provider.of<ChatUploadProvider>(context).kSendStatMap![messageObject.id]==kSendCode.FAILED)?
                              '$timeText ❌':
                              (!Provider.of<ChatUploadProvider>(context).kSendStatMap!.containsKey(messageObject.id))? '':'Sending... ⏱'),
                                textAlign: TextAlign.center, style: kHintStyle,
                              ))
                        ]
                    )
                ),
              ]
          ),
        ),
      );
  }


  void resolveNameTimeDisplay() {

    if (messageObject.userFullName.contains('<')) {
      List<String> splits = messageObject.userFullName.split('<');
      timeText = splits[1];
      senderName = splits[0];
    } else {
      senderName = messageObject.userFullName;
    }
  }

  void resolveSenderNameColor(){
    if(kUserColorMap!.containsKey(messageObject.userId))
      colorChoice=kUserColorMap![messageObject.userId];
    else{
      colorChoice = Random().nextInt(kNameColors.length);
      kUserColorMap![messageObject.userId]=colorChoice!;
    }
  }
}


