import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiffy/jiffy.dart' as jiffyPackage;
import 'package:enough_mail/enough_mail.dart' as enoughMail;
import 'package:mailer2/mailer.dart' as mailer2;

// For http requests http.dart & convert for json.decode & json.encode
// import 'package:http/http.dart' as http;
import 'dart:convert' as convert;


import 'package:mail_client_app/models/email_item_model.dart';

// import 'package:imap_client/imap_client.dart' as imapClient;

import "../environment/vars.dart";
// import 'package:mail_client_app/environment/vars.dart';
import '../models/email_account.dart';
import '../models/email_item_model.dart';
import '../models/client_item_model.dart';
import '../models/mail_connection_provider_status.dart';




class MailConnectionProvider with ChangeNotifier { 

  MailConnectionProviderStatus mailConnectionProviderStatus;
  List<ClientItem> clientList = [];
  List<EmailItemModel> emailList;
  Function reconnectAccounts;

  MailConnectionProvider( {
    this.mailConnectionProviderStatus,
    this.clientList,
    this.emailList,
    this.reconnectAccounts
  });


  bool _isInitialised = false;
  bool _isInitialising = true;

  var _isImapClientLogin = false;
  int _accountCount;
  String _preferredMail;
  String _preferredView;
  // dynamic _headersList = [];   // dynamic to be changed in future
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

  List<EmailHeader> get headersList {
    // var tempList = _headersList as List<Map<String, Object>>;
    List<EmailHeader> returnList = [];

    // Transform Date String
    emailList.forEach( (emailItem) {
      // var dateString = emailItem.header.date;
      // var jiffy = jiffyPackage.Jiffy(dateString, 'EEE, dd MMM yyyy hh:mm:ss');

      // returnList.add({
      //   'Date': intl.DateFormat('yyyy/MM/dd').format( emailItem.header.date ),
      //   'Subject': emailItem.header.subject,
      //   'From': emailItem.header.from,
      // });

      returnList.add(  emailItem.header );



      


    } );
    return returnList;
  }

  bool get isLoadingIncoming {
    return _isLoadingIncoming;
  }
  bool get isInitialised {
    return _isInitialised;
  }

  // ---------End of Getters-----


  void makeIncomingMailsScreenInitialised () {
    mailConnectionProviderStatus.isIncomingMailsScreenInitialised = true;
    notifyListeners();
  }










  bool get isNecessaryToReconnect  {    
    if(clientList.length > 0) {
      for( int i = 0; i < clientList.length; i++) {
        if(
          DateTime.now().subtract( Duration(minutes: 2)).isAfter(
            clientList[i].emailAccount.lastConnectionTime
          ) 
        ) {
          return true;
        }
      }
    }
    return false;
  }

  Future<List<int>> selectAllMailboxes () async {
    List<int> mailCountsList = [];
    for( int i = 0; i < clientList.length; i++ ) {
      var client = clientList[i].imapClient;
      var listResponse = await client.listMailboxes();

      if (listResponse.isOkStatus) {
        // Select MailBox
        await client.selectMailbox( listResponse.result[0]);

        // Mail Count
        final mailCount = listResponse.result[0].messagesExists;
        mailCountsList.add(mailCount);
        print('MailCount inside selectAllMailBoxes');
      }
    }  // end of for loop
    return  mailCountsList;
  }


  // To check Last 50(Max) Headers, and Add or Delete Some Existing Ones if Necessary
  Future<void> checkandAddNewHeaders () async { 

    clientList[0].imapClient.searchMessages(
      // ' SENTON 06-Apr-2020 FROM cpanel@teknodogu.com.tr'
      // ' FROM cpanel@teknodogu.com.tr'
      'SUBJECT e maili test ediyorum.. İnan'
      // 'UID 3405:*'
    );
    // enoughMail.EncodingsHelper.decodeAny('Ma=FDl_Konu._Tarih_2020.04.05_01');
    // enoughMail.EncodingsHelper.decodeText('=?iso-8859-9?Q?Ma=FDl_Konu._Tarih_2020.04.05_01?=', convert.);

    if( clientList.length > 0) {
      List<int> mailCountsList = [];
      if( isNecessaryToReconnect ) {
        await reconnectAccounts(); 
        mailCountsList = await selectAllMailboxes();
      }  // End of if ( NecessaryToConnect )

      List<EmailItemModel> tempFetchedEmailsList = [];
      // It means mailCountList is updated Above
      if(mailCountsList.length > 0) {        
        for( int i = 0; i<clientList.length; i++ ) {
          var thisAccountsList = await fetchHeaderFields(
            clientList[i].imapClient,
            1,
            mailCountsList[i]
          );
          tempFetchedEmailsList.addAll(
            thisAccountsList.getRange(0, thisAccountsList.length)  // to convert to iterable
          );

        } // End of for loop

        compareAndAddNewHeaders(tempFetchedEmailsList);
        notifyListeners();
      }
    }
  }  // End of checkandAddNewHeaders



  void compareAndAddNewHeaders ( List<EmailItemModel> newFetchedList ) {
    if( newFetchedList.length == 0 ) {
      return;
    }
    var addedEmailCount = 0;
    bool checkingNewOnes = true;
    var deletedCount = 0;
    var pointerValue = 0;    

    for(int i =  newFetchedList.length-1; i >= 0; i--  ) {
      if( 
        checkingNewOnes == true
        && newFetchedList[i].header.date.isAfter(
          emailList[ 0 + addedEmailCount ].header.date
        ) 
      ) {
        emailList.insert(0, newFetchedList[i] );
        addedEmailCount++;
      } else {
        checkingNewOnes = false;
        print('In compareAndAddNewHeaders method, Added total count = $addedEmailCount');
      }

      if(checkingNewOnes == false) {
        // addedEmailCount++;  // To use addedEmailCount for pointing existing List Index
        var controlledIndex = pointerValue + addedEmailCount - deletedCount;
        if(           
          newFetchedList[i].header.date != emailList[ controlledIndex ].header.date
          || newFetchedList[i].header.subject  != emailList[ controlledIndex ].header.subject
          || newFetchedList[i].header.from  != emailList[ controlledIndex ].header.from
        ) {
          emailList.removeAt( controlledIndex  );
          deletedCount++;
          i++;  
        } else {
          // print(newFetchedList[i].header.date);

          // Update each Email Id if there is any deleted or added one...
          if(deletedCount > 0 || addedEmailCount > 0 ) {
            emailList[ controlledIndex ].header.emailId = newFetchedList[i].header.emailId;
          }
        }
        pointerValue++;
      }  // End of if(checkingNewOnes == false)

    }  // End of for loop over newFetchedList
  }  // End of compareAndAddNewHeaders
  


  String handleFetchedComplexBase64 (String data) { 
    if( data.toString().contains('?utf-8?B?')  || data.toString().contains('?UTF-8?B?') ) {
      var datatoHandle = data.toString();
      // Transform String
      var step1 = datatoHandle.replaceAll('=?utf-8?B?', 'STARTER');             
      var step2 = step1.replaceAll('=?UTF-8?B?', 'STARTER'); 
      var step3 = step2.replaceAll('==?=', 'ENDING'); 
      var step4 = step3.replaceAll('?=', 'ENDING');  
      List<String> stringArray = [];
      int stringStartIndex;
      int stringEndIndex;
      String addString;
      // Creating Strings Array
      while( step4.contains('STARTER')  ) {
        stringStartIndex = step4.indexOf('STARTER');
        stringEndIndex = step4.indexOf('ENDING');
        addString = step4.substring( stringStartIndex+7, stringEndIndex );
        stringArray.add( addString );
        step4 = step4.substring(stringEndIndex + 6 );
      }
      // Add Elements in String Array to Single String
      String printableString ='';
      stringArray.forEach( (element) {        
        printableString = printableString + enoughMail.EncodingsHelper.decodeBase64(element, convert.utf8);
      } );  
      return printableString;
    } else if( data.toString().contains('=?UTF-8?Q?') || data.toString().contains('=?utf-8?Q?')  ) {      
      var datatoHandle = data.toString();  
      // Transform String
      var step1 = datatoHandle.replaceAll('?= =?utf-8?Q?', 'ENDINGSTARTER');
      step1 = step1.replaceAll('=?utf-8?Q?', 'STARTER');
      step1 =step1.replaceAll('?= =?UTF-8?Q?', 'ENDINGSTARTER');
      step1 = step1.replaceAll('=?UTF-8?Q?', 'STARTER');
      step1 = step1.replaceAll('==?=', 'ENDING'); 
      step1 = step1.replaceAll('?=', 'ENDING'); 
      List<String> stringArray = [];
      int stringStartIndex;
      int stringEndIndex;
      String addString;
      // Creating Strings Array
      while( step1.contains('STARTER')  ) {
        stringStartIndex = step1.indexOf('STARTER');
        stringEndIndex = step1.indexOf('ENDING');
        // If there is some "not encoded" text at the beginning
        if(stringStartIndex >= 0) {
          stringArray.add( step1.substring(0, stringStartIndex)  );
        }    
        addString = enoughMail.EncodingsHelper.decodeQuotedPrintable(
          step1.substring( stringStartIndex+7, stringEndIndex ),
          convert.utf8
        );
        stringArray.add( addString );
        step1 = step1.substring(stringEndIndex + 6 );
      }
      // If there is some "not encoded" text at the END
      if(step1.length > 0) {
        stringArray.add(step1);
      }
      // Add Elements in String Array to Single String
      String printableString ='';
      stringArray.forEach( (element) {        
        printableString = printableString + element;
      } );  
      return printableString;
    } else {      
      return data; // Return without any manipulation
    }
  } // End of handleFetchedComplexBase64


  DateTime handleSelectDate  ( {
    DateTime date,
    DateTime deliveryDate
  }  ) {
    if( date != null ) {
      return date;
    } else if( deliveryDate != null ) {
      return deliveryDate;
    } else {
      print( 'Date Error' );
      return null;
    }
  }  // End of handleSelectDate



  Future<List<EmailItemModel>> fetchHeaderFields ( 
    enoughMail.ImapClient client,
    int firstIndex,
    int lastIndex
   ) async {
    List<EmailItemModel> fetchedEmailHeaderList =[];
    // var dates = await client.fetchMessages(1, 10, "BODY.PEEK[HEADER]");
    var rawResponse = await client.fetchMessages(
      firstIndex, 
      lastIndex, 
      // 1,31,
      // "BODY.PEEK[HEADER.FIELDS (Subject From Date Delivery-date Content-Type charset )]"
      // "BODY.PEEK[HEADER]"
      // 'BODY.PEEK[HEADER.FIELDS (Received)]'
      // 'BODY.PEEK[HEADER.FIELDS (Message-ID)]'  // Message-ID BU SEKILDE
      // 'BODY.PEEK[HEADER.FIELDS (Message-ID Received)]'
      'BODY[]'
      // '( BODY[] UID )'
      // 'BODY[TEXT]'
    );
    var mappedData = rawResponse.result;
    var currentIndex = firstIndex;
    mappedData.forEach( (mimeItem) {
      String contentType;
      String from;
      String subject;
      DateTime date;
      DateTime deliveryDate;
      mimeItem.headers.forEach( ( headersItem ) {
        switch ( headersItem.name ) {
          case  'Content-Type' : 
            contentType = headersItem.value;
            break;
          case  'From' : 
            from = headersItem.value;
            break;
          case  'Subject' : 
            subject = headersItem.value;
            break;
          case  'Date' : 
            date =  jiffyPackage.Jiffy(headersItem.value, 'EEE, dd MMM yyyy hh:mm:ss').dateTime;
            break;
          case  'Delivery-date' : 
            deliveryDate = jiffyPackage.Jiffy(headersItem.value, 'EEE, dd MMM yyyy hh:mm:ss').dateTime;
            break;
          
          default:
            // print( 'INTERESTING HEADER: ' +headersItem.name + ':' + headersItem.value );
        }
      });      
      // Create Email Header From Sorted Headers
      var emailHeader = EmailHeader.withId(
        subject: handleFetchedComplexBase64(subject),
        from: from,
        date: handleSelectDate( 
          date: date,
          deliveryDate: deliveryDate
        ),
        emailId: currentIndex
      );
      // Add Each Header To Our Temporary List
      fetchedEmailHeaderList.add( 
        EmailItemModel(
          header: emailHeader
        ) 
      );
      currentIndex++;
    }); // End of Iterating over each Mime
    return fetchedEmailHeaderList;    
  }  // End of fetchHeaderFields



  Future<void> getHeaders (
    //  enoughMail.ImapClient client
     ClientItem clientItem
    ) async {    

    var client = clientItem.imapClient;

    // List Mailboxes
    var listResponse;
    try {

      listResponse = await client.listMailboxes();
      // print( listResponse.result.length); // How many Mailboxes do we have?
    } catch (err) {
      print(err);
    }
    
    if (listResponse.isOkStatus) {

      // Select MailBox
      await client.selectMailbox( listResponse.result[0]);

      // Mail Count
      final mailCount = listResponse.result[0].messagesExists;
      
      var tempEmailsList = await fetchHeaderFields( 
        client, 
        1,  
        mailCount <= 50 ? mailCount : 50
      );     
      // print('ThIS IS FETCHED HEADER FIELDS OF THIS CLIENT');
      // print(tempEmailsList);

      // Add Client to each emailItem
      for( int i = 0; i < tempEmailsList.length; i++ ) {
        var tempEmailItem = tempEmailsList[i];
        tempEmailItem.emailAccount = clientItem.emailAccount;
        tempEmailsList[i] = tempEmailItem;
      }

      emailList.addAll( tempEmailsList.reversed );

      // notifyListeners();   
    } else {
      // Do smt
    }    
  } // end of getHeaders



  Future<void> getAllHeaders() async {
    // print( 'getAllHeaders Method is Beginning-------------------------------------------------------' );
    // print("Client has ${clientList.length} items");
    if( clientList.length > 0) {

      // This is because sometimes after some time, occurs some errors, and auto- reconnect has solved these
      if( isNecessaryToReconnect ) {
        await reconnectAccounts();
      }

      for(  int i = 0; i < clientList.length; i++) {
        await getHeaders(
          clientList[i]
        );
      }

    }
    notifyListeners();
  }  // End of getAllHeaders

 

  // Add Account
  Future<void> addAccount ( EmailAccount newAccount) async {
    // print(newAccount.emailAddress);
    // print(newAccount.emailPassword);
    // print(newAccount.incomingMailsServer);
    // print(newAccount.incomingMailsPort);
    

    var client  = enoughMail.ImapClient(isLogEnabled: true);
    await client.connectToServer(newAccount.incomingMailsServer, int.parse(newAccount.incomingMailsPort), isSecure: true);
    var loginResponse = await client.login( newAccount.emailAddress, newAccount.emailPassword );

    if (loginResponse.isOkStatus) {

      // Prepare Format of Account to Add
      final accountToAdd =  { 
        'senderName' : newAccount.senderName,
        'email' : newAccount.emailAddress,
        'password' : newAccount.emailPassword,
        'incomingServer': newAccount.incomingMailsServer,
        'incomingPort' : newAccount.incomingMailsPort,
        'outgoingServer' : newAccount.outgoingMailsServer,
        'outgoingPort' : newAccount.outgoingMailsPort
      };

      // Save Account on Device
      final prefs = await SharedPreferences.getInstance();
      final extractedUserData = convert.json.decode(
        prefs.getString('komnataMailClient')
      ) as Map<String, Object>;
      final tempAccountList = extractedUserData['accountList'] as List;
      tempAccountList.add(accountToAdd);
      extractedUserData['accountList'] = tempAccountList;
      prefs.setString(
        'komnataMailClient', 
        convert.json.encode(extractedUserData)
      );

      _accountCount++;
      
      clientList.add( ClientItem(
        emailAccount: newAccount,
        imapClient: client
      ) );
      notifyListeners();

      print('Account Below has been Added');
      print( accountToAdd );
    }    
  }   // End of addAccount


  Future<void> fetchSingleMessage ({
    int messageSequenceId,
    EmailAccount emailAccount
  }) async {
    var relatedClient = clientList.firstWhere(
      (element) => element.emailAccount.emailAddress == emailAccount.emailAddress
    ).imapClient;
    var rawResponse = await relatedClient.fetchMessages(
      // lowerMessageSequenceId, upperMessageSequenceId, fetchContentDefinition
      messageSequenceId, 
      messageSequenceId, 
      "BODY.PEEK[]"
      // 'BODY'
            // "BODY.PEEK[HEADER.FIELDS (Subject From Date Delivery-date Content-Type charset )]"
      // "BODY.PEEK[HEADER]"
      // 'BODY.PEEK[HEADER.FIELDS (Received)]'
      // 'BODY.PEEK[HEADER.FIELDS (Message-ID)]'  // Message-ID BU SEKILDE
      // 'BODY.PEEK[HEADER.FIELDS (Message-ID Received)]'
      // 'BODY[]'
      // 'ENVELOPE'
      // 'RFC822.SIZE'
      // 'ALL'
      // '(ENVELOPE BODY[] FLAGS TEXT)'
      // 'TEXT'
      // 'envelope'
      // 'BODY.PEEK[]'
      // 'BODY'
      // '( BODY[] UID )'
      // 'BODY[TEXT]'
      // 'BODY[TEXT]'
      // 'BODYSTRUCTURE'
    );
    var mappedData = rawResponse.result;
    print( 'fetchSingleMessage -> mappedData -> $mappedData'   );
  }


  

  // This method is not used but will stay as an example...
  Future<void> sendMailByMailer2 (  ) async {

    var options = new mailer2.SmtpOptions();
    options.hostName = incomingServer1;
    options.port = 465;
    options.name = mailAddress1;
    options.username = mailAddress1;
    options.password = mailPassword1;
    options.secured = true;
    options.requiresAuthentication = true;

    // Create our email transport.
    var emailTransport = new mailer2.SmtpTransport(options);

    // 'TEST NAME HERE';

    var envelope = new mailer2.Envelope();
    envelope.from = mailAddress1;
    envelope.sender = mailAddress1;
    envelope.recipients = [emailTarget1 , mailAddress1];
    envelope.senderName = 'TEST NAME HERE';
    envelope.subject = 'Test Subject';
    envelope.text = 'This is a test mail text!';

    print('NOW ITT IS TIME TO SEND EMAIL');
    // Email it.
    emailTransport.send(envelope)
      .then((envelope) { 
        print('Email sent!');
        print(envelope.sender);
      })
      .catchError((e) => print('Error occurred: $e'));
  }  // End of sendMailByMailer2

  

  Future<void> sendMail ( EmailItemModel  emailItem ) async {
    // It will be used when it is possible to select sender Account
    // var senderClient = clientList.firstWhere( 
    //   ( item ) => item.emailAccount.emailAddress == emailItem.header.from  
    // );

    var senderClient = clientList[0];

    var options = new mailer2.SmtpOptions();
    options.hostName = senderClient.emailAccount.outgoingMailsServer;
    options.port = int.parse(senderClient.emailAccount.outgoingMailsPort);
    options.name = senderClient.emailAccount.emailAddress;
    options.username = senderClient.emailAccount.emailAddress;
    options.password = senderClient.emailAccount.emailPassword;
    options.secured = true;
    options.requiresAuthentication = true;

    // Create our email transport.
    var emailTransport = new mailer2.SmtpTransport(options);

    var envelope = new mailer2.Envelope();
    envelope.from = senderClient.emailAccount.emailAddress;
    envelope.sender = senderClient.emailAccount.emailAddress;
    envelope.recipients = emailItem.header.recipients;
    envelope.senderName = senderClient.emailAccount.senderName == null 
      ? 'NO NAME ENTERED' 
      : senderClient.emailAccount.senderName;
    envelope.subject = emailItem.header.subject;
    envelope.text = emailItem.text;

    // Email it.
    emailTransport.send(envelope)
      .then((envelope) { 
        print('Email sent!');
        print(envelope.sender);
      })
      .catchError((e) => print('Error occurred: $e'));
  } // End of sendMail Method

}  // End of MailConnectionProvider







