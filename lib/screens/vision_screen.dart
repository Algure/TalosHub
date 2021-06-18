import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as Im;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:talos_hub/custom_widgets/detection_box_renderer.dart';
import 'package:talos_hub/custom_widgets/my_button.dart';
import 'package:talos_hub/data_objects/ai_object.dart';
import 'package:talos_hub/utitlities/azure_client.dart';
import 'package:talos_hub/utitlities/constants.dart';
import 'package:talos_hub/utitlities/utility_functions.dart';

class VisionScreen extends StatefulWidget {

  AiObject aiObject;

  VisionScreen(this.aiObject);

  @override
  _VisionScreenState createState() => _VisionScreenState();
}

class _VisionScreenState extends State<VisionScreen> {
  var detectedBoxes;
  String filePath = '';
  String classificationLabel = '';
  bool shouldShowDev = false;
  bool progress = false;

  PickedFile? tempFile;
  Map<String, Color>? tagColorMap ;
  List<int> uploadImage = [];
  final picker= ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: kThemeColor),
        title: Hero(
            tag: widget.aiObject.id,
            child: Text(widget.aiObject.aiName, style: kNavTextStyle.copyWith(color: kThemeColor, fontSize: 20, fontWeight: FontWeight.bold),)),
        actions: [
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

        ],
      ),
      body: SafeArea(
        child: IgnorePointer(
          ignoring: progress,
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: Card(
                elevation: 5,
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: 500
                  ),
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(height: 10,),
                      getImageWidget(),
                      SizedBox(height: 10,
                        child: progress? LinearProgressIndicator(color: kThemeColor,): Container(),
                      ),
                      getColorLabels(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12.0),
                        child: Text(widget.aiObject.aiDescription??'',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w900, fontSize: 15),),
                      ),
                      SizedBox(height: 10,),
                      MyButton(text: 'Analyse', buttonColor: kThemeColor, textColor: Colors.white, onPressed: analyzeImage,),
                    ]
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  getImageWidget(){
    double aspectRatio=4/5;
    if(filePath==null || filePath.toString().trim().isEmpty || filePath.trim()=='null'){
      return AspectRatio(
          aspectRatio:aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
              color: kThemeColor,
              height: MediaQuery.of(context).size.height *0.25,
              width: double.maxFinite,
              alignment: Alignment.center,
              child: MaterialButton(
                  onPressed: (){
                    selectImage();
                  },
                  splashColor: Colors.white,
                  child: Text('select Image', style: kNavTextStyle),
              ),
         ),
        )
      );
    }
    return  AspectRatio(
      aspectRatio:aspectRatio,
      child: Container(
        height: MediaQuery.of(context).size.height *0.25,
        child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb ?  Image.network(this.tempFile!.path,
                  fit: BoxFit.cover, width: double.maxFinite,height:double.maxFinite) :
                Image.file(File(filePath),
                  height:double.maxFinite,
                  width: double.maxFinite,
                  fit: BoxFit.cover,),
              ),
             if(classificationLabel.isNotEmpty) Container(
                height: double.maxFinite,
              width: double.maxFinite,
              alignment: Alignment.center,
              color: classificationLabel.isNotEmpty?Colors.white.withOpacity(0.7): Colors.transparent,
              child: Text(classificationLabel,
                style: kNavTextStyle.copyWith(color: kThemeColor, fontSize: 24, fontWeight: FontWeight.w900),),),
             if(detectedBoxes != null) Container(
                  color: Colors.transparent,
                height: double.maxFinite,
                width: double.maxFinite,
                  child: CustomPaint(
                  painter: DetectionBoxPainter(
                     detectedBoxes, onBoxesRendered:showBoxLabels ,
                  ),
              )),
              Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.all(4),
                child: MaterialButton(
                  onPressed: () {
                    deleteImage();
                  },
                  splashColor: Colors.white,
                  child: Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kThemeColor,
                      ),
                      child: Icon(Icons.clear, color: Colors.white,
                        size: 20,)),
                ),
              ),
            ]
        ),
      ),
    );
  }

  selectImage() async {
    try {
      showProgress(true);
      tempFile = await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
      setDisplayFilePath(tempFile!.path);
      setUploadImageFormat(tempFile!);
      showProgress(false);
    }catch(e, t){
      uShowErrorNotification('An error occured !');
      showProgress(false);
      print('error: $e, trace: $t');
    }
  }

  Widget getColorLabels(){
    if(tagColorMap == null) return SizedBox(height: 0,);
    return Row(
      children: [
        for(String key in tagColorMap!.keys) ColorTag(key, tagColorMap![key]!),
      ],
    );
  }

  Future<dynamic> setUploadImageFormat(PickedFile imageFile) async {
    uploadImage = await imageFile.readAsBytes(); //base64Encode(imageFile.readAsBytesSync());
  }

  Future<void> analyzeImage() async {
    if(uploadImage == null || filePath == null || filePath.isEmpty){
      uShowErrorNotification('You need to select a picture first !');
      return;
    }
    showProgress(true);
    try {
      var jsonResponse = await AzureClient().analyzeImage(uploadImage!, widget.aiObject);
      if(widget.aiObject.link.contains('/detect/')){
        setDetectionBoxes(jsonResponse['predictions']);
      }
      else{
        setClassificationLabel(jsonResponse['predictions'][0]);
      }
    }catch(e, t){
      uShowErrorNotification('Sorry. An error occured !');
      print(' error: $e \n trace: $t');
    }
    showProgress(false);
  }

  void showProgress(bool bool) {
    setState(() {
      progress = bool;
    });
  }

  void setDisplayFilePath(String path) {
    setState(() {
      filePath = path;
    });
  }

  void deleteImage() {
    setState(() {
      uploadImage = [];
      classificationLabel='';
      filePath = '';
      tagColorMap = null;
      detectedBoxes = null;
    });
  }

  void setClassificationLabel(var bestOption) {
    String label = bestOption['tagName'] ;
    double probability = double.parse(bestOption['probability'].toString());
    if(probability < 0.75) label = 'Not sure';
    setState(() {
      classificationLabel = label;
    });
  }

  void setDetectionBoxes(predictionResponse) {
    setState(() {
      detectedBoxes = predictionResponse;
    });
  }

  showBoxLabels(Map<String, Color> tagColorMap){
    this.tagColorMap = tagColorMap;
  }

}


class ColorTag extends StatelessWidget {
  String tag;
  Color color;

  ColorTag(this.tag, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25,
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          border: Border.all(color: Colors.black)
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: this.color!
            ),
          ),
          SizedBox(width: 5,),
          Text(tag, style: TextStyle(color: Colors.black),)
        ],
      ),
    );
  }
}