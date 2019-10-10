import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/dialog.dart';
import 'package:flutter_atwork_frontend/screens/dialogList.dart';
import 'package:flutter_atwork_frontend/screens/expressionList.dart';
import 'package:flutter_atwork_frontend/screens/login.dart';
import 'package:flutter_atwork_frontend/screens/user.dart';
import 'package:flutter_atwork_frontend/screens/vocabulary.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyMainPage extends StatefulWidget {
  final String showCurrentPage;
  const MyMainPage(this.showCurrentPage);
  @override
  _MyMainPageState createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  int currentMenu = 0;
  String appBarTitle = "คำศัพท์";
  Widget showWidget = MyVocabulary();

// FUTURE

  @override
  void initState() {
    super.initState();
    if (widget.showCurrentPage == "0") {
      showWidget = MyVocabulary();
      appBarTitle = "คำศัพท์";
      currentMenu = 0;
    } else if (widget.showCurrentPage == "1") {
      appBarTitle = "ประโยค";
      showWidget = ExpressionList();
      currentMenu = 1;
    } else if (widget.showCurrentPage == "2") {
      showWidget = MyDialog();
      currentMenu = 2;
      appBarTitle = "สนทนา";
    } else if (widget.showCurrentPage == "3") {
      showWidget = MyUser();
      currentMenu = 3;
      appBarTitle = "ผู้ใช้";
    }
  }

  // MY WIDGET
  Widget backgroundImage() {
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("images/bg-dark.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(appBarTitle),
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
              if (index == 0) {
                appBarTitle = "คำศัพท์";
                showWidget = MyVocabulary();
              } else if (index == 1) {
                appBarTitle = "ประโยค";
                showWidget = ExpressionList();
              } else if (index == 2) {
                appBarTitle = "สนทนา";
                showWidget = MyDialogList();
              } else if (index == 3) {
                appBarTitle = "ผู้ใช้งาน";
                showWidget = MyUser();
              }
            });
          },
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              backgroundImage(),
              Container(
                child: showWidget,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
