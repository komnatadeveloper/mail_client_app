
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fot http requests http.dart & convert for json.decode & json.encode
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:enough_mail/enough_mail.dart' as enoughMail;


import 'package:imap_client/imap_client.dart' as imapClient;

import '../local_environment/vars.dart';


import '../models/email_account.dart';




class MailConnectionProvider with ChangeNotifier { 

  List<enoughMail.ImapClient> clientList = [];
  enoughMail.ImapClient client = null;

  String toBePrinted = 'Empty';

  Future<void> addAccount ( EmailAccount newAccount) async {

    print(newAccount.emailAddress);
    print(newAccount.emailPassword);
    print(newAccount.incomingMailsServer);
    print(newAccount.incomingMailsPort);

    var client  = enoughMail.ImapClient(isLogEnabled: true);
    await client.connectToServer(newAccount.incomingMailsServer, int.parse(newAccount.incomingMailsPort), isSecure: true);
    var loginResponse = await client.login( newAccount.emailAddress, newAccount.emailPassword );

    if (loginResponse.isOkStatus) {
      final accountToAdd = convert.json.encode( { 
        'email' : newAccount.emailAddress,
        'password' : newAccount.emailPassword,
        'incomingServer': newAccount.incomingMailsServer,
        'port' : newAccount.incomingMailsPort
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('komnataMailClient', accountToAdd);
      clientList.add(client);

      print( convert.json.decode(accountToAdd) );
      print('Account Added');
    }    
  }   // End of addAccount

  Future<void> getMails1 () async { 

    var listResponse = await clientList[0].listMailboxes();
      if (listResponse.isOkStatus) {

      // Select MailBox
      await client.selectMailbox( listResponse.result[0]);

      var mailCount = listResponse.result[0].messagesExists;

      var headerResponse = await client.fetchMessages(1, mailCount, "BODY.PEEK[HEADER.FIELDS (SUBJECT)]");
      
    }


  }




  
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


  Future<void> getMailsByImapClient () async { 
    var client = new imapClient.ImapClient();
    // connect
    await client.connect(incomingServer2, portNo2, true);
    // print(['resultTest1', resultTest1]);
    // authenticate
    await client.login(mailAddress2, mailPassword2);
    // get folder
    var inbox = await client.getFolder("inbox");

    print(['mailCount: ', inbox.mailCount]);
    print(['unseenCount: ', inbox.unseenCount]);
    print(['subset of folderSS: ', await inbox.list('INBOX')]);

    var allMessagesTest = await inbox.fetch([ "BODY.PEAK[HEADER.FIELDS (From Subject Date)]"], messageIds: [7] );
    print(['allMessagesTest: ', allMessagesTest ]);


    var checkMethod = await inbox.check();


    var i = 7;

    Map<int, Map<String, dynamic>> subject =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (SUBJECT)]"],messageIds: [i]);    

    var mapSubjectEmail = subject[i];
    print(mapSubjectEmail);
    var mapEmail = mapSubjectEmail.values;
    print(mapEmail);
    var subjectEmail = mapEmail.first as String;

    Map<int, Map<String, dynamic>> from =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (From)]"],messageIds: [i]);
    print(from);

    var body = await inbox.fetch(["RFC822.TEXT"], messageIds: [i]);
    print(['body: HEEE', body]);


    print('.');
    print('.');
    print('.');

    var body2 = await inbox.fetch(['BODY'], messageIdRanges: ['7']);
    print(body2);

    // var inboxFolder = await inbox.getFolder('inbox', readOnly: true);
    // print([ 'inboxFolder', inboxFolder. ]);


  }

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

    } else {
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


  Future<void> getMailsByImapClient2 () async { 
    var client = new imapClient.ImapClient();
    // connect
    await client.connect(incomingServer2, portNo2, true);
    // print(['resultTest1', resultTest1]);
    // authenticate
    await client.login(mailAddress2, mailPassword2);
    // get folder
    var inbox = await client.getFolder("inbox");


    print(['mailCount: ', inbox.mailCount]);
    print(['unseenCount: ', inbox.unseenCount]);


    var i = 7;

    // Single "Subject" with Message id (int)    Status: OK
    // Map<int, Map<String, dynamic>> subject =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (SUBJECT)"],messageIdRanges: ['1:10']); 
    // print(["THIS IS SuBjEcT", subject]);


    var printList = [];

    // print('-------------Starting Transform-----------');

    // // Mapping Fetched "SUBJECT" Data
    // subject.forEach( (indexNo, data1) {
    //   data1.forEach(( definition, data2  ) {

    //     // print(handleFetchedSubject(data2));

    //     printList.add( handleFetchedSubject(data2)  );


    //   });
    // } );

    // print('-------------END OF Transform-----------');

    toBePrinted = printList.toString();



    // Fetch "From" 
    Map<int, Map<String, dynamic>> from =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (From)]"],messageIdRanges: ['1:10']); 
    // print(["THIS IS FroM anD DaTe", fromAndDate]);


    // // Mapping Fetched "From" Data  WORKING
    // from.forEach( (indexNo, data1) {
    //   data1.forEach(( definition, data2  ) {
    //     print( handleFetchedFrom(data2) );
    //   });
    // } );


    // Fetch "Date"
    // Map<int, Map<String, dynamic>> date =  await inbox.fetch(["BODY.PEEK[HEADER]"],messageIdRanges: ['1:10']); 
    Map<int, Map<String, dynamic>> date =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (Date Delivery-date)]"],messageIdRanges: ['1:10']); 
    // print(["THIS IS OnlY DaTe", date]);


    // // Mapping Fetched "Date" Data
    // date.forEach( (indexNo, data1) {
    //   data1.forEach(( definition, data2  ) {  

    //     print(handleFetchedDate(data2));        

    //   });
    // } );













    



    // Single "From" with Message id (int)   Status: OK
    // Map<int, Map<String, dynamic>> from =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (From)]"],messageIds: [i]);
    // print([ "THIS IS FroM"  ,from]);

    // Multiple "From" with Message id Range (int) Status: OK
    // Map<int, Map<String, dynamic>> from2 =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (From)]"], messageIdRanges: ['1:6']);
    // print([ "THIS IS FroM with Range"  ,from2]);

    // Single "Content" with Message id (int)   Status: OK
    // var body = await inbox.fetch(["RFC822.TEXT"], messageIds: [1]);
    // print(['This IS  Content', body]);

    // Single "Content" with Message id (int)  Usttekiyle ayni.
    // var body2 = await inbox.fetch(["BODY[TEXT]"], messageIds: [1]);
    // print(['This IS  Content2', body2]);



    notifyListeners();





    // print('Öğretmen 3. Bölüm - FOX');



  }


}