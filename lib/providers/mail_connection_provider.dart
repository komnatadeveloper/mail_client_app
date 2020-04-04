import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart' as jiffyPackage;
import 'package:enough_mail/enough_mail.dart' as enoughMail;
import 'package:flutter_email_sender/flutter_email_sender.dart' as emailSender;
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





class MailConnectionProvider with ChangeNotifier { 


  List<ClientItem> clientList = [];
  List<EmailItemModel> emailList;
  Function reconnectAccounts;

  MailConnectionProvider( {
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
  dynamic _headersList = [];   // dynamic to be changed in future
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

  List<Map<String, Object>> get headersList {
    // var tempList = _headersList as List<Map<String, Object>>;
    List<Map<String, Object>> returnList = [];

    // Transform Date String
    emailList.forEach( (emailItem) {
      var dateString = emailItem.header.date;
      var jiffy = jiffyPackage.Jiffy(dateString, 'EEE, dd MMM yyyy hh:mm:ss');

      returnList.add({
        'Date': intl.DateFormat('yyyy/MM/dd').format( jiffy.dateTime ),
        'Subject': emailItem.header.subject,
        'From': emailItem.header.from,
      });

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





  bool get getterNecessaryToReconnect  {    
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


  Future<void> getAllHeaders() async {
    print( 'getAllHeaders Method is Beginning' );
    print("Client has ${clientList.length} items");
    if( clientList.length > 0) {

      if( getterNecessaryToReconnect ) {
        print('RECONNECTING ACCOUNTS in getAllHeaders Method-----------------------------------------------------------------------------');
        await reconnectAccounts();
      }

      for(  int i = 0; i < clientList.length; i++) {
        print('getHeaders of ${clientList[i].emailAccount.emailAddress} will start  NOWWWWW');
        await getHeaders( clientList[i].imapClient );
      }

    }
    notifyListeners();
    print( 'getAllHeaders Method has Ended' );

  }






  


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

      // Save Account Info to Device


      // final accountToAdd = convert.json.encode( { 
      //   'email' : newAccount.emailAddress,
      //   'password' : newAccount.emailPassword,
      //   'incomingServer': newAccount.incomingMailsServer,
      //   'port' : newAccount.incomingMailsPort
      // });



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







  
  

  String handleFetchedComplexBase64 (String data) {   
    print('   handleFetchedComplexBase64 Metodu----------------------------------------------------------- giren data: $data');     

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
      print(printableString);
      return printableString;

    } else {
      print('Direk Girdigi gibi cikiyor: $data');
      return data;
    }

  } // End of handleFetchedComplexBase64






  Future<void> getHeaders (
     enoughMail.ImapClient client
    ) async {

    print('getHeaders METHODU BASLANGICI------------------------------------------');
    
    // List Mailboxes
    print('Client LOGIN MI DEGIL MI YAZDIRILACAK----------------');
    print(client.isLoggedIn);
    var listResponse;
    print('TRY CATCH BASLIYOOOOOOOOOOOOOO');
    try {

      listResponse = await client.listMailboxes();
      print('LISTENIN UZUNLUGU YAZDIRILACAK----------------------');
      print( listResponse.result.length);
    } catch (err) {
      print("HATA BURADA TRY CATCH ICI");
      print(err);
    }

    print('listResponse Yazdirilacak------------');
    print(listResponse);

    
    if (listResponse.isOkStatus) {
      print('listResponse OKEY IMIS. BAKALIM PROBLEM NEREDEEEE');

      // Select MailBox
      await client.selectMailbox( listResponse.result[0]);

      print('MAILBOXU DA SECTIK... AMA PROBLEM BITEBILDI MI EMIN DEGILIZ');

      // Mail Count
      final mailCount = listResponse.result[0].messagesExists;

      print('Simdi fetchHeaderFields Methodu CAGIRILACAK BAKALIM SONRASI NEEEEEE');
      final tempEmailsList = await fetchHeaderFields( 
        client, 
        1,  
        mailCount <= 50 ? mailCount : 50
      );
      print('ThIS IS FETCHED HEADER FIELDS OF THIS CLIENT');
      print(tempEmailsList);

      for (int i = 0; i < tempEmailsList.length; i++) {
        emailList.add(tempEmailsList[i]);
      }
      // notifyListeners();   
    } else {
      print('getHeaders Methodu listResponse HATA VERIYOR PROBLEM BURADAAAAAAA---------------------------');
    }
    
  } // end of getEnoughMails



  Future<List<String>> fetchSubjects ( 

    enoughMail.ImapClient client,
    int firstIndex,
    int lastIndex
   ) async {
    List<String> subjectList =[];
     
    var subject = await client.fetchMessages(1, 10, "BODY.PEEK[HEADER.FIELDS (SUBJECT)]");
    var mappedData = subject.result;
    // Mapping Fetched "SUBJECT" Data
    mappedData.forEach( (item) {
      subjectList.add(
        handleFetchedComplexBase64(item.headers[0].value)
      );
    } );

    print(subjectList);
    return subjectList;
  }  // End of fetchSubjects


  


  String handleSelectDate  ( {
    String date,
    String deliveryDate
  }  ) {
    if( date != null ) {
      return date;
    } else if( deliveryDate != null ) {
      return deliveryDate;
    } else {
      print( 'Date Error' );
      return 'DateError';
    }

  }



  Future<List<EmailItemModel>> fetchHeaderFields ( 
    enoughMail.ImapClient client,
    int firstIndex,
    int lastIndex
   ) async {
    List<EmailItemModel> fetchedEmailHeaderList =[];

    print('Ilk index $firstIndex son index ise $lastIndex -------------------------------------------------------');

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
    );
    var mappedData = rawResponse.result;

    // print('RAW RESPONSE CEVABI-----------------------------------------------------------');
    // print(mappedData);

    // print(mappedData);
    print('---------------------------------------------MANIPULATE FETCHED DATAS in fetchHeaderFields Method---------------------------------');

    mappedData.forEach( (mimeItem) {
      String contentType;
      String from;
      String subject;
      String date;
      String deliveryDate;


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
            date = headersItem.value;
            break;
          case  'Delivery-date' : 
            deliveryDate = headersItem.value;
            break;
          
          default:
            print( 'INTERESTING HEADER: ' +headersItem.name + ':' + headersItem.value );
        }
      });      

      // Create Email Header From Sorted Headers
      var emailHeader = EmailHeader(
        subject: handleFetchedComplexBase64(subject),
        from: from,
        date: handleSelectDate( 
          date: date,
          deliveryDate: deliveryDate
        ),
      );
      print(emailHeader.subject);  // FOR TEST

      // Add Each Header To Our Temporary List
      fetchedEmailHeaderList.add( EmailItemModel(
        header: emailHeader
      ) );

    }); // End of Iterating over each Mime

    return fetchedEmailHeaderList;    
  }  // End of fetchHeaderFields


  

  // It will stay as an example
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

    print('NOW ITT IS TIME TO SEND EMAIL');
    // Email it.
    emailTransport.send(envelope)
      .then((envelope) { 
        print('Email sent!');
        print(envelope.sender);
      })
      .catchError((e) => print('Error occurred: $e'));
  } // End of sendMail Method

}  // End of MailConnectionProvider







