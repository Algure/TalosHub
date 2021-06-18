import 'package:flutter/material.dart';
import '../utitlities/azure_client.dart';
import '../utitlities/statics.dart';
import 'add_bot_screen.dart';
import 'package:talos_hub/custom_widgets/ai_list_item.dart';
import 'package:talos_hub/custom_widgets/change_name_dialog_widget.dart';
import 'package:talos_hub/custom_widgets/my_button.dart';
import 'package:talos_hub/data_objects/ai_object.dart';
import '../utitlities/utility_functions.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {


  String email = '';
  String userName = 'No Name';
  bool progress=false;
  final double spaceHeight = 16;
  List<Widget> userAiList = [];

  @override
  void didChangeDependencies() {
    setUserDets();
    reloadUserAi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kThemeColor),
        title: Text("", style: TextStyle(color: Colors.white),),),
      body: SafeArea(
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                TextButton(
                  onPressed: showEditProfileDialog,
                  child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text('$userName', textAlign: TextAlign.start ,style:TextStyle(color: kThemeColor.withOpacity(0.5), fontWeight: FontWeight.w900, fontSize: 35), )),
                ),
                SizedBox(height: 30,),
                Container(alignment: Alignment.centerLeft, child: Text('$email', style: kNavTextStyle.copyWith(color: kThemeColor.withOpacity(0.5), fontSize: 10),)),
                  SizedBox(height: spaceHeight,),
                  SizedBox(height: spaceHeight,),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 600,
                    ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only (topLeft:Radius.circular(30), topRight:Radius.circular(30)),
                        color: Colors.white,
                      ),
                      padding: EdgeInsets.only(bottom: 100, top: 16),
                      child:   Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children:[
                            MyButton(buttonColor: kThemeColor, text: 'Add AI', textColor: Colors.white, onPressed: addAI),
                            if(progress)Container(height: 50, alignment: Alignment.center,child: CircularProgressIndicator(color: kThemeColor,)),
                            for(Widget item in userAiList) item,
                          ]
                      )
                  ),
                ],
              ),
          ),
          ),
      ),
      );
  }

  addAI() async {
    if(!(await uCheckInternet())){
      uShowErrorNotification('No internet connection !');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=> AddChatBotDetails(reloadUserAi)));
  }

  showEditProfileDialog() async {
    if(!(await uCheckInternet())){
      uShowErrorNotification('No internet connection !');
      return;
    }
    Dialog dialog= Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: kDialogLight,
      child: ChangeNameDialogWidget(setUserDets)
    );
    showGeneralDialog(
      context: context,
      barrierLabel: 'text',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(dialog)
    );
  }

  openAI(AiObject object) async {
    if(!(await uCheckInternet())){
      uShowErrorNotification('No internet connection !');
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=> AddChatBotDetails(reloadUserAi,aiObject: object)));
  }

  void showProgress(bool b){
    setState((){
     progress=b;
    });
  }

  Future<void> setUserDets() async {
    email =  await uGetSharedPrefValue(kMailKey);
    userName = await uGetSharedPrefValue(kNameKey);
    if(userName==null || userName.toString()=='null'|| userName.toString().trim().isEmpty) userName='No Name';
    setState(() {

    });
  }

  reloadUserAi() async {
    showProgress(true);
    userAiList=[];
    List<AiObject?> userAiObjectList = await AzureClient().fetchUserAi(await uGetSharedPrefValue(kMailKey));
    for(AiObject? ai in userAiObjectList) userAiList.add(AiLitem(ai!, (){openAI(ai);}));
    showProgress(false);
  }
}
