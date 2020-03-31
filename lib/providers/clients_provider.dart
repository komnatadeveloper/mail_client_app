import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart' as jiffyPackage;
import 'dart:async';

// For http requests http.dart & convert for json.decode & json.encode
// import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:enough_mail/enough_mail.dart' as enoughMail;


// import 'package:imap_client/imap_client.dart' as imapClient;

import "../environment/vars.dart";
// import 'package:mail_client_app/environment/vars.dart';
import '../models/email_account.dart';

class ClientsProvider with ChangeNotifier { 


  bool _isInitialised = false;
  bool _isInitialising = true;
  List<EmailAccount> _emailAccountList = [];
  List<enoughMail.ImapClient> clientList = [];
  var _isImapClientLogin = false;
  int _accountCount;
  String _preferredMail;
  String _preferredView;
  bool _isLoadingIncoming = false;

  bool get isInitialising {
    return _isInitialising;
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

    // If First Use of App
    if(  !prefs.containsKey( 'komnataMailClient' ) ) {      
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
      final extractedUserData = convert.json.decode(
        prefs.getString('komnataMailClient')
      ) as Map<String, Object>;

      // await prefs.remove('komnataMailClient');

      // final tempAccountList = extractedUserData['accountList'] as List<Map<String, Object>>;

      final tempAccountList = extractedUserData['accountList'] as List;

      print('getInitDataFromDb ${tempAccountList.length} Accounts Exists');
      print(extractedUserData);


      _accountCount = tempAccountList.length;
      if( _accountCount > 0 ) {
        tempAccountList.forEach( (accountItem) {
           _emailAccountList.add(
             EmailAccount(
              emailAddress: accountItem['email'],
              emailPassword: accountItem['password'],
              incomingMailsServer: accountItem['incomingServer'],
              incomingMailsPort: accountItem['port'],
            )
          );
        } );
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
      _emailAccountList.forEach( (account) async {


        var client  = enoughMail.ImapClient(isLogEnabled: true);

        client.connectToServer(
          account.incomingMailsServer, 
          int.parse(account.incomingMailsPort), 
          isSecure: true
        )
          .then( ( _ ) {

            client.login(
              account.emailAddress, 
              account.emailPassword
            ).then( (loginResponse) {
              if (  !loginResponse.isOkStatus ) {
                print('Auth Error of ${account.emailAddress}');
              } else {

                client.listMailboxes()
                  .then((listResponse) {
                    // Select MailBox
                    client.selectMailbox( listResponse.result[0])
                      .then( (_3) {
                        // Add to Client List
                        clientList.add(client);
                        // notifyListeners();
                        print('Client ${account.emailAddress} has been added to clientList');       

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
    if( _accountCount > 0 )  {
      for( int i = 0; i < _accountCount; i++ ) {
        var account = _emailAccountList[i];
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
          clientList.add(client);
          print('Client ${account.emailAddress} has been added to clientList'); 
        } // end of else
      } // End of For Loop

        
    }  // Enf of if _accountCount > 0
    print('connectAllAccounts method has finished');
    // notifyListeners();
  }


  Future<enoughMail.ImapClient> connectClientToServer (
    EmailAccount accountToConnect
  ) async {
    var client  = enoughMail.ImapClient(isLogEnabled: true);
    // await client.connectToServer(incomingServer1, portNo1, isSecure: true);
    // var loginResponse = await client.login(mailAddress1, mailPassword1);
    // var client  = enoughMail.ImapClient(isLogEnabled: true);
    var portInt = int.parse(accountToConnect.incomingMailsPort);
    var socket  = await client.connectToServer(
      accountToConnect.incomingMailsServer, 
      portInt, 
      isSecure: true
    );
    print(client.toString());
    var loginResponse = await client.login(
      accountToConnect.emailAddress, 
      accountToConnect.emailPassword
    );
    if (  !loginResponse.isOkStatus ) {
      print('Auth Error');
      return null;
    } else {
      clientList.add(client);
      notifyListeners();
      print('Client ${accountToConnect.emailAddress} has been added to clientList');
      return client;
    }
  }

}