import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utitlities/statics.dart';
import 'package:talos_hub/custom_widgets/chat_box.dart';
import 'package:talos_hub/data_objects/ai_object.dart';
import 'package:talos_hub/data_objects/message_object.dart';
import 'package:talos_hub/providers/chat_upload_provider.dart';
import '../utitlities/utility_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {

  ChatScreen( this.aiObject);

  AiObject aiObject;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  double bottomPadding=15;

  String messageText='';
  String robotName='';

  TextEditingController? messageTextController;

  List<Widget> messagesList = [];

  FocusNode? textNode;

  bool isSending=false;

  bool shouldShowDev= false;


  @override
  void initState() {
    textNode = FocusNode();
    messageTextController=TextEditingController(text: messageText);
    robotName= widget.aiObject.aiName;
    Provider.of<ChatUploadProvider>(context, listen: false).messageList = [];
    Provider.of<ChatUploadProvider>(context, listen: false).chatMap = HashMap();
    Provider.of<ChatUploadProvider>(context, listen: false).kSendStatMap = HashMap();
    Provider.of<ChatUploadProvider>(context, listen: false).baseUrl = widget.aiObject.link.replaceAll(' ', '');
    Provider.of<ChatUploadProvider>(context, listen: false).searchKey = widget.aiObject.aiKey;
  }

  @override
  void didChangeDependencies() {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kThemeColor),
        title: Text("", style: TextStyle(color: Colors.white),),),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(
            maxWidth: 500
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Hero(
                tag: widget.aiObject.id ,
                child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text('${widget.aiObject.aiName}', textAlign: TextAlign.start ,
                      style:TextStyle(color: kThemeColor.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 20), )),
              ),
              Container(alignment: Alignment.centerLeft, child: Text('${widget.aiObject.aiDescription}',
                style: kNavTextStyle.copyWith(color: kThemeColor, fontSize: 10),)),
              Container(
                alignment: Alignment.bottomRight,
                child: shouldShowDev?  Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children:[
                    Container(alignment: Alignment.centerRight, child: Text('Dev. ${widget.aiObject.creatorName.toString().trim()!='null'?widget.aiObject.creatorName.toString().trim():''}',
                    style: kNavTextStyle.copyWith(color: Colors.grey.withOpacity(0.5), fontSize: 10),)),
                    SizedBox(width: 10,),
                    Container(alignment: Alignment.centerRight, child: SelectableText(' ${widget.aiObject.creatorDetails}',
                    style: kNavTextStyle.copyWith(color: Colors.blueGrey.withOpacity(0.5), fontSize: 10),)),
                    MaterialButton(onPressed: (){
                      setState(() {
                        shouldShowDev=false;
                      });
                    }, child: Icon(CupertinoIcons.ellipsis, color: Colors.grey,),),
                  ]
                ): MaterialButton(onPressed: (){
                  setState(() {
                    shouldShowDev=true;
                  });
                }, child: Icon(CupertinoIcons.ellipsis, color: Colors.grey,),),
              ),
              Container(height: 0.5, width: double.maxFinite, margin: EdgeInsets.all(1), color: kThemeColor,),
              Expanded(
                child: ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                    itemCount: Provider.of<ChatUploadProvider>(context).messageList!.length,
                    itemBuilder: (context , index){
                      return  Provider.of<ChatUploadProvider>(context, listen: false).messageList![index];
                    }),
              ),
              Container(
                decoration: BoxDecoration(color: Color(0XFFEEEEEE),
                    borderRadius: BorderRadius.circular(30)),
                margin: EdgeInsets.only(left: 6, bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 150),
                        child: TextField(
                          focusNode: textNode,
                          controller: messageTextController,
                          onChanged: (value){
                            messageText=value;
                          },
                          autofocus: false,
                          textInputAction: TextInputAction.newline,
                          maxLines: null,
                          minLines: null,
                          decoration: InputDecoration(
                              hintText: 'Enter message',
                              hintStyle: kHintStyle,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none
                              )
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding:  EdgeInsets.only(left:13.0, right:13.0 , bottom: bottomPadding),
                      child: GestureDetector(
                        child: Icon(Icons.send, color: kThemeColor),
                        onTap: (){
                          sendMessage();
                        },
                      ),
                    ),
                  ],
                ),

              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    MessageObject messageObject = MessageObject()
    ..id = uGenerateRandomId()
    ..userId = 'user'
    ..userFullName = 'nothing'
    ..chat_text= messageText;
    if(!(await uCheckInternet())){
      uShowMessageSentNotification();
      uShowErrorNotification('No internet connection detected.');
      return;
    }
    messageText='';
    setState(() {
      messageTextController!.clear();
    });
    await Provider.of<ChatUploadProvider>(context, listen: false).sendMessage(messageObject: messageObject, robotName: robotName);
  }

  void setSending(bool b){
    setState(() {
      isSending=b;
    });
  }

}
