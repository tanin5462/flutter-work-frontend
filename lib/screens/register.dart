import 'package:flutter/material.dart';

class MyRegister extends StatefulWidget {
  @override
  _MyRegisterState createState() => _MyRegisterState();
}

class _MyRegisterState extends State<MyRegister> {
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

  Widget headerLogo() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      child: Image.asset("images/callcenter.png"),
    );
  }

  Widget boxContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey[900],
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: Column(
        children: <Widget>[
          Text(
            "กรุณาติดต่อผู้ประสานงาน",
            style: TextStyle(
                color: Colors.white, letterSpacing: 1.0, fontSize: 18.0),
          ),
          Text(
            "หรือติดต่อเจ้าหน้าที่",
            style: TextStyle(
                color: Colors.white, letterSpacing: 1.0, fontSize: 18.0),
          ),
          Text(
            "โทร 099-999-9999",
            style: TextStyle(
                color: Colors.white, letterSpacing: 1.0, fontSize: 18.0),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("สมัครสมาชิก"),
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
    ));
  }
}
