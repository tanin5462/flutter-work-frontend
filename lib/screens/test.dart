import 'package:flutter/material.dart';

class MyText extends StatefulWidget {
  final String test;
  const MyText(this.test);
  @override
  _MyTextState createState() => _MyTextState();
}

class _MyTextState extends State<MyText> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("test"),
    );
  }
}
