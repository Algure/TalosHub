class AiObject{
  String id='';
  String description='';
  String link='';
  String aiName='';
  String aiDescription='';
  String aiKey='';
  String extra='';
  String category='';
  String creatorName='';
  String creatorDetails='';

  AiObject();

  AiObject.fromMap(Map jsonData){
    id=jsonData['id'].toString();
    description=jsonData['description'].toString();
    link=jsonData['link'].toString();
    extra=jsonData['extra'].toString();
    category=jsonData['category'].toString();
    creatorName=jsonData['creator_name'].toString();
    creatorDetails=jsonData['creator_details'].toString();
    aiName=jsonData['ai_name'].toString();
    aiKey=jsonData['ai_key'].toString();
    aiDescription=jsonData['ai_description'].toString();
  }

}