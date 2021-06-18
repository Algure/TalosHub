import 'package:flutter/material.dart';
import '../utitlities/azure_client.dart';
import '../utitlities/statics.dart';
import 'package:talos_hub/custom_widgets/my_button.dart';
import 'package:talos_hub/data_objects/profile.dart';
import '../utitlities/utility_functions.dart';

class ChangeNameDialogWidget extends StatefulWidget {

  ChangeNameDialogWidget(this.onNameChanged);

  Function onNameChanged;

  @override
  _ChangeNameDialogWidgetState createState() => _ChangeNameDialogWidgetState();
}

class _ChangeNameDialogWidgetState extends State<ChangeNameDialogWidget> {

  bool nameInFocus=false;
  bool selected=false;
  bool progress= false;
  Color hintColor=Colors.grey;
  Color hintSelectedColor=Colors.blue;
  String name='';
  TextEditingController? nameController;
  Widget socialIcon = SizedBox.shrink();

  @override
  void initState() {

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:  Card(
        elevation: 0,
        child: Container(
          constraints: BoxConstraints(
              maxWidth: 500
          ),
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Change Name', style: TextStyle(color: kThemeColor, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
              ),
              Container(
                height: 50,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() => nameInFocus=hasFocus);
                  },
                  child: TextFormField(
                      controller:nameController,
                      style: TextStyle(color: Colors.black),//kInputTextStyle,
                      textAlign: TextAlign.start,
                      autofocus: false,
                      maxLines: 1,
                      onChanged: (text){
                        name=text;
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Enter name',
                          labelStyle: TextStyle(
                              color:nameInFocus?hintSelectedColor:hintColor
                          ),
                          suffixIcon: Padding(padding: EdgeInsets.all(5),child: socialIcon),
                          focusedBorder: kLinedFocusedBorder,
                          enabledBorder: kLinedBorder,
                          disabledBorder: kLinedBorder
                      )
                  ),
                ),
              ),
              SizedBox(height: 30,),
              SizedBox(
                height: 50,
                child: MyButton(buttonColor: kThemeColor,
                  onPressed:() async {
                    updateProfile();
                  },
                  textColor: Colors.white, text: 'Update', ),),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.1,
              ),
              if(progress) Container(height:20, width: 20,child: CircularProgressIndicator(color: kThemeColor,)),
              Container(
                  height: 30,
                  child: Text('Powered by Azure', style:  TextStyle(color:kThemeColor, fontWeight: FontWeight.w900, fontSize: 12),)),
              SizedBox(height: 20,),
            ],
          ),
        ),
      ),
    );
  }

  void showProgress(bool bool) {
    setState(() {
      progress=bool;
    });
  }

  updateProfile() async{
    showProgress(true);
    try {
       name = name.trim();
      if (name == null || name.isEmpty) {
        showProgress(false);
        uShowErrorNotification('Name cannot be empty');
        return;
      } else if (name.length>30) {
        showProgress(false);
        uShowErrorNotification('Name is too long (max: 30 chars)');
        return;
      }

      String _email= await uGetSharedPrefValue(kMailKey);
      Profile? mProfile = await AzureClient().fetchProfile(_email);
      mProfile!.name=name;
      await AzureClient().uploadProfile(mProfile);
      await uSetPrefsValue(kIdkey, mProfile.id);
      await uSetPrefsValue(kNameKey, mProfile.name);
      await uSetPrefsValue(kMailKey, _email);
      showProgress(false);
      widget.onNameChanged.call();
      Navigator.pop(context);
    }catch(e,t){
      // print('error: $e, trace: $t');
      if(e.runtimeType==AuthException) uShowErrorNotification('${(e as AuthException).message}');
      else uShowErrorNotification('An error occured !');
    }
    showProgress(false);
  }

}
