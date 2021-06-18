import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utitlities/azure_client.dart';
import '../utitlities/statics.dart';
import 'package:talos_hub/custom_widgets/ai_list_item.dart';
import 'package:talos_hub/custom_widgets/signup_dialog_widget.dart';
import 'package:talos_hub/data_objects/ai_object.dart';
import 'package:talos_hub/screens/profile_screen.dart';
import '../utitlities/utility_functions.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String searchText = '';

  bool progress = false;
  bool _inSearchMode =  false;

  RefreshController _rController= RefreshController(initialRefresh: false);

  List<Widget> aiWidgetsList=[];

  @override
  void initState() {
    loadInit();
  }

  @override
  void didUpdateWidget(MyHomePage oldWidget) {
    // resetAiList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('RoboHub', style: TextStyle(color: kThemeColor, fontSize: 18),),
        actions: [
          SizedBox(width: 20,),
          GestureDetector(
              onTap: (){
                openProfile();
              },
              child: Icon(CupertinoIcons.add_circled_solid, color: kThemeColor, )),
          SizedBox(width: 20,),
          GestureDetector(
              onTap: resetAiList,
              child: Icon(Icons.refresh, color: kThemeColor,)),
          SizedBox(width: 20,)
        ],
      ),
      body:  SmartRefresher(
        controller: _rController,
        onRefresh: resetAiList,
        child: MediaQuery.of(context).size.width>=800?
        GridView(
            padding: EdgeInsets.all(10),
            children:aiWidgetsList,
            // semanticChildCount: proWidgets.l,
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 5
            )
        ):
        SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: aiWidgetsList
          ),
        ),
      ),
    );
  }

  showLoginDialog() async {
    if(!(await uCheckInternet())){
      uShowErrorNotification('No internet connection !');
      return;
    }
    Dialog dialog= Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: SignUpScreen()
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

  Future<void> startSearch() async {
    if (searchText==null || searchText.trim().isEmpty){
      await  resetAiList();
      return;
    }
    showProgress(true);
    try {
      List<AiObject> proList = await AzureClient().searchAi(searchText);
      aiWidgetsList = [];
      for (AiObject pro in proList) {
        if (pro == null) continue;
        aiWidgetsList.add(AiLitem(pro));
      }
    }catch(e,t){
      uShowErrorNotification('An error occured. Drag to refresh.');
    }
    showProgress(false);
  }

  resetAiList() async {
    _setSearchMode(false);
    showProgress(true);
    try {
      List<AiObject> proList = await AzureClient().getAllValidAi();
      aiWidgetsList = [];
      for (AiObject pro in proList) {
        if (pro == null) continue;
        aiWidgetsList.add(AiLitem(pro));
      }
    }catch(e,t){
      uShowErrorNotification('An error occured. Drag to refresh.');
    }
    showProgress(false);
  }

  Future<void> openProfile() async {
    SharedPreferences sp=await SharedPreferences.getInstance();
    if(sp.containsKey(kIdkey) && sp.containsKey(kPassKey)){
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfileScreen()));
      return;
    }
    showLoginDialog();
  }

  void _setSearchMode(bool bool) {
    setState(() {
      _inSearchMode=bool;

    });
  }

  void showProgress(bool bool) {
    setState(() {
      if(!bool)  _rController.refreshCompleted();
      else _rController.requestRefresh();
    });
  }

  void loadInit() {
    Future.delayed(Duration(seconds: 2), resetAiList);
  }
}