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

  MailConnectionProvider( {
    this.clientList,
    this.emailList
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




  String toBePrinted = 'Empty';


  int counter = 0;


  Future<void> getAllHeaders() async {
    print( 'getAllHeaders Method is Beginning' );
    print("Client has ${clientList.length} items");
    if( clientList.length > 0) {

      for(  int i = 0; i < clientList.length; i++) {
        await getHeaders( clientList[i].imapClient );
      }

    }
    notifyListeners();
    print( 'getAllHeaders Method has Ended' );

  }






  


  // Add Account
  Future<void> addAccount ( EmailAccount newAccount) async {



    // if( true ) {
    //   getEnoughMails();
    //   return;
    // }

    print(newAccount.emailAddress);
    print(newAccount.emailPassword);
    print(newAccount.incomingMailsServer);
    print(newAccount.incomingMailsPort);
    

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







  
  Future<void> getMails () async {
    var client  = enoughMail.ImapClient(isLogEnabled: true);
    // await client.connectToServer(incomingServer1, portNo1, isSecure: true);
    // var loginResponse = await client.login(mailAddress1, mailPassword1);
    // var client  = enoughMail.ImapClient(isLogEnabled: true);
    await client.connectToServer(incomingServer2, portNo2, isSecure: true);
    var loginResponse = await client.login(mailAddress2, mailPassword2);

    // print( ['loginResponse HERE',  loginResponse.toString() ]);  // Bir ise yaramadi


    // enoughMail.Mailbox

    // print (
    //   await client.fetchMessages(1, 6, "BODY[TEXT]")
    // );

    if (loginResponse.isOkStatus) {
      var listResponse = await client.listMailboxes();
      if (listResponse.isOkStatus) {

        // print('mailboxes: ${listResponse.result}');


        // Necessary PATTERN
        // print('mailboxes: ${listResponse.result[0].name}');
        // print('mailboxes: ${listResponse.result[0].path}');
        // print(listResponse.result.length);

      //  print( await client.examineMailbox(listResponse.result[0]));


      // Select MailBox
      await client.selectMailbox( listResponse.result[0]);

      print(listResponse.result[0].messagesExists);


      // Get Single "test"
      // var testVar = await client.fetchMessages(1, 1, 'ENVELOPE');
      // print(testVar.result);

      // var testVar2 = await client.fetchMessages(2, 2, 'BODY[]');
      // print(testVar2.result);

      print('------------------------------------HEHEHEEHEHEEHEHE-----------------');
      var testVar3 = await client.fetchMessages(1, 7, "BODY.PEEK[HEADER.FIELDS (SUBJECT)]");
      // print(testVar3.result[0].decodeContentText());
      // print(testVar3.result[0]);
      // print(testVar3.result[0][3]);
      // var testVar3Result = testVar3.result[0];
      print('---------------222222---------------------HEHEHEEHEHEEHEHE-----------------');
      // print(testVar3Result.from);

      //
      print('---------------NOW----RESULT-----------------');
      // print(testVar3.result[0]);

      var toBeConverted = testVar3.result.toString();
      var varUtf8 = convert.utf8.encode(testVar3.result.toString());

      var varTest2 = convert.base64Encode( varUtf8);

      // var encodingTestVar =  convert.Codec();

      convert.Codec<convert.AsciiCodec, convert.Utf8Codec> testCodec;
      // toBePrinted = enoughMail.EncodingsHelper.decodeQuotedPrintable(toBeConverted, testCodec);
      notifyListeners();
      
      print(
        // varTest2
testVar3.result.toString()
        // convert.Converter
      );

      // enoughMail.MimeMessage



      // Get Multi "Subjects"
      // var messageList2 = await client.fetchMessages(1, 4, 'BODY.PEEK[HEADER.FIELDS (SUBJECT)]');
      // print(messageList2.result);

      // Get Multi "Body"
      // var messageList3 = await client.fetchMessages(1, 4, "BODY[TEXT]");
      // print([
      //   '-----messageList3--------------------------------------------------------------------------------------', 
      //   messageList3.result]);


      



      // enoughMail.MimeMessage

  
      }
    }
  } // end of getMails

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

      print('   ISE YARAYACAK MI BAKALIMMMMMM-----------------------------------------------------------');
      var datatoHandle = data.toString();
      print(datatoHandle);

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
      return data;
    }

  } // End of handleFetchedComplexBase64


  

  String handleFetchedSubject (String data) {

    // you should use following fetch to use this function
    // Map<int, Map<String, dynamic>> subject =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (SUBJECT)]"],messageIdRanges: ['1:10']);

    var phase1 = data.toString().substring(9); // ( "Subject: "  9 Characters )
        
    if( phase1.toString().contains('?utf-8?B?')  || phase1.toString().contains('?UTF-8?B?') ) {

      var datatoHandle = phase1.toString();

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

    }  else {
      return phase1;
    }

  } // End of handleFetchedSubject

  String handleFetchedFrom ( dynamic data ) {
    var initial = data.toString();

    return initial.substring(6, initial.length -4);
  }


  String handleFetchedDate ( dynamic data ) {
    // You need to use the following fetch pattern
    // Map<int, Map<String, dynamic>> date =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (Date Delivery-date)]"],messageIdRanges: ['1:10']);

    var initial = data.toString();

    if( initial.contains('Date:') ) {
      var index = initial.indexOf('Date:');
      return initial.substring(index+6, initial.length - 4);

    } else if( initial.contains('Delivery-date:')) {
      // print('Date does not exist');      
      var index = initial.indexOf('Delivery-date:');
      return initial.substring(index+15, initial.length - 4);      
    } else {
      print( 'Date and Delivery-date not found!' );
      return 'No-Date';
    }
  } 


  Future<void> getHeaders (
     enoughMail.ImapClient client 
    ) async {

    print('GET ENOUGH HEADERS');
    // print(client);
    // List Mailboxes
    var listResponse = await client.listMailboxes();
    if (listResponse.isOkStatus) {

      // Select MailBox
      await client.selectMailbox( listResponse.result[0]);

      // Mail Count
      final mailCount = listResponse.result[0].messagesExists;


      final tempEmailsList = await fetchHeaderFields( 
        client, 
        1,  
        mailCount <= 50 ? mailCount : 50
      );

      for (int i = 0; i < tempEmailsList.length; i++) {
        emailList.add(tempEmailsList[i]);
      }
      // notifyListeners();   
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


  Future<List<String>> fetchDate ( 
    enoughMail.ImapClient client,
    int firstIndex,
    int lastIndex
   ) async {
    List<String> dateList =[];

    var dates = await client.fetchMessages(1, 10, "BODY.PEEK[HEADER.FIELDS (Date Delivery-date)]");
    var mappedData = dates.result;
    // Mapping Fetched "Date Delivery-date" Data
    mappedData.forEach( (item) {
      String deliveryDate;
      String date;
      String dateError = 'DateError';

      // Iterate Headers of Items
      item.headers.forEach( (headerItem) {
        if( headerItem.name == 'Date') {
          date = headerItem.value;
        } else if(headerItem.name == 'Delivery-date') {
          deliveryDate = headerItem.value;
        } else {
          print('Date not found');
        }
      } );
      // Add Date to List
      if( date != null ) {
        dateList.add(date);
      } else if( deliveryDate != null ) {
        dateList.add(deliveryDate);
      } else {
        dateList.add(dateError);      
      }

    } );

    // print(dateList);
    return dateList;
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

    // var dates = await client.fetchMessages(1, 10, "BODY.PEEK[HEADER]");
    var rawResponse = await client.fetchMessages(
      firstIndex, 
      lastIndex, 
      // "BODY.PEEK[HEADER.FIELDS (Subject From Date Delivery-date Content-Type charset )]"
      "BODY.PEEK[HEADER]"
    );
    var mappedData = rawResponse.result;


    // print(mappedData);
    print('---------------------------------------------MANIPULATE FETCHED DATAS in fetchHeaderFields Method---------------------------------');

    mappedData.forEach( (mimeItem) {
      String contentType;
      String from;
      String subject;
      String date;
      String deliveryDate;

      // Answer of enoughMail Github Issue
      // mimeItem.parse();
      // print(mimeItem);

      

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
      } );
      // print(subject);  // FOR TEST
      // print('TRY TO SOLVE BY PARSE METHOD');
      // mimeItem.bodyRaw;
      // print(mimeItem.decodeContentText());
      

      var emailHeader = EmailHeader(
        subject: handleFetchedComplexBase64(subject),
        from: from,
        date: handleSelectDate( 
          date: date,
          deliveryDate: deliveryDate
        ),
      );
      print(emailHeader.subject);  // FOR TEST

      // headerFieldsList.add( {
      //   'Subject': handleFetchedComplexBase64(subject),
      //   'From': from,
      //   'Date': handleSelectDate( 
      //     date: date,
      //     deliveryDate: deliveryDate
      //   ),
      //   'Content=Type': contentType
      // });  
      fetchedEmailHeaderList.add( EmailItemModel(
        header: emailHeader
      ) );

    } ); // End of Iterating over each Mime


    return fetchedEmailHeaderList;
    
  }  // End of fetchSubjects


  Future<void> sendEmail () async {
    print(' A TRY TO SEND EMAIL -------------------------------------------------------');
    final emailToSend = emailSender.Email(
      body: 'Email body',
      subject: 'Email subject',
      recipients: [emailTarget1],
      cc: [emailTarget2],
      bcc: [emailTarget2],
      attachmentPaths: [],
      isHTML: false,
    );
    await emailSender.FlutterEmailSender.send(emailToSend);
  }

  Future<void>sendMailByEnough() async {
    var smtpClient = enoughMail.SmtpClient( mailClientDomain1 );

    print( 'SMTP CLIENT CONNECT TO SERVER' );
    var connectionResponse = await smtpClient.connectToServer(incomingServer1, portNo1, isSecure: true );
    print( connectionResponse.message );
    print(connectionResponse.isOkStatus ); 

    print( 'SMTP CLIENT LOGIN' );
    var loginResponse = await smtpClient.login(mailAddress1, mailPassword1);
    print( loginResponse.message );
    print(loginResponse.isOkStatus ); 

    // var senderMailAddress = enoughMail.MailAddress( 'Test Sender', mailAddress1 );

    var messageToSend = enoughMail.MimeMessage();
    
    print( 'SMTP CLIENT SEND MESSAGE' );
    var sendResponse = await smtpClient.sendMessage( messageToSend );
    print(sendResponse.message);
    print(sendResponse);
  }


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


  }

  Future<void> sendMail ( EmailItemModel  emailItem ) async {



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

    // 'TEST NAME HERE';

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


  }

}







