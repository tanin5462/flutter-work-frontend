import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MyForgotPassword extends StatefulWidget {
  @override
  _MyForgotPasswordState createState() => _MyForgotPasswordState();
}

class _MyForgotPasswordState extends State<MyForgotPassword> {
  // EXPLICIT
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

  Widget mySizeBox() {
    return Container(
      height: 10,
    );
  }

  Widget headerLogo() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Image.asset("images/forgotPassword.png"),
    );
  }

  Widget boxContainer() {
    return Container(
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          emailTextBox(),
          mySizeBox(),
          sendEmail(),
          mySizeBox(),
          Text(
            "หรือติดต่อเจ้าหน้าที่โทร 099--999-9999",
            style: TextStyle(
                color: Colors.white, letterSpacing: 1.0, fontSize: 14.0),
          )
        ],
      ),
    );
  }

  Widget emailTextBox() {
    return Container(
      padding: EdgeInsets.only(left: 15.0, right: 15.0),
      color: Colors.white,
      child: TextFormField(
        decoration: InputDecoration(
          hintText: "กรอก E-mail เพื่อขอรับรหัสผ่านใหม่",
          prefixIcon: Icon(FontAwesomeIcons.mailBulk),
        ),
      ),
    );
  }

  Widget sendEmail() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: RaisedButton(
        textColor: Colors.white,
        color: Colors.teal,
        onPressed: () {},
        child: Text(
          "ส่ง",
          style: TextStyle(
            letterSpacing: 1.0,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("ลืมรหัสผ่าน"),
        ),
        body: Container(
          child: Stack(
            children: <Widget>[
              backgroundImage(),
              Container(
                padding: EdgeInsets.all(15.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      headerLogo(),
                      boxContainer(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
