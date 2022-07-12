import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:mail_client_app/screens/single_email_webview/single_email_webview_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jiffy/jiffy.dart' as jiffyPackage;
import 'package:enough_mail/enough_mail.dart' as enoughMail;
// import 'package:mailer2/mailer.dart' as mailer2;
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as mailer_smtp;

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


// Utils
import '../../utils/encoding/encodings.dart';




class MailConnectionProvider with ChangeNotifier { 

  MailConnectionProviderStatus? mailConnectionProviderStatus;
  List<ClientItem> clientList = [];
  List<EmailItemModel> emailList;
  Function? reconnectAccounts;

  MailConnectionProvider( {
    required this.mailConnectionProviderStatus,
    required this.clientList,
    required this.emailList,
    required this.reconnectAccounts,
    this.isLoadingSingleEmail = false,
  });


  bool _isInitialised = false;
  bool _isInitialising = true;

  var _isImapClientLogin = false;
  int? _accountCount;
  String? _preferredMail;
  String? _preferredView;
  // dynamic _headersList = [];   // dynamic to be changed in future
  bool _isLoadingIncoming = false;


  String? messageIdThatIsLoading;
  bool isLoadingSingleEmail;



  bool get isInitialising {
    return _isInitialising;
  }
  bool get isImapClientLogin {
    return _isImapClientLogin;
  }
  int get accountCount {
    return _accountCount ?? 0;
  }
  String? get preferredMail {
    return _preferredMail;
  }
  String? get preferredView {
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
    mailConnectionProviderStatus?.isIncomingMailsScreenInitialised = true;
    notifyListeners();
  }










  bool get isNecessaryToReconnect  {    
    if(clientList.length > 0) {
      for( int i = 0; i < clientList.length; i++) {
        if (clientList[i].emailAccount.lastConnectionTime == null ) {
          return false;
        }
        if(
          DateTime.now().subtract( Duration(minutes: 2)).isAfter(
            clientList[i].emailAccount.lastConnectionTime!
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
      var client = clientList[i].imapClient!;
      var listResponse = await client.listMailboxes();

      if (
        // listResponse.isOkStatus
        client.isConnected
      ) {
        // Select MailBox
        await client.selectMailbox( 
          listResponse[0]
        );

        // Mail Count
        final mailCount = listResponse[0].messagesExists;
        mailCountsList.add(mailCount);
        print('MailCount inside selectAllMailBoxes');
      }
    }  // end of for loop
    return  mailCountsList;
  }


  // To check Last 50(Max) Headers, and Add or Delete Some Existing Ones if Necessary
  Future<void> checkandAddNewHeaders () async { 

    
    clientList[0].imapClient?.searchMessages(
      // ' SENTON 06-Apr-2020 FROM cpanel@teknodogu.com.tr'
      // ' FROM cpanel@teknodogu.com.tr'

      // 'SUBJECT e maili test ediyorum.. İnan'

      // 'UID 3405:*'
      
      // https://gist.github.com/martinrusev/6121028  // 'SEEN' || 'RECENT' || 'SEEN'
      searchCriteria: 'ALL',

    );
    // enoughMail.EncodingsHelper.decodeAny('Ma=FDl_Konu._Tarih_2020.04.05_01');
    // enoughMail.EncodingsHelper.decodeText('=?iso-8859-9?Q?Ma=FDl_Konu._Tarih_2020.04.05_01?=', convert.);

    if( clientList.length > 0) {
      List<int> mailCountsList = [];
      if( isNecessaryToReconnect ) {     

        await reconnectAccounts!(); 
        
        mailCountsList = await selectAllMailboxes();
      }  // End of if ( NecessaryToConnect )

      List<EmailItemModel> tempFetchedEmailsList = [];
      // It means mailCountList is updated Above
      if(mailCountsList.length > 0) {        
        for( int i = 0; i<clientList.length; i++ ) {
          var thisAccountsList = await fetchHeaderFields(
            clientList[i].imapClient!,
            clientList[i].emailAccount.emailAddress,
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
        && newFetchedList[i].header.date!.isAfter(
          emailList[ 0 + addedEmailCount ].header.date!
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
        printableString = printableString + EncodingsHelper.decodeBase64(element, convert.utf8);

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

        addString = EncodingsHelper.decodeQuotedPrintable(
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


  DateTime? handleSelectDate  ( {
    DateTime? date,
    DateTime? deliveryDate
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
    String emailAddress,
    int firstIndex,
    int lastIndex
   ) async {

    var xx = client.serverInfo;
    var yy = client.logName;
    var zz = client.connectionInfo;

    List<EmailItemModel> fetchedEmailHeaderList =[];

    // var dates = await client.fetchMessages(1, 10, "BODY.PEEK[HEADER]");
    var rawResponse = await client.fetchMessages(
      enoughMail.MessageSequence.fromRange(
        firstIndex, lastIndex
      ),
      // 1,31,
     
      // "BODY.PEEK[HEADER]"
      // 'BODY.PEEK[HEADER.FIELDS (Received)]'
      // 'BODY.PEEK[HEADER.FIELDS (Message-ID)]'  // Message-ID BU SEKILDE
      // 'BODY.PEEK[HEADER.FIELDS (Message-ID Received)]'
      // 'BODY[]'
      // '( BODY[] UID )'
      // 'BODY[TEXT]'
      // "BODY.PEEK[HEADER.FIELDS (Subject From Date Delivery-date Content-Type charset Message-Id )] MEDIA"
      // "BODY.PEEK[]"
      "( BODY[] ENVELOPE )"
      // "( BODY.PEEK[] ENVELOPE )"
      // '( BODYSTRUCTURE ENVELOPE )'
    );
    
    var mappedData = rawResponse.messages;

    var currentIndex = firstIndex;
    mappedData.forEach( (mimeItem) {
      String contentType;
      late String from;
      late String subject;
      late DateTime date;
      DateTime? deliveryDate;
      String? messageId;

      String mediaType = mimeItem.mediaType.text;
      var clientEmail = client;

      var _decodeTextHtmlPart =  mimeItem.decodeTextHtmlPart();
      var _decodeTextPlainPart =  mimeItem.decodeTextPlainPart();

      

      


      var _subjectFromEnvelope = mimeItem.envelope?.subject;

      
      var _mimeData = mimeItem.mimeData;
      var _mimeDataParts = _mimeData?.parts;
      var _mimeParts = mimeItem.parts;

      
      if ( _decodeTextHtmlPart == null ) {
        if (mimeItem.mediaType.top == enoughMail.MediaToptype.multipart) {
          var __body = mimeItem.body;
          if ( __body == null ) {
           print('ddd');
          }

          if ( _mimeDataParts != null ) {
            _mimeDataParts.forEach((mimeDataPartItem) {
              var bit7 = mimeDataPartItem.decodeBinary('7bit');
              var decodedMessageData = mimeDataPartItem.decodeMessageData(); 


              print('hh');
              var _mimeDataPartItemParts = mimeDataPartItem.parts;
              if ( _mimeDataPartItemParts != null ) {
                _mimeDataPartItemParts.forEach((__mimeData) { 
                  var bit7 = __mimeData.decodeBinary('7bit');
                  var decodedMessageData = __mimeData.decodeMessageData(); 
                  print('hh');
                });
              }


              // decodedMessageData.
            });
          }

          if ( _mimeParts != null ) {
            _mimeParts.forEach(( _mimePart) { 
              if (_mimePart.mediaType.sub == enoughMail.MediaSubtype.messageRfc822) {
                //-----------------
                final mime = _mimePart.decodeContentMessage();

                var xxx = _mimePart.decodeTextHtmlPart();
                var yyy = _mimePart.decodeTextPlainPart();
                print('hh');

                var _mimeData = _mimePart.mimeData;

                if ( _mimePart.parts != null ) {
                  var __mimeParts = _mimePart.parts;
                  __mimeParts!.forEach((__mimePart) { 
                    var xxx = _mimePart.decodeTextHtmlPart();
                    var yyy = _mimePart.decodeTextPlainPart();
                     print('hh');
                  });
                }
                
                //-----------------
              }
            });
          }
        }
      }

      var _hasPart0 = mimeItem.hasPart(
        enoughMail.MediaSubtype.textHtml,
        depth: 0
      );
      var _hasPart = mimeItem.hasPart(
        enoughMail.MediaSubtype.textHtml,
        depth: 1
      );
      var _hasPart2 = mimeItem.hasPart(
        enoughMail.MediaSubtype.textHtml,
        depth: 2
      );
      var _hasPart3 = mimeItem.hasPart(
        enoughMail.MediaSubtype.textHtml,
        depth: 3
      );



      var _hasPart01 = mimeItem.hasPart(
        enoughMail.MediaSubtype.applicationXml,
        depth: 0
      );
      var _hasPart11 = mimeItem.hasPart(
        enoughMail.MediaSubtype.applicationXml,
        depth: 1
      );
      var _hasPart21 = mimeItem.hasPart(
        enoughMail.MediaSubtype.applicationXml,
        depth: 2
      );
      var _hasPart31 = mimeItem.hasPart(
        enoughMail.MediaSubtype.applicationXml,
        depth: 3
      );



      var _hasPart02 = mimeItem.hasPart(
        enoughMail.MediaSubtype.textPlain,
        depth: 0
      );
      var _hasPart12 = mimeItem.hasPart(
        enoughMail.MediaSubtype.textPlain,
        depth: 1
      );
      var _hasPart22 = mimeItem.hasPart(
        enoughMail.MediaSubtype.textPlain,
        depth: 2
      );
      var _hasPart32 = mimeItem.hasPart(
        enoughMail.MediaSubtype.textPlain,
        depth: 3
      );

      var _hasAttachments = mimeItem.hasAttachments();

      var _body = mimeItem.body;
      var _bodyParts = mimeItem.body?.parts;


      
      if (_decodeTextHtmlPart == null  ) {
        /* 
          maybe i should use MailClient API better :)
          https://github.com/Enough-Software/enough_mail/issues/58
        */
        _decodeTextHtmlPart = '<h1>This Content Couldnt be Handled Yet!</h1>';
      }
      if (_decodeTextHtmlPart == null  && _decodeTextPlainPart == null  ) {
        _decodeTextPlainPart = 'This Content Couldnt be Handled Yet!';
      }

      

      print('currentIndex -> $currentIndex');


      if ( _mimeDataParts != null ) {
        for ( int i = 0; i < _mimeDataParts.length; i++ ) {
          var tempMimeDataItem = _mimeDataParts[i];
          var tempMimeItemHeadersList = tempMimeDataItem.headersList;
          var containsHeader = tempMimeDataItem.containsHeader;
          var contentType = tempMimeDataItem.contentType;
          var contentTypeValue = contentType?.value;
          var yy = tempMimeDataItem.decodeBinary( '7bit' );
          // var tt = tempMimeDataItem.decodeBinary( '7bit' );
          print('for loop -> i -> $i');
        }
      }

      if ( mimeItem.envelope == null ) {
        mimeItem.headers?.forEach( 
          ( headersItem ) {
          switch ( headersItem.name ) {
            case  'Content-Type' : 
              contentType = headersItem.value!;
              break;
            case  'From' : 
              from = headersItem.value!;
              break;
            case  'Subject' : 
              subject = _subjectFromEnvelope ?? headersItem.value!;
              break;
            case  'Date' : 
              date =  jiffyPackage.Jiffy(headersItem.value, 'EEE, dd MMM yyyy hh:mm:ss').dateTime;
              break;
            case  'Delivery-date' : 
              deliveryDate = jiffyPackage.Jiffy(headersItem.value, 'EEE, dd MMM yyyy hh:mm:ss').dateTime;
              break;
            case  'Message-Id' : 
              messageId = headersItem.value!;
              break;
            case  'Message-ID' : 
              messageId = headersItem.value!;
              break;
            
            default:
              // print( 'INTERESTING HEADER: ' +headersItem.name + ':' + headersItem.value );
          }
        });      
      }  else { // mimeItem.envelope NOT null
      /* 
         'Content-Type' : 
              contentType = headersItem.value!;
              break;
            case  'From' : 
              from = headersItem.value!;
              break;
            case  'Subject' : 
              subject = _subjectFromEnvelope ?? headersItem.value!;
              break;
            case  'Date' : 
              date =  jiffyPackage.Jiffy(headersItem.value, 'EEE, dd MMM yyyy hh:mm:ss').dateTime;
              break;
            case  'Delivery-date' : 
              deliveryDate = jiffyPackage.Jiffy(headersItem.value, 'EEE, dd MMM yyyy hh:mm:ss').dateTime;
              break;
            case  'Message-Id' : 
              messageId = headersItem.value!;
              break;
            case  'Message-ID' : 
              messageId = headersItem.value!;
              break;
      */
        enoughMail.Envelope envelope = mimeItem.envelope!;
        // contentType = envelope.;
        from = envelope.from![0].email;
        subject = _subjectFromEnvelope!;
        date = jiffyPackage.Jiffy(envelope.date, 'EEE, dd MMM yyyy hh:mm:ss').dateTime;
        // deliveryDate = envelope.
        messageId = envelope.messageId;        

      }

      // Create Email Header From Sorted Headers
      var emailHeader = EmailHeader.withId(
        subject: handleFetchedComplexBase64(subject),
        from: from,
        date: handleSelectDate( 
          date: date,
          deliveryDate: deliveryDate
        ),
        emailId: currentIndex,
        messageId: messageId,
        clientEmail: emailAddress
      );

      // Add Each Header To Our Temporary List
      fetchedEmailHeaderList.add( 
        EmailItemModel(
          header: emailHeader,
          emailHtml: _decodeTextHtmlPart,
          text: _decodeTextPlainPart,
          mediaType: mediaType,
          hasAttachments: _hasAttachments == true
        ) 
      );
      currentIndex++;

    }); // End of Iterating over each Mime

    return fetchedEmailHeaderList;    
  }  // End of fetchHeaderFields



  
  Future<void> fetchMessageItemBody ({
    // required enoughMail.ImapClient client,
    required EmailHeader incomingEmailHeader,
    required BuildContext context,
    // int messageSequenceId = 1,
  })  async {

    EmailItemModel _emailItemModel = emailList.firstWhere(
      (element) => ( 
        element.header.clientEmail != null
        && element.header.clientEmail == incomingEmailHeader.clientEmail
        && element.header.emailId == incomingEmailHeader.emailId
      )
    );

    /* 
      String? messageIdThatIsLoading;
      bool isLoadingSingleEmail;
    */

    messageIdThatIsLoading = _emailItemModel.header.messageId;
    isLoadingSingleEmail = true;
    notifyListeners();

    Future.delayed(
      Duration(milliseconds: 1), 
      () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) => SingleEmailWebviewScreen())
        );
      }    
    );



    var relatedClientItem = clientList.firstWhere(
      (element) => element.emailAccount.emailAddress == incomingEmailHeader.clientEmail
    );
    var _imapClient = relatedClientItem.imapClient;

    int? _messageSequenceId = incomingEmailHeader.emailId! ;
    var rawResponse = await _imapClient?.fetchMessage(
    // var rawResponse = await client.fetchMessage(
      _messageSequenceId,
      // 'BODY[]'
      // 'ENVELOPE'
      // "BODY.PEEK[]"
      "( BODY.PEEK[] UID )"
      // 'BODY[TEXT]'
      
    );
      // 1,31,
      // "BODY.PEEK[HEADER.FIELDS (Subject From Date Delivery-date Content-Type charset )]"
      // "BODY.PEEK[HEADER]"
      // 'BODY.PEEK[HEADER.FIELDS (Received)]'
      // 'BODY.PEEK[HEADER.FIELDS (Message-ID)]'  // Message-ID BU SEKILDE
      // 'BODY.PEEK[HEADER.FIELDS (Message-ID Received)]'
      // 'BODY[]'
      // '( BODY[] UID )'
      // 'BODY[TEXT]'
   
    var mappedData = rawResponse?.messages;

    if ( mappedData != null) {
      var _body = mappedData[0].body;
      var _guid = mappedData[0].guid;
      var _headers = mappedData[0].headers;
      var _allPartsFlat = mappedData[0].allPartsFlat;
      var _sequenceId = mappedData[0].sequenceId;
      var _envelope = mappedData[0].envelope;
      var _mimeData = mappedData[0].mimeData;
      var _mediaType =  mappedData[0].mediaType;
      var _decodeTextHtmlPart =  mappedData[0].decodeTextHtmlPart();
      var _decodeTextPlainPart =  mappedData[0].decodeTextPlainPart();
      var _mimeDataContentType = _mimeData?.contentType;    
      var _mimeDataContentTypeValue = _mimeDataContentType?.value;  
      var _mimeDataParts = _mimeData?.parts;

      if ( _mimeDataParts != null ) {
        for ( int i = 0; i < _mimeDataParts.length; i++ ) {
          var tempMimeDataItem = _mimeDataParts[i];
          var tempMimeItemHeadersList = tempMimeDataItem.headersList;
          var containsHeader = tempMimeDataItem.containsHeader;
          var contentType = tempMimeDataItem.contentType;
          var contentTypeValue = contentType?.value;
          print('for loop -> i -> $i');
        }
      }

      var newEmailModel = EmailItemModel.fetchedBody(
        header: incomingEmailHeader,
        text: _decodeTextPlainPart,
        emailHtml: _decodeTextHtmlPart
      );
      var indexAtEmailList = emailList.indexWhere(
        (element) => (
          element.header.emailId == incomingEmailHeader.emailId
          && element.header.clientEmail == incomingEmailHeader.clientEmail
        ),
      );
      var newEmailList = [ ...emailList ];
      newEmailList.removeAt(indexAtEmailList);
      newEmailList.insert(
        indexAtEmailList,
        newEmailModel
      );
      emailList = [ ...newEmailList];

      print('hi');
    }

    print('hi');


    isLoadingSingleEmail = false;
    notifyListeners();


  }



  Future<void> seeMessageItemOnWebviewScreen ({
    // required enoughMail.ImapClient client,
    required EmailHeader incomingEmailHeader,
    required BuildContext context,
    // int messageSequenceId = 1,
  })  async {

    EmailItemModel _emailItemModel = emailList.firstWhere(
      (element) => ( 
        element.header.clientEmail != null
        && element.header.clientEmail == incomingEmailHeader.clientEmail
        && element.header.emailId == incomingEmailHeader.emailId
      )
    );

    /* 
      String? messageIdThatIsLoading;
      bool isLoadingSingleEmail;
    */

    messageIdThatIsLoading = _emailItemModel.header.messageId;
    // isLoadingSingleEmail = true;
    notifyListeners();

    Future.delayed(
      Duration(milliseconds: 1), 
      () {
        Navigator.of(context).push(
          CupertinoPageRoute(builder: (ctx) => SingleEmailWebviewScreen())
        );
      }    
    );
    notifyListeners();
  }



  Future<void> getHeaders ({
     required enoughMail.ImapClient client,
     required emailAddress,
    }) async {    

    // List Mailboxes
    late List<enoughMail.Mailbox> listResponse;
    try {

      listResponse = await client.listMailboxes();
      // print( listResponse.result.length); // How many Mailboxes do we have?
    } catch (err) {
      print(err);
    }
    
    if (listResponse.isNotEmpty) {

      // Select MailBox
      await client.selectMailbox( listResponse[0]);

      // Mail Count
      final mailCount = listResponse[0].messagesExists;
      
      final tempEmailsList = await fetchHeaderFields( 
        client, 
        emailAddress,
        1,  
        mailCount <= 50 ? mailCount : 50
      );
      // print('ThIS IS FETCHED HEADER FIELDS OF THIS CLIENT');
      // print(tempEmailsList);

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
        await reconnectAccounts!();
      }

      for(  int i = 0; i < clientList.length; i++) {
        await getHeaders( 
          client: clientList[i].imapClient!,  
          emailAddress: clientList[i].emailAccount.emailAddress
        );
      }

    }
    await Future.delayed(Duration(milliseconds: 1), () {
      notifyListeners();
    });
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

    if (
      // loginResponse.isOkStatus
      client.isConnected
    ) {

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
        prefs.getString('komnataMailClient')!
      ) as Map<String, dynamic>;
      final tempAccountList = extractedUserData['accountList'] as List;
      tempAccountList.add(accountToAdd);
      extractedUserData['accountList'] = tempAccountList;
      prefs.setString(
        'komnataMailClient', 
        convert.json.encode(extractedUserData)
      );

      if( _accountCount !=null) {
        _accountCount = _accountCount!+1;
      }
      
      clientList.add( ClientItem(
        emailAccount: newAccount,
        imapClient: client
      ) );
      notifyListeners();

      print('Account Below has been Added');
      print( accountToAdd );
    }    
  }   // End of addAccount


  

  // // This method is not used but will stay as an example...
  // Future<void> sendMailByMailer2 (  ) async {

  //   var options = new mailer2.SmtpOptions();
  //   options.hostName = incomingServer1;
  //   options.port = 465;
  //   options.name = mailAddress1;
  //   options.username = mailAddress1;
  //   options.password = mailPassword1;
  //   options.secured = true;
  //   options.requiresAuthentication = true;

    

  //   // Create our email transport.
  //   var emailTransport = new mailer2.SmtpTransport(options);

  //   // 'TEST NAME HERE';

  //   var envelope = new mailer2.Envelope();
  //   envelope.from = mailAddress1;
  //   envelope.sender = mailAddress1;
  //   envelope.recipients = [emailTarget1 , mailAddress1];
  //   envelope.senderName = 'TEST NAME HERE';
  //   envelope.subject = 'Test Subject';
  //   envelope.text = 'This is a test mail text!';

  //   print('NOW ITT IS TIME TO SEND EMAIL');
  //   // Email it.
  //   emailTransport.send(envelope)
  //     .then((envelope) { 
  //       print('Email sent!');
  //       print(envelope.sender);
  //     })
  //     .catchError((e) => print('Error occurred: $e'));
  // }  // End of sendMailByMailer2

  

  Future<void> sendMail ( EmailItemModel  emailItem ) async {
    // It will be used when it is possible to select sender Account
    // var senderClient = clientList.firstWhere( 
    //   ( item ) => item.emailAccount.emailAddress == emailItem.header.from  
    // );

    var senderClient = clientList[0];

    

    // var options = new mailer2.SmtpOptions();
    // options.hostName = senderClient.emailAccount.outgoingMailsServer;
    // options.port = int.parse(senderClient.emailAccount.outgoingMailsPort);
    // options.name = senderClient.emailAccount.emailAddress;
    // options.username = senderClient.emailAccount.emailAddress;
    // options.password = senderClient.emailAccount.emailPassword;
    // options.secured = true;
    // options.requiresAuthentication = true;


    var _smptServer = mailer_smtp.SmtpServer(
      senderClient.emailAccount.outgoingMailsServer,
      port:   int.parse(senderClient.emailAccount.outgoingMailsPort),
      name: senderClient.emailAccount.emailAddress,
      username: senderClient.emailAccount.emailAddress,
      password: senderClient.emailAccount.emailPassword,
    );


    // Create our email transport.
    // var emailTransport = new mailer2.SmtpTransport(options);

    // var envelope = new mailer2.Envelope();
    // envelope.from = senderClient.emailAccount.emailAddress;
    // envelope.sender = senderClient.emailAccount.emailAddress;
    // envelope.recipients = emailItem.header.recipients;
    // envelope.senderName = senderClient.emailAccount.senderName == null 
    //   ? 'NO NAME ENTERED' 
    //   : senderClient.emailAccount.senderName;
    // envelope.subject = emailItem.header.subject;
    // envelope.text = emailItem.text;


    final _message = mailer.Message()
      ..from = mailer.Address(senderClient.emailAccount.emailAddress, 'Your Komnata Name')
      ..recipients.addAll(
        emailItem.header.recipients!
      )
      ..subject = emailItem.header.subject
      ..text = emailItem.text;
      // ..html = "<h1>Test</h1>\n<p>Hey! Here's some HTML content</p>";


    // Email it.
    // emailTransport.send(envelope)
    //   .then((envelope) { 
    //     print('Email sent!');
    //     print(envelope.sender);
    //   })
    //   .catchError((e) => print('Error occurred: $e'));

    try {
      final sendReport = await mailer.send(_message, _smptServer);
      print('Message sent: ' + sendReport.toString());
    } on mailer.MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  } // End of sendMail Method

}  // End of MailConnectionProvider







