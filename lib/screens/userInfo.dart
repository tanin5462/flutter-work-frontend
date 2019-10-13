import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/bottomnavigatorbar.dart';
import 'package:flutter_atwork_frontend/screens/loading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

class UserInfo extends StatefulWidget {
  @override
  _UserInfoState createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  // Variable
  final formKey = GlobalKey<FormState>();
  TextEditingController nameController = new TextEditingController();
  String customerName,
      customerSurname,
      customerKey,
      customerPositionKeyDefault,
      customerPassword,
      customerEmail,
      customerSex;
  bool isLoading = true;
  List<String> sexOptions = ['ชาย', 'หญิง'];
  String selectedSex;
  Firestore db = Firestore.instance;

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
      isLoading = false;
      customerPassword = prefs.getString('customerPassword');
      customerEmail = prefs.getString('customerEmail');
      customerSex = prefs.getString('customerSex');
      selectedSex = prefs.getString('customerSex');
    });
  }

  Future<void> saveEdit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      isLoading = true;
    });
    formKey.currentState.save();
    // print(
    //     "name= $customerName surname = $customerSurname password = $customerPassword email = $customerEmail sex = $customerSex");
    db.collection("CustomerAccounts").document(customerKey).updateData({
      'name': customerName,
      'surname': customerSurname,
      'password': customerPassword,
      'email': customerEmail,
      'sex': selectedSex
    }).then((res) {
      setState(() {
        prefs.setString('customerName', customerName);
        prefs.setString('customerSurname', customerSurname);
        prefs.setString('customerSex', selectedSex);
        prefs.setString('customerEmail', customerEmail);
        prefs.setString('customerPassword', customerPassword);
        isLoading = false;
      });
    });
  }

  // WIDGET
  Widget showUserInfo() {
    return ListView(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              headerText(),
              Container(
                height: 20,
              ),
              userForm(),
            ],
          ),
        ),
      ],
    );
  }

  Widget headerText() {
    return Text(
      "แก้ไขข้อมูลส่วนตัว",
      style: TextStyle(color: Colors.white, fontSize: 20),
    );
  }

  Widget myGutter() {
    return Container(
      height: 10,
    );
  }

  Widget userForm() {
    return Form(
      child: Column(
        children: <Widget>[
          nameTextBox(),
          myGutter(),
          surnameTextBox(),
          myGutter(),
          passwordTextBox(),
          myGutter(),
          emailTextBox(),
          myGutter(),
          sexDropdown(),
          myGutter(),
          showButton(),
        ],
      ),
      key: formKey,
    );
  }

  Widget nameTextBox() {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        initialValue: customerName,
        decoration: InputDecoration(labelText: "ชื่อ"),
        onSaved: (value) {
          customerName = value.trim();
        },
      ),
    );
  }

  Widget surnameTextBox() {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        initialValue: customerSurname,
        decoration: InputDecoration(labelText: "นามสกุล"),
        onSaved: (value) {
          customerSurname = value.trim();
        },
      ),
    );
  }

  Widget passwordTextBox() {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        initialValue: customerPassword,
        decoration: InputDecoration(labelText: "รหัสผ่าน"),
        onSaved: (value) {
          customerPassword = value.trim();
        },
      ),
    );
  }

  Widget emailTextBox() {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: TextFormField(
        initialValue: customerEmail,
        decoration: InputDecoration(labelText: "E-mail"),
        onSaved: (value) {
          customerEmail = value.trim();
        },
      ),
    );
  }

  Widget sexDropdown() {
    return Container(
      padding: EdgeInsets.only(left: 8, right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButton(
        isExpanded: true,
        icon: Icon(
          FontAwesomeIcons.chevronDown,
          size: 16,
        ),
        items: sexOptions.map((item) {
          return DropdownMenuItem(
            child: Text(item),
            value: item,
          );
        }).toList(),
        onChanged: (newval) {
          setState(() {
            selectedSex = newval;
          });
        },
        value: selectedSex,
      ),
    );
  }

  Widget showButton() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          confirmButton(),
          Container(
            width: 20.0,
          ),
          cancleButton(),
        ],
      ),
    );
  }

  Widget cancleButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text("ยกเลิก"),
      ),
    );
  }

  Widget confirmButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        textColor: Colors.white,
        color: Colors.teal,
        onPressed: () {
          saveEdit();
        },
        child: Text("บันทึก"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.blueGrey[900],
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
        body: isLoading ? ShowLoading() : showUserInfo(),
      ),
    );
  }
}
