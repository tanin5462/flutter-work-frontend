import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class ShowLoading extends StatefulWidget {
  @override
  _ShowLoadingState createState() => _ShowLoadingState();
}

class _ShowLoadingState extends State<ShowLoading> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Loading(indicator: BallPulseIndicator(), size: 100.0),
    );
  }
}
