import 'package:flutter/material.dart';
import 'package:mail_client_app/models/incoming_mail_Item.dart';
import './widgets/incoming_mails.dart';

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

          headline1: TextStyle(
            color: Colors.white
          )
        ),
        backgroundColor: Color.fromARGB(240, 20, 20, 20)
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final List<IncomingMailItem> _incomingMailList = [
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 5)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, pleas1'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 6)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, please login your account'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 7)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, please'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 7)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, please'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 7)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, please'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 5)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, pleas1'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 6)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, please login your account'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 7)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, please'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 7)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, please'
    ),
    IncomingMailItem(
      date: DateTime.now().subtract(Duration(hours: 7)),
      senderName: 'Facebook',
      emailTitle: 'John Doe has commented on your Post',
      emailBody: 'John Doe has commented on your post. To view details, please'
    ),
  ];
  

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        actions: <Widget> [

          Expanded(

            child: Row(              
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,   

              children: <Widget>[

                IconButton(
                  icon: Icon(Icons.format_align_left),
                  onPressed: () {},
                ),

                Text('Incoming'),

                Switch(
                  value: false, 
                  onChanged: (val) {}
                )

              ],
            ),
          ),
        ]
      ),

      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Column(
          
            
          children: <Widget>[
            IncomingMails( _incomingMailList)

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
