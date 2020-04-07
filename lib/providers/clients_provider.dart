import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' as convert;
import 'package:enough_mail/enough_mail.dart' as enoughMail;


import '../models/email_account.dart';
import '../models/client_item_model.dart';

class ClientsProvider with ChangeNotifier { 


  bool _isInitialised = false;
  bool _isInitialising = true;
  List<EmailAccount> _emailAccountList = [];
  List<ClientItem> _clientList = [];
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

  List<ClientItem> get clientList {
    return _clientList;
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
        .then( ( _x2 ) {
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


    } else {  // NOT FIRST USE OF APP 
      final extractedUserData = convert.json.decode(
        prefs.getString('komnataMailClient')
      ) as Map<String, Object>;

      // await prefs.remove('komnataMailClient');
      // return;

      final tempAccountList = extractedUserData['accountList'] as List;
      // print('getInitDataFromDb ${tempAccountList.length} Accounts Exists');

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
          _clientList.add( clientItem );
        });
      }
      _preferredMail = extractedUserData['preferredMail'];
      _preferredView = extractedUserData['preferredView'];

    }
    // notifyListeners();
    // print('End of getInitDataFromDb');
  }  // End of getInitDataFromDb



  Future<void> connectAndAddAllAccounts1() async {
    print('connectAllAccounts method RUNNING');
    if( _clientList.length > 0 )  {
      for( int i = 0; i < _clientList.length; i++ ) {
        var account = _clientList[i].emailAccount;
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
          _clientList[i].imapClient = client;
          _clientList[i].emailAccount.lastConnectionTime = DateTime.now();
          print('Client ${account.emailAddress} has been added to clientList'); 
        } // end of else
      } // End of For Loop

        
    }  // Enf of if _accountCount > 0
    print('connectAllAccounts method has finished');
    // notifyListeners();
  }

  

}  // End of ClientsProvider