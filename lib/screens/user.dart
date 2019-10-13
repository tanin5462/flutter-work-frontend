import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/userInfo.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyUser extends StatefulWidget {
  @override
  _MyUserState createState() => _MyUserState();
}

class _MyUserState extends State<MyUser> {
  bool isLoading = true;
  String customerName, customerSurname, customerKey, customerPositionKeyDefault;
  bool switchOn = false;
  Firestore db = Firestore.instance;
  List<Map<String, dynamic>> position = [];
  List<dynamic> positionSelected = [];
  var switchStore;
  @override
  void initState() {
    getLocalStorage();
    return super.initState();
  }

  // FUTURE
  Future<void> getLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      customerName = prefs.getString("customerName");
      customerSurname = prefs.getString("customerSurname");
      customerKey = prefs.getString("customerKey");
      customerPositionKeyDefault =
          prefs.getString('customerPositionKeyDefault');
    });
    getPositionSelected();
  }

  Future<void> getPositionSelected() async {
    setState(() {
      isLoading = true;
    });

    db
        .collection("CustomerAccounts")
        .document(customerKey)
        .collection("PositionSelected")
        .orderBy("orderid")
        .getDocuments()
        .then((dataPosition) {
      if (dataPosition.documents.length > 0) {
        // มีการตั้งค่าบทเรียนไว้อยู่แล้ว ดึงจากตารางที่user ตั้งไว้
        // print("NotEmpty");
        List<Map<String, dynamic>> dataFinal = [];
        dataPosition.documents.forEach((element) {
          if (element.data['status'] == true) {
            Map<String, dynamic> data = {};
            data.addAll({'key': element.documentID});
            data.addAll(element.data);
            dataFinal.add(data);
          }
        });
        setState(() {
          positionSelected = dataPosition.documents.first.data['position'];
          position = dataFinal;
          isLoading = false;
        });
        // });
      } else {
        // print("Empty");
        // ยังไม่มีการตั้งค่า เลือกบทเรียนไว้
        db
            .collection("Position")
            .where("status", isEqualTo: true)
            .getDocuments()
            .then((data) {
          List<Map<String, dynamic>> dataFinalPos = [];
          data.documents.forEach((element) {
            Map<String, dynamic> dataPos = {};
            dataPos.addAll({'key': element.documentID});
            dataPos.addAll(element.data);
            if (element.documentID == customerPositionKeyDefault) {
              dataPos.addAll({'isUse': true});
              // ทำการเพิ่มเข้าไปในการตั้งค่าบทเรียนอัตโนมัติ โดยบทเรียน Default ตอนสมัครจะถูกตั้งสถานะให้เป็นใช้งาน
              db
                  .collection("CustomerAccounts")
                  .document(customerKey)
                  .collection("PositionSelected")
                  .document(element.documentID)
                  .setData(
                    dataPos,
                  );
            } else {
              // ทำการเพิ่มเข้าไปในการตั้งค่าบทเรียนอัตโนมัติ โดยบทเรียนนอกเหนือจาก Default ตอนสมัครจะถูกตั้งสถานะให้เป็นไม่ใช้งาน
              dataPos.addAll({'isUse': false});
              db
                  .collection("CustomerAccounts")
                  .document(customerKey)
                  .collection("PositionSelected")
                  .document(element.documentID)
                  .setData(
                    dataPos,
                  );
            }
            dataFinalPos.add(dataPos);
          });
          setState(() {
            position = dataFinalPos;
            isLoading = false;
          });
        });
      }
    });
  }

  // WIDGET
  Widget loading() {
    return Center(
      child: Loading(indicator: BallPulseIndicator(), size: 100.0),
    );
  }

  Widget userUI() {
    return ListView(
      children: <Widget>[
        Container(
          color: Colors.blueGrey[900],
          child: Column(
            children: <Widget>[
              showUsername(),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Divider(
                  color: Colors.white,
                ),
              ),
              textHeader(),
              for (var i = 0; i < position.length; i++) showPosition(i),
            ],
          ),
        ),
      ],
    );
  }

  Widget showUsername() {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext context) => UserInfo());
        Navigator.of(context).push(materialPageRoute);
      },
      child: Container(
        padding: EdgeInsets.all(20.0),
        width: MediaQuery.of(context).size.width,
        // decoration: BoxDecoration(
        //   border: Border(
        //     bottom: BorderSide(color: Colors.white, width: 0.5),
        //   ),
        // ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                customerName + " " + customerSurname,
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            Icon(
              FontAwesomeIcons.chevronRight,
              color: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget textHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(20.0),
      child: Text(
        "เนื้อหาบทเรียน",
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget showPosition(int index) {
    return Container(
      // decoration: BoxDecoration(
      //     // border: Border(
      //     //   bottom: BorderSide(color: Colors.white, width: 0.5),
      //     // ),
      //     ),
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              position[index]['name'],
              style: TextStyle(color: Colors.white, fontSize: 16.0),
            ),
          ),
          Switch(
            onChanged: (bool value) {
              setState(() {
                position[index]['isUse'] = value;
              });
              db
                  .collection("CustomerAccounts")
                  .document(customerKey)
                  .collection("PositionSelected")
                  .document(position[index]['key'])
                  .setData(position[index]);
            },
            value: position[index]['isUse'],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loading();
    } else {
      return Container(
        child: userUI(),
      );
    }
  }
}
