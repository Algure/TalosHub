
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'package:uuid/uuid.dart';


void uShowOkNotification(String text){
  showSimpleNotification(
      Text(text, style: kNavTextStyle,),
      background: Colors.green);
}

void uShowErrorNotification(String text){
  showSimpleNotification(
      Text(text, style: kNavTextStyle,),
      leading:Icon(Icons.warning, color:Colors.white),
      background: Colors.red);
}

void uShowMessageSentNotification() {
  showSimpleNotification(
      Text('Sent', style: kNavTextStyle,),
      leading:Icon(Icons.check, color:Colors.white),
      background: Colors.green);
}

void uShowEmptyTextNotification() {
  showSimpleNotification(
      Text('Message cannot be empty', style: TextStyle(color: kThemeColor),),
      leading:Icon(Icons.warning, color:kThemeColor),
      background: Colors.white);
}

void uShowCustomDialog({required BuildContext context, required IconData icon, required Color iconColor, required String text,
   List buttonList = const []}){
  List<Widget> butList=[];
  if(buttonList!=null && buttonList.length>0){
    for(var arr in buttonList){
      butList.add(Expanded(
        child: Container(
          margin: EdgeInsets.all(4.0),
          decoration: BoxDecoration(
              color: arr[1],
              borderRadius: BorderRadius.circular(20)
          ),
          child: FlatButton(onPressed: arr[2],
            child: Padding(
              padding: EdgeInsets.all(2),
              child: Text(arr[0], style: kNavTextStyle,),
            ),
            splashColor: Colors.white,),
        ),
      ));
    }
  }
  Dialog errorDialog= Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    backgroundColor: kDialogLight,
    child: Container(
      height: 350,
      constraints: BoxConstraints(
        maxWidth: 500
      ),
      child: Column(
        children: [
          Expanded(child: Icon(icon, color: iconColor, size: 200,)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(text, style: TextStyle(color: kThemeColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
          ),
          SizedBox(height: 20,),
          Container(
            height: butList!=null?50:2,
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: buttonList!=null?butList:[],
            ),
          )
        ],
      ),
    ),
  );
  showGeneralDialog(context: context,
      barrierLabel: text,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 500),
      transitionBuilder: (_, anim, __, child){
        return SlideTransition(position: Tween(begin: Offset(-1,0), end: Offset(0,0)).animate(anim), child: child,);
      },
      pageBuilder: (BuildContext context, _, __)=>(errorDialog)
  );
}

Future<bool> uCheckInternet() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

String  uGenerateRandomId() {
  var uuid = Uuid();
  return 'a'+uuid.v1().replaceAll('-', '');
}

Future<void> uSetPrefsValue(String key, var value) async {
  SharedPreferences sp=await SharedPreferences.getInstance();
  if(sp.containsKey(key)){
    await sp.remove(key);
  }
  await sp.reload();
  await sp.setString(key, value.toString());
}

Future<dynamic> uGetSharedPrefValue(String key) async {
  SharedPreferences sp=await SharedPreferences.getInstance();
  await sp.reload();
  return sp.get(key).toString();
}