import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../accounts/accounts_screen.dart';
import '../../models/email_account.dart';
import '../../providers/mail_connection_provider.dart';



class AddExchangeAccountScreen extends StatefulWidget {
  static const routeName = '/add-exchange-account';

  @override
  _AddExchangeAccountScreenState createState() => _AddExchangeAccountScreenState();
}

// STATE
class _AddExchangeAccountScreenState extends State<AddExchangeAccountScreen> {


  var _initValues = {
    'emailAddress': '',
    'emailPassword': '',
    'incomingMailsServer': '',
    'incomingMailsPort': '',
    'outgoingMailsServer': '',
    'outgoingMailsPort': ''
  };

  var _editedEmailAccount = EmailAccount(
    emailAddress: '',
    emailPassword: '',
    senderName: '',
    incomingMailsServer: '',
    incomingMailsPort: '',
    outgoingMailsServer: '',
    outgoingMailsPort: '',
  );

  final _emailAddress = FocusNode();
  final _emailPassword = FocusNode();
  final _senderName = FocusNode();
  final _incomingMailsServer = FocusNode();
  final _incomingMailsPort = FocusNode();
  final _outgoingMailsServer = FocusNode();
  final _outgoingMailsPort = FocusNode();

  final _formGlobalKey = GlobalKey<FormState>();

  Future <void> _saveForm (  ) async {
    // final isValid = _formGlobalKey.currentState.validate();
    // if( !isValid ) {
    //   return;
    // }

    _formGlobalKey.currentState.save(); 

    // print(_editedEmailAccount.emailAddress);

    Provider.of<MailConnectionProvider>(context).addAccount( _editedEmailAccount );

  }  // end of _saveForm

  // @override
  // void didChangeDependencies() {
  //   _it
    
  //   super.didChangeDependencies();
  // }  // End of didChangeDependencies

  @override
  void dispose() {
    _emailAddress.dispose();
    _emailPassword.dispose();
    _senderName.dispose();
    _incomingMailsServer.dispose();
    _incomingMailsPort.dispose();
    _outgoingMailsServer.dispose();
    _outgoingMailsPort.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        // backgroundColor: Theme.of(context).backgroundColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.keyboard_arrow_left),
            onPressed: () {
              Navigator.of(context).pushReplacementNamed(
                AccountsScreen.routeName
              );
            },
          ),
          Expanded(

            child: Center(
              child: Text(
                'Exchange Account'
              ),
            ),
          ),
        ],
      ),

      body: Form(
        key: _formGlobalKey,

        child: SingleChildScrollView(
                  child: Container(
                    
                    child: Column(
                      children: <Widget>[                      

                        // EMAIL ADDRESS
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(
                              color: Colors.grey
                            ),
                            
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color
                          ),
                          focusNode: _emailAddress,
                          onFieldSubmitted: ( _ ) {
                            FocusScope.of(context).requestFocus( _emailPassword );
                          },
                          onSaved: ( value ) {
                            _editedEmailAccount = EmailAccount(
                              emailAddress: value,
                              emailPassword: _editedEmailAccount.emailPassword,
                              senderName: _editedEmailAccount.senderName,
                              incomingMailsServer: _editedEmailAccount.incomingMailsServer,
                              incomingMailsPort: _editedEmailAccount.incomingMailsPort,
                              outgoingMailsServer: _editedEmailAccount.outgoingMailsServer,
                              outgoingMailsPort: _editedEmailAccount.outgoingMailsPort,
                            );
                          },

                        ),

                        // PASSWORD
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(
                              color: Colors.grey
                            ),
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none
                            
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color
                          ),
                          focusNode: _emailPassword,
                          onSaved: ( value ) {
                            _editedEmailAccount = EmailAccount(
                              emailAddress: _editedEmailAccount.emailAddress,
                              emailPassword: value,
                              senderName: _editedEmailAccount.senderName,
                              incomingMailsServer: _editedEmailAccount.incomingMailsServer,
                              incomingMailsPort: _editedEmailAccount.incomingMailsPort,
                              outgoingMailsServer: _editedEmailAccount.outgoingMailsServer,
                              outgoingMailsPort: _editedEmailAccount.outgoingMailsPort,
                            );
                          },
                          
                        ),

                        // YOUR NAME
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Your Name',
                            labelStyle: TextStyle(
                              color: Colors.grey
                            ),
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none
                            
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color
                          ),
                          focusNode: _senderName,
                          onSaved: ( value ) {
                            _editedEmailAccount = EmailAccount(
                              emailAddress: _editedEmailAccount.emailAddress,
                              emailPassword: _editedEmailAccount.emailPassword,
                              senderName: value,
                              incomingMailsServer: _editedEmailAccount.incomingMailsServer,
                              incomingMailsPort: _editedEmailAccount.incomingMailsPort,
                              outgoingMailsServer: _editedEmailAccount.outgoingMailsServer,
                              outgoingMailsPort: _editedEmailAccount.outgoingMailsPort,
                            );
                          },
                          
                        ),

                        // Incoming Mail Settings Title
                        Text(
                          'Incoming Mail Settings',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color 
                          ),
                        ),

                        // Incoming Mails Server
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Incoming Mails Server',
                            labelStyle: TextStyle(
                              color: Colors.grey
                            ),
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none
                            
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color
                          ),
                          focusNode: _incomingMailsServer,
                          onSaved: ( value ) {
                            _editedEmailAccount = EmailAccount(
                              emailAddress: _editedEmailAccount.emailAddress,
                              emailPassword: _editedEmailAccount.emailPassword,
                              senderName: _editedEmailAccount.senderName,
                              incomingMailsServer: value,
                              incomingMailsPort: _editedEmailAccount.incomingMailsPort,
                              outgoingMailsServer: _editedEmailAccount.outgoingMailsServer,
                              outgoingMailsPort: _editedEmailAccount.outgoingMailsPort,
                            );
                          },
                          
                          
                        ),

                        // Incoming Mails Port
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Incoming Mails Port',
                            labelStyle: TextStyle(
                              color: Colors.grey
                            ),
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none
                            
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color
                          ),
                          focusNode: _incomingMailsPort,
                          onSaved: ( value ) {
                            _editedEmailAccount = EmailAccount(
                              emailAddress: _editedEmailAccount.emailAddress,
                              emailPassword: _editedEmailAccount.emailPassword,
                              senderName: _editedEmailAccount.senderName,
                              incomingMailsServer: _editedEmailAccount.incomingMailsServer,
                              incomingMailsPort: value,
                              outgoingMailsServer: _editedEmailAccount.outgoingMailsServer,
                              outgoingMailsPort: _editedEmailAccount.outgoingMailsPort,
                            );
                          },
                          
                        ),

                        // Outgoing Mail Settings Title
                        Text(
                          'Outgoing Mail Settings',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color 
                          ),
                        ),

                        // Outgoing Mails Server
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Outgoing Mails Server',
                            labelStyle: TextStyle(
                              color: Colors.grey
                            ),
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none
                            
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color
                          ),
                          focusNode: _outgoingMailsServer,
                          onSaved: ( value ) {
                            _editedEmailAccount = EmailAccount(
                              emailAddress: _editedEmailAccount.emailAddress,
                              emailPassword: _editedEmailAccount.emailPassword,
                              senderName: _editedEmailAccount.senderName,
                              incomingMailsServer: _editedEmailAccount.incomingMailsServer,
                              incomingMailsPort: _editedEmailAccount.incomingMailsPort,
                              outgoingMailsServer: value,
                              outgoingMailsPort: _editedEmailAccount.outgoingMailsPort,
                            );
                          },
                          
                          
                        ),

                        // Outgoing Mails Port
                        TextFormField(
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            labelText: 'Outgoing Mails Port',
                            labelStyle: TextStyle(
                              color: Colors.grey
                            ),
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none
                            
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.title.color
                          ),
                          focusNode: _outgoingMailsPort,
                          onSaved: ( value ) {
                            _editedEmailAccount = EmailAccount(
                              emailAddress: _editedEmailAccount.emailAddress,
                              emailPassword: _editedEmailAccount.emailPassword,
                              senderName: _editedEmailAccount.senderName,
                              incomingMailsServer: _editedEmailAccount.incomingMailsServer,
                              incomingMailsPort: _editedEmailAccount.incomingMailsPort,
                              outgoingMailsServer: _editedEmailAccount.outgoingMailsServer,
                              outgoingMailsPort: value,
                            );
                          },
                          
                        ),

                        // ADD ACCOUNT BUTTON
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
                

                onPressed: ()  async {
                  // Provider.of<MailConnectionProvider>(context).getMails();
                  // Provider.of<MailConnectionProvider>(context).getMailsByImapClient2();
                  // Provider.of<MailConnectionProvider>(context).getMailsByImapClient2();

                  // Navigator.of(context).pushReplacementNamed(
                  //   AddExchangeAccountScreen.routeName
                  // );



                  _saveForm();

                },
                
                
              ),




                      ],
                    ),
                  ),

                ),
      ),


      
    );
  }
}