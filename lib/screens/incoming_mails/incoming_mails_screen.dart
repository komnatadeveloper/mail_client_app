import 'package:flutter/material.dart';

import '../../temporary_files/incoming_dummy_mails.dart';


import '../../layout/app_drawer/app_drawer.dart';
import '../../models/incoming_mail_Item.dart';
import './incoming_mails.dart';

import './new_email_bottom_sheet.dart';

class IncomingMailsScreen extends StatefulWidget {
  static const routeName = '/incoming-mails';

  // void _startSendNewEmail( BuildContext ctx ) {
  //   showModalBottomSheet(
  //     context: ctx, 
  //     builder: ( _ ) {
  //       return NewEmailBottomSheet();

  //     }
  //   );

  // void _startSendNewEmail( BuildContext ctx ) {
  //   showModalBottomSheet(
  //           context: ctx,
  //           builder: (BuildContext ctx) {
  //             return DraggableScrollableSheet(
  //               initialChildSize: 0.5,
  //               maxChildSize: 1,
  //               minChildSize: 0.25,
  //               builder:
  //                   (BuildContext context, ScrollController scrollController) {
  //                 return Container(
  //                   color: Colors.white,
  //                   child: ListView.builder(
  //                     controller: scrollController,
  //                     itemCount: 25,
  //                     itemBuilder: (BuildContext context, int index) {
  //                       return ListTile(title: Text('Item $index'));
  //                     },
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         );
  // }
  void _startSendNewEmail( BuildContext ctx ) {
    showModalBottomSheet(
        context: ctx,
        isScrollControlled: true,
        builder: (context) {
          return FractionallySizedBox(
            heightFactor: 0.90,
            child: NewEmailBottomSheet(),
          );
        });
  }

  // void _startSendNewEmail( BuildContext ctx ) {
  //   showDialog(
  //     context: ctx, 
  //     builder: ( ctx ) {
  //       return Material(


  //         child: Container(
  //           width: MediaQuery.of(ctx).size.width,
  //           height: (MediaQuery.of(ctx).size.height - 200.00),
  //           color: Theme.of(ctx).backgroundColor,

  //           child: SingleChildScrollView(
  //             child: IconButton(
  //               icon: Icon(Icons.close),
  //               onPressed: () {
                  
  //               },
  //             ),
  //           ),
  //         ),
  //       );

  //     }
  //   );
  // }

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
            IncomingMails( varAppBar.preferredSize )

          ],

        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget._startSendNewEmail(context);
        },        
        child: Icon(Icons.edit),
      ), // This trailing comma makes auto-formatting nicer for build methods.

    );
  }
}