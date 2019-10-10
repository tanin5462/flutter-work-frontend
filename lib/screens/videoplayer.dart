import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayer extends StatefulWidget {
  final String videoURL;
  VideoPlayer({Key key, this.videoURL}) : super(key: key);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  // Explicit
  String urlVideo = '';
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  // Methods

  @override
  void initState() {
    super.initState();
    setState(() {
      videoPlayerController = VideoPlayerController.network(widget.videoURL);
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,
      );
    });
  }

  @override
  // dispose หมายถึง destroy package ทั้งหมดในหน้านี้เมื่อกด back หรือปิด
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    chewieController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: chewieController,
    );
  }
}
