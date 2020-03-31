import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {

  final String text;

  SplashScreen(this.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(text),
      ),
    );
  }
}