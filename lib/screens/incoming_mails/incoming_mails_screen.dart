import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mail_connection_provider.dart';
import '../../providers/clients_provider.dart';

import '../../layout/app_drawer/app_drawer.dart';
import './incoming_mails.dart';
import './new_email_bottom_sheet.dart';



class IncomingMailsScreen extends StatefulWidget {
  static const routeName = '/incoming-mails';

  
  void _startSendNewEmail( BuildContext ctx ) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.90,
          child: NewEmailBottomSheet(),
        );
      }
    );
  } 
  @override
  _IncomingMailsScreenState createState() => _IncomingMailsScreenState();
}


// STATE
class _IncomingMailsScreenState extends State<IncomingMailsScreen> {
  var _isInited = false;

  @override
  void didChangeDependencies() {
    
    // IncomingMailsScreen not Inited & Clients Provider ALREADY INITIALISED (not isInitialising)
    if( !_isInited 
      && !Provider.of<ClientsProvider>(context).isInitialising 
      && !Provider.of<MailConnectionProvider>(context).mailConnectionProviderStatus.isIncomingMailsScreenInitialised  
      ) {
      Provider.of<MailConnectionProvider>(context, listen: false).getAllHeaders()
        .then( (_) {
          setState(() {
            _isInited = true;
            Provider.of<MailConnectionProvider>(context, listen: false).makeIncomingMailsScreenInitialised();
          });          
      });        
    } // end of if

    if( 
      !_isInited 
      && !Provider.of<ClientsProvider>(context).isInitialising 
      && Provider.of<MailConnectionProvider>(context).mailConnectionProviderStatus.isIncomingMailsScreenInitialised 
     ) {
       Provider.of<MailConnectionProvider>(context,listen: false).checkandAddNewHeaders()
        .then( ( _ ) {
          setState(() {
            _isInited = true;
          });
        });
     }
    super.didChangeDependencies();
  }  // end of didChangeDependencies
  

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
              Text('Incoming'),
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
            ( 
              !_isInited 
              && !Provider.of<MailConnectionProvider>(context).mailConnectionProviderStatus.isIncomingMailsScreenInitialised 
            )
              ? Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
              : IncomingMails( 
                varAppBar.preferredSize ,
                _isInited
              ) 
              

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