import 'package:flutter/material.dart';

import '../incoming_mails/incoming_mails_screen.dart';
import '../accounts/accounts_screen.dart';

class SettingsScreen extends StatelessWidget {

  static const routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // APPBAR
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                IncomingMailsScreen.routeName
              );
            },
          ),
          Expanded(

            child: Center(
              child: Text(
                'Settings'
              ),
            ),
          ),
        ],
      ),

      body: Container(
        color: Theme.of(context).backgroundColor ,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Container(
                  child: ListTile(
                    leading: Icon(
                      Icons.account_box,
                      color: Colors.blue
                    ),
                    title: Text(
                      'Accounts',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right,
                      color: Theme.of(context).textTheme.title.color,
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed(
                        AccountsScreen.routeName
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),


      
    );
  }
}