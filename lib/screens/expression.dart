import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';
import 'main_page.dart';

class Expression extends StatefulWidget {
  final String situationKey;
  final String positionKey;
  Expression(this.situationKey, this.positionKey);
  @override
  _ExpressionState createState() => _ExpressionState();
}

class _ExpressionState extends State<Expression> {
  @override
  void initState() {
    super.initState();
    loadSituation();
  }

  // EXPLICIT
  Firestore db = Firestore.instance;
  List<Map<String, dynamic>> expressions = [];
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlayingAudio = false;
  int playingIndex;
  List<int> iconFavourites = [];
  bool isLoading = true;
  int currentMenu = 1;
  int showMicrophoneIndex;
  FlutterSound flutterSound = new FlutterSound();
  int recordingIndex;
  Color containerColor = Colors.white;
  bool isDisableTap = false;

  // MY WIDGET

  Widget expressionColumn() {
    return Container(
      child: Column(
        children: <Widget>[
          for (var i = 0; i < expressions.length; i++)
            englishExpression(expressions[i], i)
          // expressionRow()
        ],
      ),
    );
  }

  // MY WIDGET
  Widget backgroundImage() {
    return Container(
      decoration: new BoxDecoration(color: Colors.blueGrey[800]
          // image: new DecorationImage(
          //   image: new AssetImage("images/bg-dark.jpg"),
          //   fit: BoxFit.cover,
          // ),
          ),
    );
  }

  Widget englishExpression(Map<String, dynamic> item, int index) {
    return Container(
      padding: EdgeInsets.all(10.0),
      width: MediaQuery.of(context).size.width,
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 10.0),
              child: IconButton(
                  onPressed: () {
                    if (showMicrophoneIndex == index) {
                      if (recordingIndex == index) {
                        // STOP RECORD
                        stopRecord();
                      } else {
                        record();
                      }
                    } else {
                      favourite(index);
                    }
                  },
                  icon: showMicrophoneIndex == index
                      ? recordingIndex == index
                          ? Icon(
                              FontAwesomeIcons.stop,
                              color: Colors.amber,
                              size: 40,
                            )
                          : Icon(
                              FontAwesomeIcons.microphoneAlt,
                              color: Colors.teal,
                              size: 40,
                            )
                      : expressions[index]['favourite'] == true
                          ? Icon(
                              FontAwesomeIcons.solidHeart,
                              color: Colors.pink[300],
                              size: 40,
                            )
                          : Icon(
                              FontAwesomeIcons.heart,
                              size: 40,
                            )),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  play(item['url'], index);
                  setState(() {
                    showMicrophoneIndex = null;
                    playingIndex = index;
                    containerColor = Colors.teal;
                  });
                },
                child: AnimatedContainer(
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color:
                        playingIndex == index ? containerColor : Colors.white,
                  ),
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        item['sentenceEnglish'],
                        style: TextStyle(
                            color: playingIndex == index
                                ? Colors.white
                                : Colors.black87),
                      ),
                      Divider(
                        color: Colors.blueGrey[600],
                        thickness: 0.2,
                      ),
                      Text(
                        item['sentenceThai'],
                        style: TextStyle(
                            color: playingIndex == index
                                ? Colors.white
                                : Colors.black87),
                      )
                    ],
                  ),
                  duration: Duration(seconds: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget loading() {
    return Container(
      color: Color.fromRGBO(0, 0, 0, 0.5),
      child: Center(
        child: Loading(indicator: BallPulseIndicator(), size: 100.0),
      ),
    );
  }

  // MY FUTURE

  Future<void> favourite(int index) async {
    if (!isDisableTap) {
      setState(() {
        isLoading = true;
        if (expressions[index]['favourite'] == false) {
          expressions[index]['favourite'] = true;
        } else {
          expressions[index]['favourite'] = false;
        }
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String customerKey = prefs.getString('customerKey');
      var dbRefs = await db
          .collection("CustomerAccounts")
          .document(customerKey)
          .collection("FavouriteExpression")
          .document(widget.situationKey)
          .collection("favourite")
          .getDocuments();
      if (dbRefs.documents.length > 0) {
        db
            .collection("CustomerAccounts")
            .document(customerKey)
            .collection("FavouriteExpression")
            .document(widget.situationKey)
            .collection("favourite")
            .document(expressions[index]['key'])
            .updateData(expressions[index])
            .then((res) {
          List<Map<String, dynamic>> newExpression = [];
          db
              .collection("CustomerAccounts")
              .document(customerKey)
              .collection("FavouriteExpression")
              .document(widget.situationKey)
              .collection("favourite")
              .orderBy("orderid")
              .getDocuments()
              .then((newEx) {
            newEx.documents.forEach((newEle) {
              Map<String, dynamic> dataNew = {};
              dataNew.addAll({'key': newEle.documentID});
              dataNew.addAll(newEle.data);
              newExpression.add(dataNew);
            });
            newExpression.sort((a, b) {
              return b['favourite']
                  .toString()
                  .compareTo(a['favourite'].toString());
            });
            setState(() {
              expressions = newExpression;
              isLoading = false;
            });
          });
        });
      } else {
        // กรณี ยังไม่เคยมีการตั้ง Favourite
        setState(() {
          isLoading = true;
        });
        for (var i = 0; i < expressions.length; i++) {
          if (i != index) {
            expressions[i]['favourite'] = false;
          }
          db
              .collection("CustomerAccounts")
              .document(customerKey)
              .collection("FavouriteExpression")
              .document(widget.situationKey)
              .collection("favourite")
              .document(expressions[i]['key'])
              .setData(expressions[i])
              .then((resUp) {
            setState(() {
              isLoading = false;
            });
          });
        }
      }
    }
  }

  Future<void> loadSituation() async {
    // print(
    //     "SituationKey = ${widget.situationKey} PositionKey = ${widget.positionKey}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String customerKey = prefs.getString('customerKey');

    var dbRefs = await db
        .collection("CustomerAccounts")
        .document(customerKey)
        .collection("FavouriteExpression")
        .document(widget.situationKey)
        .collection("favourite")
        .getDocuments();
    if (dbRefs.documents.length > 0) {
      List<Map<String, dynamic>> newExpression = [];
      db
          .collection("CustomerAccounts")
          .document(customerKey)
          .collection("FavouriteExpression")
          .document(widget.situationKey)
          .collection("favourite")
          .orderBy("orderid")
          .getDocuments()
          .then((newEx) {
        newEx.documents.forEach((newEle) {
          Map<String, dynamic> dataNew = {};
          dataNew.addAll({'key': newEle.documentID});
          dataNew.addAll(newEle.data);
          newExpression.add(dataNew);
        });
        newExpression.sort((a, b) {
          return b['favourite'].toString().compareTo(a['favourite'].toString());
        });
        setState(() {
          expressions = newExpression;
          isLoading = false;
        });
      });
    } else {
      db
          .collection("Expression")
          .document("server")
          .collection("data")
          .where("situationKey", isEqualTo: widget.situationKey)
          .where("positionKey", isEqualTo: widget.positionKey)
          .getDocuments()
          .then((doc) {
        List<Map<String, dynamic>> dataTemp = [];
        doc.documents.forEach((element) {
          Map<String, dynamic> dataFinal = {};
          dataFinal.addAll({'key': element.documentID});
          dataFinal.addAll(element.data);
          dataTemp.add(dataFinal);
        });

        dataTemp.sort((a, b) {
          var r = a['orderid'].compareTo(b['orderid']);
          if (r != 0) return r;
          return a['orderid'].compareTo(b['orderid']);
        });
        setState(() {
          isLoading = false;
          expressions = dataTemp;
        });
      });
    }
  }

  Future<void> record() async {
    setState(() {
      recordingIndex = showMicrophoneIndex;
      isDisableTap = true;
    });
    await flutterSound.startRecorder(null);
  }

  Future<void> stopRecord() async {
    setState(() {
      recordingIndex = null;
      isDisableTap = false;
    });

    StreamSubscription<dynamic> _recorderSubscription =
        flutterSound.onRecorderStateChanged.listen((e) {});
    if (_recorderSubscription != null) {
      _recorderSubscription.cancel();
      _recorderSubscription = null;
    }
    await flutterSound.stopRecorder();

    // PLAY

    await flutterSound.startPlayer(null);
  }

  Future<void> play(url, int index) async {
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text("ประโยค"),
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
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentMenu,
          selectedItemColor: Colors.teal,
          items: [
            BottomNavigationBarItem(
              backgroundColor: Colors.black87,
              icon: Icon(
                FontAwesomeIcons.idCard,
                color: Colors.white70,
              ),
              title: Text(
                'คำศัพท์',
                style: TextStyle(color: Colors.white),
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.black87,
              icon: Icon(
                FontAwesomeIcons.commentDots,
                color: Colors.white70,
              ),
              title: Text(
                'ประโยค',
                style: TextStyle(color: Colors.white),
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.black87,
              icon: Icon(
                FontAwesomeIcons.comments,
                color: Colors.white70,
              ),
              title: Text(
                'สนทนา',
                style: TextStyle(color: Colors.white),
              ),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.black87,
              icon: Icon(
                FontAwesomeIcons.userCog,
                color: Colors.white70,
              ),
              title: Text(
                'ผู้ใช้',
                style: TextStyle(color: Colors.white),
              ),
            )
          ],
          onTap: (index) {
            setState(() {
              currentMenu = index;
            });

            if (index == 0) {
              MaterialPageRoute materialPageRoute = MaterialPageRoute(
                  builder: (BuildContext context) => MyMainPage("0"));
              Navigator.of(context).pushAndRemoveUntil(
                  materialPageRoute, (Route<dynamic> route) => false);
            } else if (index == 1) {
              Navigator.of(context).pop();
            } else if (index == 2) {
              MaterialPageRoute materialPageRoute = MaterialPageRoute(
                  builder: (BuildContext context) => MyMainPage("2"));
              Navigator.of(context).pushAndRemoveUntil(
                  materialPageRoute, (Route<dynamic> route) => false);
            } else if (index == 3) {
              MaterialPageRoute materialPageRoute = MaterialPageRoute(
                  builder: (BuildContext context) => MyMainPage("3"));
              Navigator.of(context).pushAndRemoveUntil(
                  materialPageRoute, (Route<dynamic> route) => false);
            }
          },
        ),
        body: Stack(
          children: <Widget>[
            backgroundImage(),
            ListView(
              children: <Widget>[expressionColumn()],
            ),
            isLoading ? loading() : Container()
          ],
        ),
      ),
    );
  }
}
