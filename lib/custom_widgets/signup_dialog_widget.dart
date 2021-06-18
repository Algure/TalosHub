import 'package:flutter/material.dart';
import '../utitlities/azure_client.dart';
import '../utitlities/statics.dart';
import 'package:talos_hub/custom_widgets/my_button.dart';
import 'package:talos_hub/data_objects/profile.dart';
import 'package:talos_hub/screens/home_screen.dart';
import 'package:talos_hub/screens/profile_screen.dart';
import '../utitlities/utility_functions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool progress= false;
  bool _emailInFocus=false;
  bool showPassword=false;
  bool selected=false;
  bool _passInFocus= false;
  String _email='';
  String? _iconString;
  String  _password='';
  Widget _socialIcon=SizedBox.shrink();

  Color hintColor=Colors.grey;
  Color hintSelectedColor=Colors.blue;

  TextEditingController? _linkController;
  TextEditingController? _passController;

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
              Container(
                height: 50,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() => _emailInFocus=hasFocus);
                  },
                  child: TextFormField(
                      controller:_linkController,
                      style: TextStyle(color: Colors.black),//kInputTextStyle,
                      textAlign: TextAlign.start,
                      autofocus: false,
                      maxLines: 1,
                      onEditingComplete: (){

                      },
                      onChanged: (text){
                        _email=text;
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Email',
                          labelStyle: TextStyle(
                              color:_emailInFocus?hintSelectedColor:hintColor
                          ),
                          suffixIcon: Padding(padding: EdgeInsets.all(5),child: _socialIcon),
                          focusedBorder: kLinedFocusedBorder,
                          enabledBorder: kLinedBorder,
                          disabledBorder: kLinedBorder
                      )
                  ),
                ),
              ),
              SizedBox(height: 20,),
              Container(
                height: 50,
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() => _passInFocus=hasFocus);
                  },
                  child: TextFormField(
                      controller: _passController,
                      style: TextStyle(color: Colors.black),//kInputTextStyle,
                      textAlign: TextAlign.start,
                      autofocus: false,
                      maxLines: 1,
                      onEditingComplete: (){

                      },
                      onChanged: (text){
                        _password=text;
                      },
                      obscureText: showPassword?false:true,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          labelText: 'Password',
                          labelStyle: TextStyle(
                              color:_passInFocus?hintSelectedColor:hintColor
                          ),
                          // suffixIcon: Padding(padding: EdgeInsets.all(5),child: Icon(Icons.lock)),
                          suffixIcon: IconButton(icon: Icon(showPassword?Icons.visibility_off:Icons.visibility, color: Colors.grey,), onPressed: _toggleIconVisibility,),
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
                child: Row(
                    children:[
                      Expanded(
                        child: MyButton(buttonColor: kThemeColor,
                          onPressed:() async {
                            _login();
                          },
                          textColor: Colors.white, text: 'Login', ),
                      ),
                      SizedBox(width: 15,),
                      Expanded(
                        child: MyButton(buttonColor: Colors.black,
                          textColor: Colors.white,
                          onPressed:() async {
                            _signup();
                          }, text: 'Sign Up', ),
                      ),
                    ]
                ),
              ),
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

  _toggleIconVisibility(){
    setState(() {
      showPassword=!showPassword;
    });
  }

  _signup() async{
    _showProgress(true);
    try {
      _email = _email.trim();
      if (_email == null || _email.isEmpty) {
        _showProgress(false);
        uShowErrorNotification('Email cannot be empty');
        return;
      } else if (!_email.contains('@') || !_email.contains('.com')) {
        _showProgress(false);
        uShowErrorNotification('Invalid email');
        return;
      }
      _password = _password.trim();
      if (_password == null || _password.isEmpty) {
        _showProgress(false);
        uShowErrorNotification('Password cannot be empty');
        return;
      } else if (_password.length < 3) {
        _showProgress(false);
        uShowErrorNotification('Password is too short');
        return;
      }
      Profile? tprf = await AzureClient().fetchProfile(_email);
      if(tprf!=null && tprf.id!=null && tprf.id!.length>5){
        _showProgress(false);
        uShowErrorNotification('This link is registered');
        return;
      }
      print("link: $_email, password: $_password}");
      String id = await AzureClient().signUpOnCloud(_email, _password);
      Profile mProfile = Profile()
        ..id = id
        ..name = ''
        ..email =_email;

      await uSetPrefsValue(kIdkey, mProfile.id);
      await uSetPrefsValue(kNameKey, mProfile.name);
      await uSetPrefsValue(kMailKey, _email);
      await uSetPrefsValue(kPassKey, _password);
      _showProgress(false);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
    }catch(e,t){
      print('error: $e, trace: $t');
      if(e.runtimeType==AuthException) uShowErrorNotification('${(e as AuthException).message}');
      else uShowErrorNotification('An error occured !');
    }
    _showProgress(false);
  }


  String _generateRandomId() {
    var uuid = Uuid();
    return 'a'+uuid.v1().replaceAll('-', '');
  }

  _login() async {
    _showProgress(true);
    try {
      _email = _email.trim();
      if (_email == null || _email.isEmpty) {
        _showProgress(false);

      } else if (!_email.contains('@') || !_email.contains('.com')) {
        _showProgress(false);
        uShowErrorNotification('Invalid email');
        return;
      }
      _password = _password.trim();
      if (_password == null || _password.isEmpty) {
        _showProgress(false);
        uShowErrorNotification('Password cannot be empty');
        return;
      } else if (_password.length < 3) {
        _showProgress(false);
        uShowErrorNotification('Password is too short');
        return;
      }

      Profile? prf;

      String? id = '';
      prf = await AzureClient().fetchProfile(_email);
      if (prf != null) {
        id =await AzureClient().loginOnCloud(_email, _password);
        await uSetPrefsValue(kIdkey, prf.id);
        await uSetPrefsValue(kNameKey, prf.name);
        await uSetPrefsValue(kMailKey, _email);
        await uSetPrefsValue(kPassKey, _password);
        _showProgress(false);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) =>ProfileScreen()));
      }else{
        throw 'Profile not found.';
      }
    }catch(e,t){
      print('Error: $e, trace: $t');
      if(e.runtimeType==AuthException && !(e as AuthException).message.contains('<')) uShowErrorNotification('${(e as AuthException).message}');
      else if(e.toString().contains('Wrong password'))uShowErrorNotification('Wrong password !');
      else if(e.toString().contains('Profile not found.'))uShowErrorNotification('Profile not found.');
      else uShowErrorNotification('An error occured');
    }
    _showProgress(false);

  }

  void _showProgress(bool bool) {
    setState(() {
      progress=bool;
    });
  }

}
