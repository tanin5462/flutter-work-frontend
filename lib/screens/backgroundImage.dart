import 'package:flutter/material.dart';

class BackgroundImage extends StatefulWidget {
  @override
  _BackgroundImageState createState() => _BackgroundImageState();
}

class _BackgroundImageState extends State<BackgroundImage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        image: new DecorationImage(
          image: new AssetImage("images/bg-dark.jpg"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
