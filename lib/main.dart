import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:qrollcall/pages/main_app.dart';

void main() {
  runApp(MaterialApp(
      home: AnimatedSplashScreen(
    splash: ClipOval(
      child: Image.asset(
        'assets/images/qrollcall-logo.jpeg',
        fit: BoxFit.cover,
      ),
    ),
    nextScreen: const MainApp(),
  )));
}
