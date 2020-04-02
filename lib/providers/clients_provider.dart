import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart' as intl;
// import 'package:jiffy/jiffy.dart' as jiffyPackage;
import 'dart:convert' as convert;
import 'package:enough_mail/enough_mail.dart' as enoughMail;

// For http requests http.dart & convert for json.decode & json.encode
// import 'package:http/http.dart' as http;



// import 'package:imap_client/imap_client.dart' as imapClient;

import "../environment/vars.dart";
// import 'package:mail_client_app/environment/vars.dart';
import '../models/email_account.dart';
import '../models/client_item_model.dart';

class ClientsProvider with ChangeNotifier { 


  bool _isInitialised = false;
  bool _isInitialising = true;
  List<EmailAccount> _emailAccountList = [];
  List<ClientItem> clientList = [];
  var _isImapClientLogin = false;
  int _accountCount;
  String _preferredMail;
  String _preferredView;
  bool _isLoadingIncoming = false;

  bool get isInitialising {
    return _isInitialising;
  }
  List<EmailAccount> get emailAccountList {
    return _emailAccountList;
  }
  bool get isImapClientLogin {
    return _isImapClientLogin;
  }
  int get accountCount {
    return _accountCount;
  }
  String get preferredMail {
    return _preferredMail;
  }
  String get preferredView {
    return _preferredView;
  }

  

  bool get isLoadingIncoming {
    return _isLoadingIncoming;
  }
  bool get isInitialised {
    return _isInitialised;
  }

  // ---------End of Getters-----





  Future<void> initialiseApp () async {   


    getInitDataFromDb()
    .then(( _ ) {
      connectAndAddAllAccounts1()
        .then( ( _2 ) {
          _isInitialising = false;
          print('Client List Length: ${clientList.length}');
          print('_isInitialising is set to FALSE');
          notifyListeners();
        });
    });  
  }  // End of initialiseApp


  // Get Initial Data From Device
  Future<void> getInitDataFromDb ()  async{
    final prefs = await SharedPreferences.getInstance();
    print('GET INIT DATA FROM DB');

    // If First Use of App
    if(  !prefs.containsKey( 'komnataMailClient' ) ) {    
      print('FIRST USE OF APP');  

      final logToAdd = convert.json.encode( { 
        'accountList': [],
        'preferredView': 'inbox',  //  'inbox' 'sent' 'viewed' 'archieve' 'trash'
        'preferredMail': 'all'  // "mailAddress" or "all"
      });
      prefs.setString('komnataMailClient', logToAdd);

      _accountCount = 0;
      _preferredMail = 'inbox';
      _preferredView = 'all';


    } else {
      print('NOT FIRST USE OF APP');  
      final extractedUserData = convert.json.decode(
        prefs.getString('komnataMailClient')
      ) as Map<String, Object>;

      print('LETS PRINT EXTRACTED USER DATA komnataMailClient from Shared Prefs');
      print(extractedUserData);

      // await prefs.remove('komnataMailClient');
      // return;

      // final tempAccountList = extractedUserData['accountList'] as List<Map<String, Object>>;

      final tempAccountList = extractedUserData['accountList'] as List;

      print('getInitDataFromDb ${tempAccountList.length} Accounts Exists');


      _accountCount = tempAccountList.length;
      if( _accountCount > 0 ) {
        tempAccountList.forEach( (accountItem) {

          var clientItem = new  ClientItem(
            emailAccount: null,
            imapClient: null
          );
          var newAccount = EmailAccount(
              senderName: accountItem['senderName'],
              emailAddress: accountItem['email'],
              emailPassword: accountItem['password'],
              incomingMailsServer: accountItem['incomingServer'],
              incomingMailsPort: accountItem['incomingPort'],
              outgoingMailsServer: accountItem['outgoingServer'],
              outgoingMailsPort: accountItem['outgoingPort'],
          );
          clientItem.emailAccount = newAccount;      
          clientList.add( clientItem );
        });
      }
      _preferredMail = extractedUserData['preferredMail'];
      _preferredView = extractedUserData['preferredView'];

    }
    // notifyListeners();
    print('End of getInitDataFromDb');
  }  // End of getInitDataFromDb



  Future<void> connectAndAddAllAccounts() async {
    print('connectAllAccounts method RUNNING');
    if( _accountCount > 0 )  {
      clientList.forEach( (clientItem) async {


        var client  = enoughMail.ImapClient(isLogEnabled: true);

        client.connectToServer(
          clientItem.emailAccount.incomingMailsServer, 
          int.parse(clientItem.emailAccount.incomingMailsPort), 
          isSecure: true
        )
          .then( ( _ ) {

            client.login(
              clientItem.emailAccount.emailAddress, 
              clientItem.emailAccount.emailPassword
            ).then( (loginResponse) {
              if (  !loginResponse.isOkStatus ) {
                print('Auth Error of ${clientItem.emailAccount.emailAddress}');
              } else {

                client.listMailboxes()
                  .then((listResponse) {
                    // Select MailBox
                    client.selectMailbox( listResponse.result[0])
                      .then( (_3) {
                        // Add to Client List
                        clientItem.imapClient = client;
                        // clientList.add(client);
                        // notifyListeners();
                        print('Client ${clientItem.emailAccount.emailAddress} has been added to clientList');       

                      });  // After selectMailBox
                  });  // After ListMailBoxes   
              }  // end of else 

            }); // After login
          }); // After connectToServer

      });  // emailAccountList for Each
        
    }  // Enf of if _accountCount > 0
    print('connectAllAccounts method has finished');
    // notifyListeners();
  }


  Future<void> connectAndAddAllAccounts1() async {
    print('connectAllAccounts method RUNNING');
    if( clientList.length > 0 )  {
      for( int i = 0; i < clientList.length; i++ ) {
        var account = clientList[i].emailAccount;
        var client  = enoughMail.ImapClient(isLogEnabled: true);

        await client.connectToServer(
          account.incomingMailsServer, 
          int.parse(account.incomingMailsPort), 
          isSecure: true
        );

        var loginResponse = await client.login(
          account.emailAddress, 
          account.emailPassword
        );

        if (  !loginResponse.isOkStatus ) {
          print('Auth Error of ${account.emailAddress}');
        } else {

          // var listResponse = await client.listMailboxes();
          // // Select MailBox
          // await client.selectMailbox( listResponse.result[0]);
          clientList[i].imapClient = client;
          print('Client ${account.emailAddress} has been added to clientList'); 
        } // end of else
      } // End of For Loop

        
    }  // Enf of if _accountCount > 0
    print('connectAllAccounts method has finished');
    // notifyListeners();
  }


  // Future<enoughMail.ImapClient> connectClientToServer (
  //   EmailAccount accountToConnect
  // ) async {
  //   var client  = enoughMail.ImapClient(isLogEnabled: true);
  //   // await client.connectToServer(incomingServer1, portNo1, isSecure: true);
  //   // var loginResponse = await client.login(mailAddress1, mailPassword1);
  //   // var client  = enoughMail.ImapClient(isLogEnabled: true);
  //   var portInt = int.parse(accountToConnect.incomingMailsPort);
  //   var socket  = await client.connectToServer(
  //     accountToConnect.incomingMailsServer, 
  //     portInt, 
  //     isSecure: true
  //   );
  //   print(client.toString());
  //   var loginResponse = await client.login(
  //     accountToConnect.emailAddress, 
  //     accountToConnect.emailPassword
  //   );
  //   if (  !loginResponse.isOkStatus ) {
  //     print('Auth Error');
  //     return null;
  //   } else {
  //     clientList.add(client);
  //     notifyListeners();
  //     print('Client ${accountToConnect.emailAddress} has been added to clientList');
  //     return client;
  //   }
  // }

}