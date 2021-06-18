import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utitlities/statics.dart';
import 'package:talos_hub/custom_widgets/chat_box.dart';
import 'package:talos_hub/data_objects/message_object.dart';
import 'package:talos_hub/data_objects/profile.dart';
import '../utitlities/utility_functions.dart';

class ChatUploadProvider extends ChangeNotifier{
   Map<String, kSendCode>? kSendStatMap;
    Map<String, MessageObject>? chatMap;
    List<ChatTextWidget> messageList=[];
   String baseUrl='https://talostest.azurewebsites.net/qnamaker/knowledgebases/cf7643d7-dc2a-401a-9e61-924e1ab3edae/generateAnswer';
   String searchKey='1c997cc6-263c-4897-88d5-ca8a89aeb9f7';//'EndpointKey 1c997cc6-263c-4897-88d5-ca8a89aeb9f7';

  Future<void> sendMessage ({required MessageObject messageObject, robotName='robot'}) async{

    String id= messageObject.id;
    try {
      if(kSendStatMap!.containsKey(id)){
        if(kSendStatMap![id]==kSendCode.SENT|| kSendStatMap![id]==kSendCode.SENDING){
          notifyListeners();
          return;
        }
      }
      kSendStatMap![id]=kSendCode.STARTEDSENDING;
      chatMap![messageObject.id]= messageObject;
      messageList.insert(0,
          ChatTextWidget(messageObject: messageObject, userId: messageObject.userId, onChatNotSent: (){}, onChatSent: (){},
              onChatSelected: (){closeChatIfNotSent(messageObject.id);}));
      notifyListeners();

      Response response = await post(Uri.parse(baseUrl),body: '{"question":"${messageObject.chat_text}"}',
          headers:
          {'Content-Type': 'application/json',
            'Authorization': searchKey});

      if (response.statusCode>=200 && response.statusCode<300) {
        kSendStatMap![id] = kSendCode.SENT;
        kSendStatMap![id] = kSendCode.SENT;
        String result= jsonDecode(response.body.toString())['answers'][0]['answer'];
        String newId = uGenerateRandomId();
        MessageObject? messageObject2= MessageObject()
        ..id = newId
        ..userId = 'robot'
        ..chat_text=result
        ..userFullName=robotName;

        chatMap![messageObject2.id]= messageObject2;
        kSendStatMap![messageObject2.id]=kSendCode.SENT;
        messageList.insert(0, ChatTextWidget(messageObject: messageObject2, userId: messageObject2.userId, onChatNotSent: (){}, onChatSent: (){}, onChatSelected: (){}));

      } else {
        kSendStatMap![id] = kSendCode.FAILED;
        kSendStatMap![id] = kSendCode.FAILED;
      }
    }catch(e,t ){
      kSendStatMap![id]=kSendCode.FAILED;
    }
    notifyListeners();
  }

   closeChatIfNotSent(String id) {
    if( kSendStatMap!.containsKey(id) && kSendStatMap![id]!=kSendCode.FAILED) return;
    chatMap!.remove(id);
    kSendStatMap!.remove(id);
    notifyListeners();
  }
}