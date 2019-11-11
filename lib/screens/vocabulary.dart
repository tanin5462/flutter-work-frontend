import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/loading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyVocabulary extends StatefulWidget {
  @override
  _MyVocabularyState createState() => _MyVocabularyState();
}

class _MyVocabularyState extends State<MyVocabulary> {
  @override
  void initState() {
    loadVocabulary();
    return super.initState();
  }

  // VARIABLE
  String resultTextShow = "ถูกต้อง";
  bool isLoading = true;
  bool isShowDescription = false;
  Firestore db = Firestore.instance;
  List<Map<String, dynamic>> vocabs = [];
  int currentQuestion = 0;
  AudioPlayer audioPlayer = AudioPlayer();
  // FUTURE
  Future<void> loadVocabulary() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("customerKey");
    List<String> positionSelected = prefs.getStringList("positionSelected");

    setState(() {
      isLoading = true;
    });
    // Load Choices for random
    db
        .collection("Vocabulary")
        .document("server")
        .collection("data")
        .getDocuments()
        .then((vchoices) {
      List<Map<String, dynamic>> choicesTemp = [];
      vchoices.documents.forEach((v) {
        Map<String, dynamic> dataChoices = {};
        dataChoices.addAll({'key': v.documentID});
        dataChoices.addAll(v.data);
        choicesTemp.add(dataChoices);
      });
      choicesTemp.shuffle();
      db
          .collection("Vocabulary")
          .document("server")
          .collection("data")
          .getDocuments()
          .then((vocabData) {
        vocabData.documents.forEach((e) {
          // ถ้าเป็นคำศัพท์ที่อยู่ในตำแหน่งที่ User เลือกไว้
          if (positionSelected.contains(e.data['positionKey'])) {
            List choices = List(3);
            final _random = new Random();
            int next(int min, int max) => min + _random.nextInt(max - min);
            int randomType = next(1, 4);
            // 1.โจทย์ศัพท์เสียง คำตอบ คำแปลไทย
            // 2.โจทย์คำแปลไทย คำตอบ ศัพท์อังกฤษ
            // 3.โจทย์คำศัพท์อังกฤษ คำตอบ คำแปลไทย
            Map<String, dynamic> data = {};
            data.addAll({'key': e.documentID});
            data.addAll(e.data);
            for (var i = 0; i < 3; i++) {
              if (i == 0) {
                choices[i] = data;
              } else {
                choices[i] = choicesTemp[i];
              }
            }
            choices.shuffle();
            data.addAll({'type': randomType});
            data.addAll({'choices': choices});
            setState(() {
              vocabs.add(data);
            });
          }
        });
        setState(() {
          vocabs.shuffle();
          isLoading = false;
        });
      });
    });
  }

  Future<void> play(url) async {
    print(url);
    await audioPlayer.play(url);
    // ON AUDIO END
    audioPlayer.onPlayerCompletion.listen((event) {});
  }

  Future<void> checkAnswer(String questionKey, choiceKey) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userId = pref.getString("customerKey");
    if (questionKey == choiceKey) {
      setState(() {
        resultTextShow = "ตอบถูก";
      });
      db
          .collection("CustomerAccounts")
          .document(userId)
          .collection("Vocabulary")
          .document(questionKey)
          .get()
          .then((doc) {
        int newData = doc.data['correct'] + 1;
        db
            .collection("CustomerAccounts")
            .document(userId)
            .collection("Vocabulary")
            .document(questionKey)
            .updateData(
          {
            'correct': newData,
            'ratio': newData / doc.data['incorrect'],
          },
        );
      });
    } else {
      setState(() {
        resultTextShow = "ตอบผิด";
      });

      db
          .collection("CustomerAccounts")
          .document(userId)
          .collection("Vocabulary")
          .document(questionKey)
          .get()
          .then((doc) {
        int newData = doc.data['incorrect'] + 1;
        db
            .collection("CustomerAccounts")
            .document(userId)
            .collection("Vocabulary")
            .document(questionKey)
            .updateData(
          {
            'incorrect': newData,
            'ratio': newData / doc.data['correct'],
          },
        );
      });
    }
    setState(() {
      isShowDescription = true;
    });
  }

  // MY WIDGET
  Widget gameBg() {
    return Stack(
      children: <Widget>[
        gameBgImg(),
        resultBar(),
        charactorShow(),
      ],
    );
  }

  Widget vocabPracticeShow() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [Colors.white, Colors.grey],
          ),
        ),
        child: Container(
          child: ListView(
            children: <Widget>[
              questionShow(),
              mySizeBox(),
              for (var i = 0;
                  i < vocabs[currentQuestion]['choices'].length;
                  i++)
                answerShow(i, vocabs[currentQuestion]['type']),
            ],
          ),
        ),
      ),
    );
  }

  Widget gameBgImg() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("images/Deepsea bg.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget resultBar() {
    return Positioned(
      bottom: 0,
      child: Container(
          padding: EdgeInsets.all(8.0),
          width: MediaQuery.of(context).size.width,
          color: Colors.blueGrey[900],
          child: resultText()),
    );
  }

  Widget resultText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          resultTextShow,
          style: TextStyle(
              color: resultTextShow == "ตอบถูก"
                  ? Colors.teal[200]
                  : resultTextShow == "ตอบผิด" ? Colors.red : Colors.teal[200],
              fontSize: 16),
        ),
        resultTextShow == "ตอบถูก" || resultTextShow == "ตอบผิด"
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Icon(
                  resultTextShow == "ตอบถูก"
                      ? FontAwesomeIcons.check
                      : FontAwesomeIcons.times,
                  color: resultTextShow == "ตอบถูก"
                      ? Colors.teal[200]
                      : Colors.red,
                ),
              )
            : Container(),
      ],
    );
  }

  Widget charactorShow() {
    return Positioned(
      left: -10,
      bottom: -8,
      child: Container(
        padding: EdgeInsets.all(8.0),
        width: MediaQuery.of(context).size.width * 0.4,
        child: Image.asset("images/6.png"),
      ),
    );
  }

  Widget mySizeBox() {
    return Container(
      height: 10,
    );
  }

  Widget answerShow(int index, int type) {
    return GestureDetector(
      onTap: () {
        // ฟังก์ชันเช็คคำตอบ
        String questionKey = vocabs[currentQuestion]['key'];
        String choiceKey = vocabs[currentQuestion]['choices'][index]['key'];
        checkAnswer(questionKey, choiceKey);
        // เช็คคำตอบ
      },
      child: Stack(
        children: <Widget>[
          bgButton(),
          textAnswerShow(index, type),
        ],
      ),
    );
  }

  Widget textAnswerShow(int index, int type) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width,
      child: type == 1 || type == 3
          ? Text(
              vocabs[currentQuestion]['choices'][index]['meaning'],
              style: TextStyle(fontSize: 15),
            )
          : Text(
              vocabs[currentQuestion]['choices'][index]['vocab'],
              style: TextStyle(fontSize: 15),
            ),
    );
  }

  Widget bgButton() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.09,
      width: MediaQuery.of(context).size.width,
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("images/3.png"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget questionShow() {
    return GestureDetector(
      onTap: () {
        if (vocabs[currentQuestion]['type'] == 1) {
          play(vocabs[currentQuestion]['url']);
        }
      },
      child: Stack(
        children: <Widget>[
          bgQuestionShow(),
          questionText(),
        ],
      ),
    );
  }

  Widget questionText() {
    if (vocabs[currentQuestion]['type'] == 1) {
      return GestureDetector(
        onTap: () {
          play(vocabs[currentQuestion]['url']);
        },
        child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width,
          child: Icon(
            FontAwesomeIcons.volumeUp,
            color: Colors.white,
          ),
        ),
      );
    } else if (vocabs[currentQuestion]['type'] == 2) {
      return Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Text(
          vocabs[currentQuestion]['meaning'],
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * 0.1,
        width: MediaQuery.of(context).size.width,
        child: Text(
          vocabs[currentQuestion]['vocab'],
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }
  }

  Widget bgQuestionShow() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/1.png"),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  Widget showDescription() {
    return Expanded(
      child: ListView(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(top: 0, left: 10, right: 10),
            decoration: BoxDecoration(
                gradient: RadialGradient(
              radius: 3.0,
              colors: [
                Colors.grey,
                Colors.grey[700],
              ],
            )),
            child: Column(
              children: <Widget>[
                vocabs[currentQuestion]['type'] == 3 ||
                        vocabs[currentQuestion]['type'] == 2
                    ? descriptionTextShowType2and3()
                    : descriptionTextShowType1(),
                mySizeBox(),
                nextButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget nextButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isShowDescription = false;
          currentQuestion++;
          resultTextShow = "350m.";
        });
      },
      child: Stack(
        children: <Widget>[
          bgButton(),
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.08,
            width: MediaQuery.of(context).size.width,
            child: Text(
              "ข้อถัดไป",
              style: TextStyle(fontSize: 15),
            ),
          )
        ],
      ),
    );
  }

  Widget descriptionTextShowType2and3() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.35,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/1.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10.0),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      for (var i = 0;
                          i < vocabs[currentQuestion]['choices'].length;
                          i++)
                        Container(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                vocabs[currentQuestion]['choices'][i]['vocab'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              Text(
                                vocabs[currentQuestion]['choices'][i]
                                    ['meaning'],
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget descriptionTextShowType1() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/1.png"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              vocabs[currentQuestion]['vocab'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            Text(
                              vocabs[currentQuestion]['meaning'],
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget showVocabTest() {
    return Expanded(
      child: ListView(
        children: <Widget>[
          Text(
            vocabs.toString(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? ShowLoading()
        : Column(
            children: <Widget>[
              gameBg(),
              isShowDescription ? showDescription() : vocabPracticeShow(),
            ],
          );
  }
}
