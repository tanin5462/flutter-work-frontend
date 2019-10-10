import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/dialog.dart';
import 'package:flutter_atwork_frontend/screens/loading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDialogList extends StatefulWidget {
  @override
  _MyDialogListState createState() => _MyDialogListState();
}

class _MyDialogListState extends State<MyDialogList> {
  @override
  void initState() {
    loadPosition();
    return super.initState();
  }

  // **************************** -> VARIABLE <-**********************************
  Firestore db = Firestore.instance;
  List<Map<String, dynamic>> options = [];
  String selectedPositionKey = "";
  bool isLoading = false;
  List<Map<String, dynamic>> dialogData = [];
  // **************************** -> WIDGET <-**********************************

  Widget positionDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
      ),
      padding: EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: DropdownButton(
          isExpanded: true,
          icon: Icon(
            FontAwesomeIcons.chevronDown,
            size: 16,
          ),
          items: options.map((item) {
            return DropdownMenuItem(
              child: Text(item['label'].toString()),
              value: item['value'],
            );
          }).toList(),
          onChanged: (newval) {
            setState(() {
              selectedPositionKey = newval;
            });
            loadDialog();
          },
          value: selectedPositionKey,
        ),
      ),
    );
  }

  Widget showDialogList(String th, String en, String dialogKey, String vdoURL) {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute materialPageRoute = MaterialPageRoute(
            builder: (BuildContext context) => MyDialog(
                  titleEn: en,
                  titleTh: th,
                  dialogKey: dialogKey,
                  vdoURL: vdoURL,
                ));
        Navigator.of(context).push(materialPageRoute);
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.blueGrey[700],
            border: Border(bottom: BorderSide(color: Colors.black))),
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        th.trim(),
                        style: TextStyle(color: Colors.white),
                      ),
                      Container(
                        height: 10.0,
                      ),
                      Text(
                        en..trim(),
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 10.0),
                child: Icon(
                  FontAwesomeIcons.chevronRight,
                  color: Colors.teal,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // **************************** -> FUTURE <-**********************************
  Future<void> loadPosition() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String customerKey = pref.getString('customerKey');

    db
        .collection("CustomerAccounts")
        .document(customerKey)
        .collection("Settings")
        .document("PositionSetting")
        .get()
        .then((data) {
      if (data.exists) {
        // กรณีมีการตั้งค่า ตำแหน่งไว้
        int count = 0;
        data.data['position'].forEach((element) {
          db.collection("Position").document(element).get().then((data) {
            Map<String, dynamic> dataFinal = {
              'label': data.data['name'],
              'value': data.documentID
            };
            setState(() {
              options.add(dataFinal);
              selectedPositionKey = options[0]['value'];
            });

            if (count == 0) {
              loadDialog();
            }
            count++;
          });
        });
      } else {
        db
            .collection("Position")
            .where("status", isEqualTo: true)
            .getDocuments()
            .then((data) {
          data.documents.forEach((element) {
            options.add(element.data);
          });
        });
      }
    });
  }

  Future<void> loadDialog() async {
    db
        .collection("Dialog")
        .document("server")
        .collection("data")
        .where("positionSelec", arrayContains: selectedPositionKey)
        .getDocuments()
        .then((doc) {
      List<Map<String, dynamic>> dataFinal = [];
      doc.documents.forEach((ele) {
        Map<String, dynamic> dataAdd = {};
        dataAdd.addAll({"key": ele.documentID});
        dataAdd.addAll(ele.data);
        dataFinal.add(dataAdd);
      });
      setState(() {
        dialogData = dataFinal;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                positionDropdown(),
                for (var i = 0; i < dialogData.length; i++)
                  showDialogList(
                      dialogData[i]['situationThai'],
                      dialogData[i]['situationEng'],
                      dialogData[i]['key'],
                      dialogData[i]['url']),
              ],
            ),
          ),
        ],
      );
    } else {
      return ShowLoading();
    }
  }
}
