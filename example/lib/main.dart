import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nefect_video_player/nefect_video_player.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red,
        body: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: double.infinity,
                height: 234,
                child: NeVideoPlayer(
                  onPlatformViewCreated: (int id) {},
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
