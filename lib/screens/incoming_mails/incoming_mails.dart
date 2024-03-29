import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mail_connection_provider.dart';
import './mail_item.dart';



class IncomingMails  extends StatelessWidget {

  final bool _isIncomingMailsScreenInitialised;
  final Size appBarPreferredHeight;

  IncomingMails( 
    this.appBarPreferredHeight, 
    this._isIncomingMailsScreenInitialised
  );




  @override
  Widget build(BuildContext context) {
    // var mailConnectionProvider = Provider.of<MailConnectionProvider>(context);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          height: ( MediaQuery.of(context).size.height 
            - appBarPreferredHeight.height 
            - MediaQuery.of(context).padding.top - 24 
          ),

          child: Column(
            children: <Widget>[
              !_isIncomingMailsScreenInitialised 
                ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[CircularProgressIndicator()],
                ) 
                : Container(),
              Expanded(
                child: Consumer<MailConnectionProvider>(
                  builder: ( ctx, mailConnectionProvider, child ) => mailConnectionProvider.headersList.length == 0
                    ? Center(
                      child: Text(
                        'No Mails',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.headline6?.color
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemBuilder: ( ctx, index ) {
                        return MailItem( 
                          // mailConnectionProvider.headersList[index] 
                          mailConnectionProvider.emailList[index]
                        );
                      },
                      itemCount: mailConnectionProvider.headersList.length,
                    )
                    
                ),
              )
            ],
          )
          
           
        );
      }
    );
  }
}



// ListTile(

//       title: Text('Facebook'),

//       subtitle: Text('John Doe has shared Shakira\'s Post'),
      
//     );




// // Email Sender Name
//                 Container(
//                   margin: EdgeInsets.all(0),
//                   height: 20,
//                   child: Text( 
//                     incomingMailsList[index].senderName 
//                   ),
//                 ),


//                 // Email Title
//                 Container(
//                   alignment: Alignment(-1.0, -1.0),
//                   child: Text( 
//                     incomingMailsList[index].emailTitle,
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.bold 
//                     ),
//                   )
//                 ),

//                 // Email Body & Date
//                 Container(
//                   alignment: Alignment(-1.0, -1.0),
//                   height: 12,

//                   child: Row(
//                     children: <Widget>[

//                       // Email Body
//                       Expanded(
//                         child:                           
//                         Text( 
//                           incomingMailsList[index].emailBody,

//                           overflow: TextOverflow.clip,
//                           style: TextStyle(
//                             fontSize: 12
//                           ),
//                         )
//                       ),

//                       Text( 
//                         DateFormat('yyyy/MM/dd').format(incomingMailsList[index].date) ,
//                         style: TextStyle(
//                           fontSize: 12
//                         ),
//                       ),

//                       // Container(
//                       //   width: 50,
//                       //   child: Text( 'AA' )
//                       // ),
//                     ],

//                   ),
//                 ),