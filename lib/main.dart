import 'package:flutter/material.dart';
import 'package:mail_client_app/screens/settings/settings_screen.dart';


import './screens/incoming_mails/incoming_mails_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // primarySwatch: Colors.black.[400],
        textTheme: ThemeData.light().textTheme.copyWith(

          title: TextStyle(
            color: Colors.white
          ),

          // headline1: TextStyle(
          //   color: Colors.white
          // )
        ),
        backgroundColor: Color.fromARGB(240, 20, 20, 20)
      ),
      home: IncomingMailsScreen(),
      routes: {
        SettingsScreen.routeName : (ctx) => SettingsScreen()
      }
    );
  }
}


