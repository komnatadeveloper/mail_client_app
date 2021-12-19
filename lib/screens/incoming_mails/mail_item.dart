import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart' as jiffyPackage;
import 'package:mail_client_app/providers/mail_connection_provider.dart';
import 'package:provider/provider.dart';
// helpers
import '../../helpers/helpers.dart' as helpers;

import '../../models/email_item_model.dart';

class MailItem extends StatelessWidget {

  // final EmailHeader   incomingMailsListItem;
  final EmailItemModel   incomingEmailItemModel;

  MailItem( this.incomingEmailItemModel );
  


  


  @override
  Widget build(BuildContext context) {
    var header = incomingEmailItemModel.header;
   


    return  Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        bottom: 0,
        top: 0,
      ),
      margin: EdgeInsets.only(
        top: 8,
        bottom: 4
      ),
      // decoration: BoxDecoration(
      //   border: Border.all(width: 1.0, color: Colors.white)
      // ),

      child: GestureDetector(
        onTap: () {
          print('Screens -> Incoming Mails -> Mail Item -> onTap -> ');
          print('Date: ${header.date}');
          print('Subject: ${header.subject}');
          print('emailId: ${header.emailId}');
          print('emailAccount.emailAddress: ${incomingEmailItemModel.emailAccount.emailAddress}');

          Provider.of<MailConnectionProvider>(context).fetchSingleMessage(
            messageSequenceId: incomingEmailItemModel.header.emailId,
            emailAccount: incomingEmailItemModel.emailAccount
            

          );
        },
        child: Column(
          children: <Widget>[

            // Email Sender Name
            Container(
              alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.only(
                top: 5,
                left: 5
              ),
              height: 20,
              child: Text( 
                header.from ,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headline6.color
                ),
              ),
            ),


            // Email Title
            Container(
              alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.only(
                left: 5
              ),
              child: Text( 
                header.subject,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold ,
                  color: Theme.of(context).textTheme.headline6.color
                ),
              )
            ),

            // Email Body & Date
            Container(
              alignment: Alignment(-1.0, -1.0),
              height: 12,
                margin: EdgeInsets.only(
                bottom: 5,
                left: 5
              ),

              child: Row(
                children: <Widget>[

                  // Email Body
                  Expanded(
                    child:                           
                    Text( 
                      // incomingMailsListItem.emailBody,
                      'This is Temporarily not OK',

                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.headline6.color,
                        fontWeight: FontWeight.w300
                      ),
                    )
                  ),

                  Text( 
                    // '  ${DateFormat('yyyy/MM/dd').format(incomingMailsListItem.date)}' ,
                    helpers.formattedDateForPrintOut(
                      header.date
                    ),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.headline6.color,
                      fontWeight: FontWeight.w300
                    ),
                  ),

                  // Container(
                  //   width: 50,
                  //   child: Text( 'AA' )
                  // ),
                ],

              ),
            ),
          ],
        ),
        
      )
    );
    
    
    
    
    
    
  }
}