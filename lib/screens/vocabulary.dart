import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/loading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyVocabulary extends StatefulWidget {
  @override
  _MyVocabularyState createState() => _MyVocabularyState();
}

class _MyVocabularyState extends State<MyVocabulary> {
  // VARIABLE
  String resultTextShow = "ถูกต้อง";
  bool isLoading = false;
  bool isShowDescription = false;
  // FUTURE
  // MY WIDGET
  Widget gameBg() {
    return Stack(
      children: <Widget>[
        gameBgImg(),
        resultBar(),
        charactorShow(),
        Switch(
          onChanged: (bool value) {
            print(value);
            setState(() {
              isShowDescription = value;
            });
          },
          value: isShowDescription,
        ),
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
              for (var i = 0; i < 4; i++) answerShow(),
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
          style: TextStyle(color: Colors.teal[200], fontSize: 16),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Icon(
            FontAwesomeIcons.check,
            color: Colors.teal[200],
          ),
        ),
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

  Widget answerShow() {
    return Stack(
      children: <Widget>[
        bgButton(),
        textAnswerShow(),
      ],
    );
  }

  Widget textAnswerShow() {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.08,
      width: MediaQuery.of(context).size.width,
      child: Text("ANSWER"),
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
    return Stack(
      children: <Widget>[
        bgQuestionShow(),
        questionText(),
      ],
    );
  }

  Widget questionText() {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width,
      child: Text(
        "QuestionText",
        style: TextStyle(color: Colors.white),
      ),
    );
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
                descriptionTextShow(),
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
    return Stack(
      children: <Widget>[
        bgButton(),
        Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height * 0.08,
          width: MediaQuery.of(context).size.width,
          child: Text("ขัดถัดไป"),
        )
      ],
    );
  }

  Widget descriptionTextShow() {
    return Stack(
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
                    for (var i = 0; i < 8; i++)
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Text(
                          "Description",
                          style: TextStyle(color: Colors.white),
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
