
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fot http requests http.dart & convert for json.decode & json.encode
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:enough_mail/enough_mail.dart' as enoughMail;


import 'package:imap_client/imap_client.dart' as imapClient;

import '../local_environment/vars.dart';




class MailConnectionProvider with ChangeNotifier { 

  List<enoughMail.ImapClient> clientList = [];
  enoughMail.ImapClient client = null;

  String toBePrinted = 'Empty';

  Future<void> addAccount ({
    String email,
    String password,
    int port,
    String incomingServer    
  }) async {

    var client  = enoughMail.ImapClient(isLogEnabled: true);
    await client.connectToServer(incomingServer1, port = portNo1 , isSecure: true);
    var loginResponse = await client.login( mailAddress1, mailPassword1 );

    if (loginResponse.isOkStatus) {
      final accountToAdd = convert.json.encode( { 
        'email' : email,
        'password' : password,
        'port' : port,
        'incomingServer': incomingServer
      });
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('komnataMailClient', accountToAdd);
      clientList.add(client);
    }    
  }

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





      toBePrinted = enoughMail.EncodingsHelper.decodeQuotedPrintable(toBeConverted, testCodec);
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
  }


  Future<void> getMailsByImapClient () async { 
    var client = new imapClient.ImapClient();
    // connect
    await client.connect(incomingServer1, portNo1, true);
    // print(['resultTest1', resultTest1]);
    // authenticate
    await client.login(mailAddress1, mailPassword1);
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


  Future<void> getMailsByImapClient2 () async { 
    var client = new imapClient.ImapClient();
    // connect
    await client.connect(incomingServer1, portNo1, true);
    // print(['resultTest1', resultTest1]);
    // authenticate
    await client.login(mailAddress1, mailPassword1);
    // get folder
    var inbox = await client.getFolder("inbox");


    print(['mailCount: ', inbox.mailCount]);
    print(['unseenCount: ', inbox.unseenCount]);


    var i = 7;

    // Single Subject with Message id (int)    Status: OK
    // Map<int, Map<String, dynamic>> subject =  await inbox.fetch(["BODY.PEEK[HEADER.FIELDS (SUBJECT)]"],messageIds: [i]); 
    // print(["THIS IS SuBjEcT", subject]);


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





    // print('Öğretmen 3. Bölüm - FOX');



  }


}