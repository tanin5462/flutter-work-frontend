import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_atwork_frontend/screens/forgotpassword.dart';
import 'package:flutter_atwork_frontend/screens/main_page.dart';
import 'package:flutter_atwork_frontend/screens/register.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLogin extends StatefulWidget {
  @override
  _MyLoginState createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  // Explicit
  String username, password;
  final formKey = GlobalKey<FormState>();
  bool isShowPassword = true;
  Firestore db = Firestore.instance;
  bool isLoading = false;

  // FUTURE METHODS

  Future<void> login() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      isLoading = true;
    });

    db
        .collection("CustomerAccounts")
        .where("tel", isEqualTo: username)
        .where("password", isEqualTo: password)
        .where("status", isEqualTo: true)
        .getDocuments()
        .then((res) async {
      isLoading = false;
      if (res.documents.length == 1) {
        // User ถูกต้อง
        // print("ถูกต้อง");
        pref.setString('customerKey', res.documents.first.documentID);
        pref.setString('businessKey', res.documents.first.data['businessKey']);
        pref.setString('customerName', res.documents.first.data['name']);
        pref.setString('customerSurname', res.documents.first.data['surname']);
        pref.setString('customerSex', res.documents.first.data['sex']);
        pref.setString('customerUsername', res.documents.first.data['tel']);
        pref.setString('customerEmail', res.documents.first.data['email']);
        pref.setString('customerPositionKeyDefault',
            res.documents.first.data['positionKey']);
        pref.setString(
            'customerPassword', res.documents.first.data['password']);

        MaterialPageRoute materialPageRoute = MaterialPageRoute(
            builder: (BuildContext context) => MyMainPage("0"));
        Navigator.of(context).pushAndRemoveUntil(
            materialPageRoute, (Route<dynamic> route) => false);
      } else {
        // User ไม่ถูกต้อง
        print("Username Password ไม่ถูกต้อง");
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  // MY WIDGET
  Widget logo() {
    return Column(
      children: <Widget>[
        Container(
          width: 100,
          child: Image.asset("images/logo.png"),
        ),
        Text(
          "Winner@Work",
          style:
              TextStyle(letterSpacing: 1.0, color: Colors.white, fontSize: 18),
        )
      ],
    );
  }

  Widget showLoginForm() {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 10.0, right: 10.0),
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            usernameTextBox(),
            mySizeBox(),
            passwordTextBox(),
          ],
        ),
      ),
    );
  }

  Widget usernameTextBox() {
    return Container(
      color: Colors.white,
      child: TextFormField(
        decoration: InputDecoration(
          prefixIcon: Icon(FontAwesomeIcons.userAlt),
          hintText: "Username",
          fillColor: Colors.white,
        ),
        onSaved: (String value) {
          username = value.trim();
        },
      ),
    );
  }

  Widget passwordTextBox() {
    return Container(
      color: Colors.white,
      child: TextFormField(
        obscureText: isShowPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(FontAwesomeIcons.lock),
          hintText: "password",
          fillColor: Colors.white,
          suffixIcon: GestureDetector(
            child: isShowPassword
                ? Icon(FontAwesomeIcons.eyeSlash)
                : Icon(FontAwesomeIcons.eye),
            onTap: () {
              setState(() {
                isShowPassword = !isShowPassword;
              });
            },
          ),
        ),
        onSaved: (String value) {
          password = value.trim();
        },
      ),
    );
  }

  Widget mySizeBox() {
    return Container(
      height: 10,
    );
  }

  Widget loginButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        color: Colors.teal,
        textColor: Colors.white,
        onPressed: () {
          formKey.currentState.save();
          login();
          // MaterialPageRoute materialPageRoute = MaterialPageRoute(
          //   builder: (BuildContext buildContext) => ExpressionList(),
          // );
          // Navigator.of(context).push(materialPageRoute);
        },
        child: Text(
          "เข้าสู่ระบบ",
          style: TextStyle(letterSpacing: 1.0, fontSize: 16.0),
        ),
      ),
    );
  }

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

  Widget forgotPassword() {
    return FlatButton(
      child: Text(
        "ลืมรหัสผ่าน",
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
      onPressed: () {
        MaterialPageRoute materialPageRoute = MaterialPageRoute(
          builder: (BuildContext context) => MyForgotPassword(),
        );
        Navigator.of(context).push(materialPageRoute);
      },
    );
  }

  Widget registerText() {
    return FlatButton(
      child: Text(
        "สมัครสมาชิก",
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.white,
          decoration: TextDecoration.underline,
        ),
      ),
      onPressed: () {
        MaterialPageRoute materialPageRoute = MaterialPageRoute(
          builder: (BuildContext context) => MyRegister(),
        );
        Navigator.of(context).push(materialPageRoute);
      },
    );
  }

  Widget showButtomFont() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          forgotPassword(),
          registerText(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            backgroundImage(),
            isLoading
                ? Loading(
                    indicator: BallPulseIndicator(),
                    size: 100,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        constraints: BoxConstraints(maxWidth: 500),
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[900],
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(15.0),
                          child: Column(
                            children: <Widget>[
                              mySizeBox(),
                              logo(),
                              mySizeBox(),
                              showLoginForm(),
                              mySizeBox(),
                              loginButton(),
                              showButtomFont(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
