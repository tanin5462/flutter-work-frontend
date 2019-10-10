import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'main_page.dart';

class MyBottomNavBar extends StatefulWidget {
  final int getCurrentMenu;
  MyBottomNavBar(this.getCurrentMenu);
  @override
  _MyBottomNavBarState createState() => _MyBottomNavBarState();
}

class _MyBottomNavBarState extends State<MyBottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.getCurrentMenu,
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
    );
  }
}
