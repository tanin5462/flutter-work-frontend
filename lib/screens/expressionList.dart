import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/expression.dart';
import 'package:flutter_atwork_frontend/screens/loading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpressionList extends StatefulWidget {
  @override
  _ExpressionListState createState() => _ExpressionListState();
}

class _ExpressionListState extends State<ExpressionList> {
  Firestore db = Firestore.instance;
  bool isLoadFinish = false;
  List<Map<String, dynamic>> options = [];
  String selectedPositionKey = "";
  List<Map<String, dynamic>> situations = [];
  bool isLoading = true;
  String pageName = "ExpressionList";
  String currentSituationKey = "";
  @override
  void initState() {
    super.initState();
    loadPosition();
  }

  Future<void> loadPosition() async {
    setState(() {
      isLoading = true;
    });
    SharedPreferences pref = await SharedPreferences.getInstance();
    String customerKey = pref.getString('customerKey');

    db
        .collection("CustomerAccounts")
        .document(customerKey)
        .collection("PositionSelected")
        .where("status", isEqualTo: true)
        .where("isUse", isEqualTo: true)
        .getDocuments()
        .then((data) {
      if (data.documents.length > 0) {
        // กรณีมีการตั้งค่า ตำแหน่งไว้
        List<Map<String, dynamic>> dataFinal = [];
        data.documents.forEach((element) {
          Map<String, dynamic> data = {
            'label': element.data['name'],
            'value': element.documentID
          };
          dataFinal.add(data);
        });
        setState(() {
          options = dataFinal;
          selectedPositionKey = options[0]['value'];
          isLoading = false;
        });
        print(options);
        loadSituation();
      } else {
        db
            .collection("Position")
            .where("status", isEqualTo: true)
            .getDocuments()
            .then((data) {
          List<Map<String, dynamic>> dataFinal = [];
          data.documents.forEach((element) {
            Map<String, dynamic> data = {
              'label': element.data['name'],
              'value': element.documentID
            };
            dataFinal.add(data);
          });
          setState(() {
            options = dataFinal;
            selectedPositionKey = options[0]['value'];
            isLoading = false;
          });
          loadSituation();
        });
      }
    });
  }

  Future<void> loadSituation() async {
    // SharedPreferences pref = await SharedPreferences.getInstance();
    // String customerKey = pref.getString('customerKey');
    setState(() {
      isLoading = true;
    });
    situations = [];
    db
        .collection("Situation")
        .where("positionKey", isEqualTo: selectedPositionKey)
        .snapshots()
        .listen(
      (doc) {
        List<Map<String, dynamic>> dataTemp = [];
        doc.documents.forEach(
          (data) {
            Map<String, dynamic> dataFinal = {"key": data.documentID};
            dataFinal.addAll(data.data);
            dataTemp.add(dataFinal);
          },
        );
        setState(
          () {
            situations = dataTemp;
            isLoading = false;
          },
        );
      },
    );
  }

  Widget positionDropdown() {
    return Container(
      alignment: Alignment.center,
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
              loadSituation();
            });
          },
          value: selectedPositionKey,
        ),
      ),
    );
  }

  Widget mySizeBox() {
    return Container(
      height: 10.0,
    );
  }

  Widget situationWrap() {
    return Container(
      child: Column(
        children: <Widget>[
          // for (var item in situations) situationCard(item)
          for (var i = 0; i < situations.length; i++)
            situationCard(situations[i], i)
        ],
      ),
    );
  }

  Widget situationCard(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        MaterialPageRoute materialPageRoute = MaterialPageRoute(
          builder: (BuildContext buildContext) =>
              Expression(item['key'], selectedPositionKey),
        );
        Navigator.of(context).push(materialPageRoute);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black),
          ),
          color: Colors.blueGrey[800],
        ),
        width: MediaQuery.of(context).size.width,
        child: Container(
          child: Center(
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        child: Text(
                          item['name'],
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        FontAwesomeIcons.chevronRight,
                        color: Colors.teal,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget expressionList() {
    return ListView(
      children: <Widget>[
        positionDropdown(),
        situationWrap(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return ShowLoading();
    } else {
      return Container(
        child: expressionList(),
      );
    }
  }
}
