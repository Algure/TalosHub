
class MessageObject{
  String id='';
  String userId='';
  String userFullName='';
  String chat_text='';

  MessageObject();

  MessageObject.fromJson(var jsonData){
    id=jsonData['id'].toString();
    userId=jsonData['user_id'].toString();
    userFullName=jsonData['user_fullname'].toString();
    chat_text=jsonData['chat_text'].toString();
  }

  MessageObject.fromMap(Map jsonData){
    id=jsonData['id'].toString();
    userId=jsonData['user_id'].toString();
    userFullName=jsonData['user_fullname'].toString();
    chat_text=jsonData['chat_text'].toString();
  }


  @override
  String toString() {
    return 'id:$id, user_id: $userId, user_fullname: $userFullName, chat_text:$chat_text';
  }

  Map<String, dynamic> toMap(){
    return {
      'id':id,
      'user_id':userId,
      'user_fullname': userFullName,
      'chat_text':chat_text,
    };
  }

}