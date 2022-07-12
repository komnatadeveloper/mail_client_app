



// import 'dart:html';
// import 'dart:js_util';

// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:mail_client_app/models/email_item_model.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'dart:convert';
import 'dart:core';
import 'package:provider/provider.dart';


// Providers
import '../../providers/mail_connection_provider.dart';



class SingleEmailWebviewScreen extends StatefulWidget {
  // String? fcmToken;

  SingleEmailWebviewScreen({Key? key, }) : super(key: key);
  final _state = _SingleEmailWebviewScreenState();
  @override
  State<SingleEmailWebviewScreen> createState() => _state;

  // navigate2Link(link) {
  //   _state.navigateToUrl(link);
  // }
}

// ----------------------- STATE ------------------------
class _SingleEmailWebviewScreenState extends State<SingleEmailWebviewScreen> {
  late WebViewPlusController controller;

  double progress = 0;
  bool _isInited = false;

  String? html;
  String? text;

  // void navigateToUrl(String newUrl) {
  //   controller.webViewController.loadUrl(newUrl);
  // }

  // updateDeviceToken({required String fcmToken}) {
  //   Future.delayed(const Duration(milliseconds: 2), () {
  //     controller.webViewController.runJavascriptReturningResult("""
  //           window.localStorage.setItem(
  //             'firebaseDeviceID','${widget.fcmToken}'
  //           );
  //         """);
  //     getKeyFromSharedPrefs("person").then((String? value) {
  //       if (value != null) {
  //         dynamic person = json.decode(value.toString());
  //         sendUpdatedFcmTokenToApi(
  //             newDeviceID: fcmToken,
  //             previousDeviceID: widget.fcmToken,
  //             accessToken: person.refreshToken);
  //       }
  //     });
  //   });
  //   //----------------
  // }



  void loadLocalHtml ({
    required String html,
  }) async {
    final url = Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8')
    ).toString();
    controller.loadUrl(url);
  }

  @override
  void initState() {
    super.initState();
    // FirebaseMessaging.instance.getToken().then((token) {
    //   setKeyOnSharedPrefs("deviceToken", token.toString());
    //   widget.fcmToken = token;
    // });
    // FirebaseMessaging.instance.onTokenRefresh.listen((token) {
    //   widget.fcmToken = token;
    //   setKeyOnSharedPrefs("deviceToken", token.toString());
    //   updateDeviceToken(fcmToken: token);
    // }).onError((err) {
    //   // Error getting token.
    // });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if ( 
      _isInited == false 
      && Provider.of<MailConnectionProvider>(context).isLoadingSingleEmail == false
    ) {
      _isInited = true;   
      var  messageIdThatIsLoading = Provider.of<MailConnectionProvider>(context, listen: false).messageIdThatIsLoading;
      var relatedEmail =    Provider.of<MailConnectionProvider>(context, listen: false).emailList.firstWhere(
        (element) => element.header.messageId == messageIdThatIsLoading
      );
      html = relatedEmail.emailHtml;      
      text = relatedEmail.text;      
      setState(() { });
    } 
  }

 

  @override
  Widget build(BuildContext context) {
    var isLoadingSingleEmail = Provider.of<MailConnectionProvider>(context).isLoadingSingleEmail;

     var  messageIdThatIsLoading = Provider.of<MailConnectionProvider>(context).messageIdThatIsLoading;
     EmailHeader? emailHeader;
     if (messageIdThatIsLoading != null   ) {
        emailHeader  = Provider.of<MailConnectionProvider>(context).headersList.firstWhere(
          (element) => element.messageId == messageIdThatIsLoading
        );
     }     
      

    return WillPopScope(
      onWillPop: () async {
        if (await controller.webViewController.canGoBack()) {
          controller.webViewController.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          actions: [
            
          ],
          centerTitle: true,
          title: Text(
              emailHeader != null ? emailHeader.subject : '-',
              overflow: TextOverflow.ellipsis,
              maxLines: 3,
              style: TextStyle(
                fontSize: 14
              ),
            ),
        ),
        body: SafeArea(
            child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              color: Colors.red,
              backgroundColor: Colors.black,
            ),
            Expanded(
              child: ( isLoadingSingleEmail || _isInited == false ) 
                ?
                Center(
                  child: CircularProgressIndicator(),
                )
                :              
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: WebViewPlus(                  
                    javascriptMode: JavascriptMode.unrestricted,
                    onWebViewCreated: (controller) async {
                      this.controller = controller;
                      if ( html != null ) {
                        loadLocalHtml(html: html!); 
                      }
                    },
                    
                    onPageStarted: (url) async {
                      
                    },
                    onProgress: (progress) {
                      setState(() {
                        this.progress = progress / 100;
                      });
                    },
                    // initialUrl: constants.domain + "/pages/dashboard",
                  ),
                ),
            )
          ],
        )),
      ),
    );
  }
}
