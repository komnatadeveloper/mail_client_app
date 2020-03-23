import 'package:flutter/material.dart';

import '../settings/settings_screen.dart';

class AccountsScreen extends StatelessWidget {
  static const routeName = '/accounts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      // APPBAR
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                SettingsScreen.routeName
              );
            },
          ),
          Expanded(

            child: Center(
              child: Text(
                'Accounts'
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(
                  color: Colors.grey,
                  width: 0.2
                ))
              ),
              // color: Theme.of(context).backgroundColor,
              child: ListTile(
                title: Text(
                  'komnatadeveloper@gmail.com',
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
                  // Navigator.of(context).pushReplacementNamed(
                  //   AccountsScreen.routeName
                  // );
                },
              ),
            ),
            Container(
              color: Theme.of(context).backgroundColor,
              child: ListTile(
                title: Text(
                  'komnatadeveloper@gmail.com',
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
                  // Navigator.of(context).pushReplacementNamed(
                  //   AccountsScreen.routeName
                  // );
                },
              ),
            ),
            Divider(),

            RaisedButton(
              child: Container(
                width: (MediaQuery.of(context).size.width - 50),
                alignment: Alignment.center,
                child: Text(
                  'Add Account',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.title.color
                  ),
                ),
              ),
              color: Colors.blue,              
              

              onPressed: () {

              },
              
              
            )
          ],
        ),
      ),
    );
  }
}