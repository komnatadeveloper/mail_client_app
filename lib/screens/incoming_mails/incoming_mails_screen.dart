import 'package:flutter/material.dart';

import '../../temporary_files/incoming_dummy_mails.dart';


import '../../layout/app_drawer/app_drawer.dart';
import '../../models/incoming_mail_Item.dart';
import './incoming_mails.dart';

class IncomingMailsScreen extends StatefulWidget {

  @override
  _IncomingMailsScreenState createState() => _IncomingMailsScreenState();
}

class _IncomingMailsScreenState extends State<IncomingMailsScreen> {

  final List<IncomingMailItem> _incomingMailList = dummyIncomingList;


  // Widget iconButton ( BuildContext ctx)   {
  //   return IconButton(
  //     icon: Icon(Icons.format_align_left),
  //     onPressed: () {
  //       Scaffold.of(ctx).openDrawer();
  //     },
  //   );
  // }
  

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.    
    final varAppBar = AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        actions: <Widget> [

          Expanded(

            child: Row(              
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,   

              children: <Widget>[

                // IconButton(
                //   icon: Icon(Icons.format_align_left),
                //   onPressed: () {
                //     Scaffold.of(context).openDrawer();
                //   },
                // ),
                // iconButton(context),

                Text('Incoming'),

                Switch(
                  value: false, 
                  onChanged: (val) {}
                )

              ],
            ),
          ),
        ]
      );


    return Scaffold(
      drawer: AppDrawer(),
      appBar: varAppBar,

      

      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Column(
          
            
          children: <Widget>[
            IncomingMails( _incomingMailList, varAppBar.preferredSize)

          ],

        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {},        
        child: Icon(Icons.edit),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}