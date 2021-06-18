import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utitlities/azure_client.dart';
import '../utitlities/constants.dart';
import 'package:talos_hub/custom_widgets/my_button.dart';
import 'package:talos_hub/data_objects/ai_object.dart';
import '../utitlities/utility_functions.dart';

class AddChatBotDetails extends StatefulWidget {
  AddChatBotDetails(this.onUploadComplete, {this.aiObject});

  Function onUploadComplete;
  AiObject? aiObject;

  @override
  _AddChatBotDetailsState createState() => _AddChatBotDetailsState();
}

class _AddChatBotDetailsState extends State<AddChatBotDetails > {
  GlobalKey _dropdownButtonKey = GlobalKey(debugLabel: 'GlobalDropdownCategoryKey');

  String aiName = '';
  String aiLink = '';
  String aiDescription = '';
  String authorisationKey='';
  String host = '';
  String postlink = '';
  String id= '';
  String category= '';
  String label= 'AI Details';
  bool progress=false;
  bool canDelete= false;

  List<DropdownMenuItem<String>> aiCategoryList=[
    DropdownMenuItem<String>(child: Text( 'Chatbot', overflow: TextOverflow.ellipsis,), value: 'bots') ,
    DropdownMenuItem<String>(child: Text( 'Computer Vision', overflow: TextOverflow.ellipsis,), value: 'vision') ,
  ];

  @override
  void initState() {
    category = aiCategoryList[0].value!;
    if(widget.aiObject!=null && widget.aiObject!.category != 'vision'){
      initChatbot();
    }else if( widget.aiObject!=null && widget.aiObject!.category == 'vision') {
      initVision();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            constraints: BoxConstraints(
              maxWidth: 500
            ),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 10,),
                    Row(
                      children:[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.arrow_back, color: kThemeColor, size:  20, ))),
                        Spacer(),
                        if(canDelete)Container(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                              onPressed: (){
                                showConfirmDeleteDialog();
                              },
                              child: Icon(Icons.clear, color: kThemeColor, size:  20, ))),
                        ]
                    ),
                    Padding(padding: EdgeInsets.all(8),
                      child: Text(label,
                        textAlign:TextAlign.center, style: TextStyle(color: kThemeColor, fontSize: 18, fontWeight: FontWeight.bold),),
                    ),
                    Image.asset(category=='vision'? 'images/vision.png' :'images/bot.jpg', height: 100, width: 100,),
                    // Icon(CupertinoIcons.shopping_cart, color: kThemeOrange, size:  150,),
                    if(!canDelete)  Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 1.5 ),
                        borderRadius: BorderRadius.all(
                            Radius.circular(5)
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton <String>(
                              key:  _dropdownButtonKey,
                              isDense: true,
                              icon: Icon(Icons.filter_list_sharp, color: kThemeColor, size: 24,),
                              style: TextStyle(color: Colors.black),
                              items: aiCategoryList,
                              value: category,
                              onChanged: (value){
                                category=value!;
                                showProgress(false);
                              }),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child:  TextField(
                          controller: TextEditingController(text: aiName),
                          style: kInputTextStyle,
                          textAlign: TextAlign.start,
                          maxLength: 30,
                          onChanged: (value){
                            aiName=value;
                            // print('ai name $aiName');
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(30)
                          ],
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'Name of AI' ,
                            labelStyle: kHintStyle,
                            errorStyle: kHintStyle.apply(color: Colors.red),
                            hintStyle: kHintStyle,
                            border: kInputOutlineBorder,
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child:  TextField(
                          controller: TextEditingController(text: aiDescription),
                          style: kInputTextStyle,
                          textAlign: TextAlign.start,
                          maxLength: 100,
                          onChanged: (value){
                            aiDescription=value;
                            // print('ai desc $aiDescription');
                          },
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(100)
                          ],
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          maxLines: 2,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'AI description.' ,
                            labelStyle: kHintStyle,
                            errorStyle: kHintStyle.apply(color: Colors.red),
                            hintStyle: kHintStyle,
                            border: kInputOutlineBorder,
                          )
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(8),
                      child: Text('Azure Details',
                        textAlign:TextAlign.center, style: TextStyle(color: kThemeColor, fontSize: 12),),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child:  TextField(
                          controller: TextEditingController(text: host),
                          style: kInputTextStyle,
                          textAlign: TextAlign.start,
                          onChanged: (value){
                            host=value;
                            // print('ai host $host');
                          },
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: kHintStyle,
                            labelText: 'Endpoint: "http://tal...."' ,
                            errorStyle: kHintStyle.apply(color: Colors.red),
                            hintStyle: kHintStyle,
                            border: kInputOutlineBorder,
                          )
                      ),
                    ),
                  if(category != 'vision')  Padding(
                      padding: EdgeInsets.all(4.0),
                      child:  TextField(
                          controller: TextEditingController(text: postlink),
                          style: kInputTextStyle,
                          textAlign: TextAlign.start,
                          onChanged: (value){
                            postlink=value;
                            // print('ai postlink $postlink');
                          },
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle: kHintStyle,
                            labelText: 'Link: "/knowledgebases/cf7643d...generateAnswer"' ,
                            errorStyle: kHintStyle.apply(color: Colors.red),
                            hintStyle: kHintStyle,
                            border: kInputOutlineBorder,
                          )
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(4.0),
                      child:  TextField(
                          controller: TextEditingController(text: authorisationKey),
                          style: kInputTextStyle,
                          textAlign: TextAlign.start,
                          onChanged: (value){
                            authorisationKey=value;
                            // print('Authorization $authorisationKey');
                          },
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            labelText: 'EndpointKey : "1c997cc6-26...."' ,
                            labelStyle: kHintStyle,
                            errorStyle: kHintStyle.apply(color: Colors.red),
                            hintStyle: kHintStyle,
                            border: kInputOutlineBorder,
                          )
                      ),
                    ),

                    SizedBox(height: 30, width: 30, child: progress? LinearProgressIndicator(color: kThemeColor,):Container(),),
                    MyButton(buttonColor: kThemeColor, text: 'Upload', textColor: Colors.white, onPressed: uploadBot),
                    SizedBox(height: 30,)
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }

  void initChatbot(){
    id=widget.aiObject!.id;
    label='Update AI';
    aiName=widget.aiObject!.aiName;
    aiDescription=widget.aiObject!.aiDescription;
    authorisationKey=decryptAuthKey(widget.aiObject!.aiKey);
    widget.aiObject!.link=widget.aiObject!.link.trim().replaceAll(' ', '');
    category = widget.aiObject!.category;
    int midDix=widget.aiObject!.link.indexOf('knowledgebase')-1;
    host=widget.aiObject!.link.substring(0,midDix);
    postlink=widget.aiObject!.link.substring(midDix);
    canDelete=true;
  }

  void showProgress(bool b){
    setState(() {
      progress=b;
    });
  }

  Future<void> uploadBot() async {
    try {
      if (aiName
          .trim()
          .isEmpty) {
        uShowErrorNotification('You AI needs a name !');
        return;
      }

      host = host.trim();
      if (host.isEmpty) {
        uShowErrorNotification('Invalid Endpoint entered !');
        return;
      } else if (!host.startsWith('https')) {
        uShowErrorNotification('Invalid Endpoint entered !');
        return;
      }

      if(category == 'bots') {
        postlink = postlink.trim();
        if (postlink.isEmpty) {
          uShowErrorNotification('Invalid link entered entered !');
          return;
        } else
        if (!postlink.endsWith('generateAnswer') || !postlink.startsWith('/')) {
          uShowErrorNotification('Invalid link entered entered ! ');
          return;
        }
        aiLink = host + postlink;
      }else{
        aiLink = host;
      }
      authorisationKey = authorisationKey.trim();
      if (authorisationKey.isEmpty) {
        uShowErrorNotification('Invalid authorization key');
        return;
      }
      if(!(await uCheckInternet())){
        uShowErrorNotification('No internet');
        return;
      }
      showProgress(true);
      AiObject aiObject = AiObject()
        ..aiDescription = aiDescription
        ..aiName = aiName
        ..id = await getId()
        ..category= category
        ..link = aiLink
        ..creatorName = await uGetSharedPrefValue(kNameKey)
        ..creatorDetails = await uGetSharedPrefValue(kMailKey)
        ..aiKey = encryptAuth(authorisationKey);

      await AzureClient().uploadAI(aiObject);
      uShowOkNotification('AI saved');
      await widget.onUploadComplete.call();
      showProgress(false);
      Navigator.pop(context);
    }catch(e){
      uShowErrorNotification('An error occured');
    }
  }

  showConfirmDeleteDialog(){
     uShowCustomDialog(context: context, icon: Icons.delete_forever_outlined, iconColor: Colors.red,
         text: 'Confirm. This AI would be permanently deleted',
         buttonList: [['Confirm', Colors.red, (){ Navigator.pop(context); deleteBot();}]]);
  }

  Future<void> deleteBot() async {
    if(!(await uCheckInternet())){
      uShowErrorNotification('No internet');
      return;
    }
    try {
      showProgress(true);
      await AzureClient().deleteAi(
          widget.aiObject!.id, await uGetSharedPrefValue(kIdkey));
      await widget.onUploadComplete.call();
      uShowOkNotification('Bot deleted');
      showProgress(false);
      Navigator.pop(context);
    }catch(e, t){
      print('error: $e, trace: $t');
      showProgress(false);
      uShowErrorNotification('An error occured');
    }
  }

  String encryptAuth(String authorisationKey) {
    return authorisationKey;
  }

  String decryptAuthKey(String aiKey) {
    return aiKey;
  }

  Future<String> getId() async{
    if(id!=null && id.trim().isNotEmpty && id.trim()!='null') return id;
    return (await uGetSharedPrefValue(kIdkey)) + uGenerateRandomId();
  }

  void initVision() {
    id=widget.aiObject!.id;
    label='Update AI';
    aiName=widget.aiObject!.aiName;
    aiDescription=widget.aiObject!.aiDescription;
    authorisationKey=decryptAuthKey(widget.aiObject!.aiKey);
    widget.aiObject!.link=widget.aiObject!.link.trim().replaceAll(' ', '');
    category = widget.aiObject!.category;
    host=widget.aiObject!.link;
    canDelete=true;
  }

}
