import 'package:flutter/material.dart';

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
              Scaffold.of(context).openDrawer();
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