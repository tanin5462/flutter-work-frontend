import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/bottomnavigatorbar.dart';
import 'package:flutter_atwork_frontend/screens/main_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'login.dart';

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text("แก้ไขข้อมูลส่วนตัว"),
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
        bottomNavigationBar: MyBottomNavBar(3),
      ),
    );
  }
}
