import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/loading.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login.dart';
import 'videoplayer.dart';

class MyDialog extends StatefulWidget {
  final String titleEn, titleTh, vdoURL, dialogKey;
  MyDialog({this.titleEn, this.titleTh, this.vdoURL, this.dialogKey});
  @override
  _MyDialogState createState() => _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  @override
  void initState() {
    loadDialog();
    return super.initState();
  }

  // VARIABLE
  var audioPlayer = AudioPlayer();
  bool isLoading = true;
  String vdoTitleEN, videoTitleTH;
  Firestore db = Firestore.instance;
  List<Map<String, dynamic>> sentenceData = [];
  List<Map<String, dynamic>> speakers = [];
  int showMicrophoneIndex;
  bool isDisableTap = false;
  bool isPlayingAudio = false;
  FlutterSound flutterSound = new FlutterSound();
  // FUTURE
  Future<void> loadDialog() async {
    db
        .collection("Dialog")
        .document("server")
        .collection("data")
        .document(widget.dialogKey)
        .collection("sentence")
        .orderBy("orderId")
        .getDocuments()
        .then((sentence) {
      List<Map<String, dynamic>> dataFinal = [];
      sentence.documents.forEach((ele) {
        Map<String, dynamic> data = {};
        data.addAll({'key': ele.documentID});
        data.addAll(ele.data);
        dataFinal.add(data);
      });
      setState(() {
        isLoading = false;
        sentenceData = dataFinal;
      });

      // LOAD SPEAKERNAME
      db
          .collection("Dialog")
          .document("server")
          .collection("data")
          .document(widget.dialogKey)
          .collection("speaker")
          .getDocuments()
          .then((speakerDoc) {
        List<Map<String, dynamic>> dataSpeakerFinal = [];
        speakerDoc.documents.forEach((elespeaker) {
          Map<String, dynamic> dataSpeaker = {};
          dataSpeaker.addAll({'key': elespeaker.documentID});
          dataSpeaker.addAll({'speakerNameTh': elespeaker.data['speakerThai']});
          dataSpeaker.addAll({'speakerNameEng': elespeaker.data['speakerEng']});
          dataSpeakerFinal.add(dataSpeaker);
        });
        setState(() {
          speakers = dataSpeakerFinal;
        });
      });
    });
  }

  Future<void> play(url, int index) async {
    setState(() {
      showMicrophoneIndex = null;
    });
    if (!isDisableTap) {
      isPlayingAudio = true;
      await audioPlayer.play(url);
      // ON AUDIO END
      audioPlayer.onPlayerCompletion.listen((event) {
        setState(() {
          isPlayingAudio = false;
          showMicrophoneIndex = index;
        });
      });
    }
  }

  Future<void> record() async {
    // setState(() {
    //   isDisableTap = true;
    // });
    await flutterSound.startRecorder(null);
  }

  Future<void> stopRecord() async {
    // setState(() {
    //   isDisableTap = false;
    // });

    await flutterSound.stopRecorder();
    // PLAY
    await flutterSound.startPlayer(null);
  }

  Widget showSpeakerName(String speakerKey) {
    var newMap =
        speakers.where((m) => m['key'].startsWith(speakerKey)).toList();
    return Row(
      children: <Widget>[
        Text(newMap[0]['speakerNameTh']),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Text("-"),
        ),
        Text(newMap[0]['speakerNameEng'])
      ],
    );
  }

  // WIDGET

  Widget showTitle() {
    return Container(
      color: Colors.blueGrey[900],
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            widget.titleTh,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Container(
            height: 10,
          ),
          Text(
            widget.titleEn,
            style: TextStyle(color: Colors.white, fontSize: 16),
          )
        ],
      ),
    );
  }

  Widget dialogCard(int index) {
    return Container(
      color: Colors.blueGrey[800],
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Padding(
              padding: EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
              child: showMicrophoneIndex == index
                  // แสดงปุ่ม Microphone สำหรับบันทึกเสียง
                  ? Row(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          child: IconButton(
                            icon: !isPlayingAudio
                                ? Icon(
                                    FontAwesomeIcons.microphoneAlt,
                                    color: Colors.teal,
                                    size: 35,
                                  )
                                : Icon(
                                    FontAwesomeIcons.stop,
                                    color: Colors.amber,
                                    size: 35,
                                  ),
                            onPressed: () {
                              setState(() {
                                isPlayingAudio = !isPlayingAudio;
                              });
                              print(isPlayingAudio);
                              if (isPlayingAudio) {
                                record();
                              } else {
                                stopRecord();
                              }
                            },
                          ),
                        ),
                        Expanded(
                            child: GestureDetector(
                          onTap: () {
                            play(sentenceData[index]['url'], index);
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              showSpeakerName(
                                  sentenceData[index]['speakerKey']),
                              Divider(
                                thickness: 0.5,
                                color: Colors.black,
                              ),
                              Text(sentenceData[index]['sentenceEng']),
                              Container(
                                height: 10,
                              ),
                              Text(sentenceData[index]['sentenceThai'])
                            ],
                          ),
                        )),
                      ],
                    )
                  :
                  // ปกติ
                  GestureDetector(
                      onTap: () {
                        play(sentenceData[index]['url'], index);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          showSpeakerName(sentenceData[index]['speakerKey']),
                          Divider(
                            thickness: 0.5,
                            color: Colors.black,
                          ),
                          Text(sentenceData[index]['sentenceEng']),
                          Container(
                            height: 10,
                          ),
                          Text(sentenceData[index]['sentenceThai'])
                        ],
                      ),
                    )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: Text("สนทนา"),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              MaterialPageRoute materialPageRoute = MaterialPageRoute(
                  builder: (BuildContext context) => MyLogin());
              Navigator.of(context).push(materialPageRoute);
            },
            icon: Icon(FontAwesomeIcons.signOutAlt),
          )
        ],
      ),
      body: SafeArea(
        child: !isLoading
            ? Column(
                children: <Widget>[
                  VideoPlayer(videoURL: widget.vdoURL),
                  showTitle(),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        for (var i = 0; i < sentenceData.length; i++)
                          dialogCard(i)
                      ],
                    ),
                  )
                ],
              )
            : ShowLoading(),
      ),
    );
  }
}
