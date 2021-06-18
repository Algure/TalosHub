
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'statics.dart';
import 'package:talos_hub/data_objects/ai_object.dart';
import 'package:talos_hub/data_objects/profile.dart';
import 'keys.dart';
import 'utility_functions.dart';

class AzureClient{

  AzureClient._privateConstructor();

  static final AzureClient _instance = AzureClient._privateConstructor();

  factory AzureClient() {
    return _instance;
  }

  uploadProfile(Profile profile) async {
    String password= await uGetSharedPrefValue(kPassKey);
    String sendUrl = '$functionsEndPoint/api/UpdateProfile?name=${profile.name}&id=${profile.id}&pass=${password}';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    // print(' started search upload ${req.url}');
    await req.send().then((value) async {
      String message= await value.stream.bytesToString();
      // print('order upload result: ${value.statusCode},  ${message}');
      if (value.statusCode >= 400) throw Exception(' ${message}');
    });
  }

  Future<String> loginOnCloud(String email, String password) async {
    String message='';
    String sendUrl = '$functionsEndPoint/api/Login?email=$email&pass=$password';
    Request req = Request('POST', Uri.parse(sendUrl));
    // print(sendUrl);
    await req.send().then((value) async {
      message= await value.stream.bytesToString();
      // print('login result:  ${value.statusCode},  ${message},  ${value.toString()},  ${value.reasonPhrase.toString()}');
      if (value.statusCode >= 400) throw AuthException(' ${message}');
    });
    var data= jsonDecode(message);
    return data['id'].toString();
  }

  Future<String> signUpOnCloud(String email,String password) async {
    String sendUrl = '$functionsEndPoint/api/SignUp?email=$email&pass=$password';
    Request req = Request('POST', Uri.parse(sendUrl));
    req.headers['Content-Type'] = 'application/json';
    // print(' started search upload ${req.url}');
    String message= '';
    await req.send().then((value) async {
      message= await value.stream.bytesToString();
      // print('sign up result:  ${value.statusCode},  ${message},  ${value.toString()},  ${value.reasonPhrase.toString()}');
      if (value.statusCode >= 400) throw AuthException(' ${message}');
    });
    var data= jsonDecode(message);
    return data['id'].toString();
  }

  Future<Profile?> fetchProfile(String email) async {
    Response response = await get(Uri.parse('$searchEndPoint/indexes/taloprofiles/docs?api-version=2020-06-30&\$filter=email%20eq%20\'$email\''),
        headers:
        {'Content-Type': 'application/json',
          'api-key': searchKey});
    // print('market status response: ${response.body}');
    if (response != null && response.body != null) {
      var res = jsonDecode(response.body);
      if (res['value'].length > 0) {
        return Profile.fromMap(
            res['value'][0]);
      }
    }
    return null;
  }

  Future<Profile?> fetchAI(String email) async {
    Response response = await get(Uri.parse('$searchEndPoint/indexes/talohubdex/docs?api-version=2020-06-30-Preview&search=*'),
        headers:
        {'Content-Type': 'application/json',
          'api-key': searchKey});
    // print('market status response: ${response.body}');
    if (response != null && response.body != null) {
      var res = jsonDecode(response.body);
      if (res['value'].length > 0) {
        return Profile.fromMap(
            res['value'][0]);
      }
    }
    return null;
  }

  Future<List<AiObject?>> fetchUserAi(String email) async {
    Response response = await get(Uri.parse('$searchEndPoint/indexes/talohubdex/docs?api-version=2020-06-30&\$filter=creator_details%20eq%20\'$email\''),
        headers:
        {'Content-Type': 'application/json',
          'api-key': searchKey});
    // print('market status uri:${response.request!.url} response: ${response.body}');
    List<AiObject?> result = [];
    if (response != null && response.body != null) {
      var res = jsonDecode(response.body);
      if (res['value'].length > 0) {
        for(var value in res['value']) result.add(AiObject.fromMap(value));
      }
    }
    return result;
  }

  Future<void> uploadAI(AiObject aiObject) async{
    String message='';
    String sendUrl = '$functionsEndPoint/api/uploadAi?name=${aiObject.creatorName}&email=${aiObject.creatorDetails}&aikey=${aiObject.aiKey}&ailink=${aiObject.link}&ainame=${aiObject.aiName}&aidescription=${aiObject.aiDescription}&id=${aiObject.id}&aitype=${aiObject.category}';
    Request req = Request('POST', Uri.parse(sendUrl));
    // print(sendUrl);
    await req.send().then((value) async {
      message= await value.stream.bytesToString();
      // print('login result:  ${value.statusCode},  ${message},  ${value.toString()},  ${value.reasonPhrase.toString()}');
      if (value.statusCode >= 400) throw AuthException(' ${message}');
    });
  }

  Future<void> deleteAi(String id, String userId) async{
    String message='';
    String sendUrl = '$functionsEndPoint/api/delete-ai?id=$id&userId=$userId';
    Request req = Request('POST', Uri.parse(sendUrl));
    print(sendUrl);
    await req.send().then((value) async {
      message= await value.stream.bytesToString();
      print('delete result:  ${value.statusCode},  ${message},  ${value.toString()},  ${value.reasonPhrase.toString()}');
      if (value.statusCode >= 400) throw AuthException(' ${message}');
    });
  }

  Future<List<AiObject>> getAllValidAi() async {
    Response response = await get(Uri.parse('$searchEndPoint/indexes/talohubdex/docs?api-version=2020-06-30&search=*'),
        headers:
        {'Content-Type': 'application/json',
          'api-key': searchKey});
    // print('market status uri:${response.request!.url} response: ${response.body}');
    List<AiObject> result = [];
    if (response != null && response.body != null) {
      var res = jsonDecode(response.body);
      if (res['value'].length > 0) {
        for (var value in res['value'])
          result.add(AiObject.fromMap(value));
      }
    }
      return result;
  }

  searchAi(String value) async {
    Response response = await get(
        Uri.parse('$searchEndPoint/indexes/talohubdex/docs?api-version=2020-06-30-Preview&search=$value&searchFields=ai_name,ai_description'),
        headers:
        {'Content-Type': 'application/json',
          'api-key': searchKey,
          'Access-Control-Allow-Origin':'*'
        });
    // print('search status response: ${response.body}');
    List<AiObject> prolist=[];
    if (response != null && response.body != null) {
      var res = jsonDecode(response.body);
      for(var data in res['value']){
        AiObject pro= AiObject.fromMap(data);
        if(pro!=null)prolist.add(pro);
      }
    }
    return prolist;
  }

  analyzeImage(List<int> uploadImage, AiObject aiObject) async {
    Request req = Request('POST', Uri.parse('${aiObject.link}'),);
    req.headers['Prediction-Key'] =  aiObject.aiKey;
    req.headers['Content-Type'] =  'application/octet-stream';
    req.bodyBytes =  uploadImage;
    StreamedResponse response = await req.send();
    String message = await response.stream.bytesToString();
    print('uri: ${response.request!.url.toString()}. vision AI response: $message');
    if (response == null || message == null || response.statusCode >= 400 ) {
      throw 'Error in request';
    }
    return jsonDecode(message);
  }

}

class AuthException implements Exception {
  String message;
  AuthException(this.message);
}