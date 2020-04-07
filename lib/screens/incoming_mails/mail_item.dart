import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart' as jiffyPackage;

import '../../models/email_item_model.dart';

class MailItem extends StatelessWidget {

  final EmailHeader   incomingMailsListItem;

  MailItem( this.incomingMailsListItem );


  String get formattedDateForPrintOut {   
    // If Today
    if( 
      intl.DateFormat( 'yyyy/MM/dd' ).format( DateTime.now() )
      == intl.DateFormat( 'yyyy/MM/dd' ).format( 
          incomingMailsListItem.date
        )   
    ) {
      return intl.DateFormat( 'HH:mm' ).format( incomingMailsListItem.date );
    }
    // If Yesterday
    if( 
      intl.DateFormat( 'yyyy/MM/dd' ).format(
        DateTime.now().subtract(
          Duration(days: 1)
        ) 
      )
      == intl.DateFormat( 'yyyy/MM/dd' ).format( 
        incomingMailsListItem.date
      )   
    ) {
      return 'Yesterday';
    }
    // If Last 7 Days
    if( DateTime.now().isAfter(
      jiffyPackage.Jiffy(      
      intl.DateFormat( 'dd, MMM yyyy' ).format(
        DateTime.now()
          .subtract(
            Duration(days: 6)
          )
      ),
      'dd, MMM yyyy'
      ).dateTime
    )) {
      return intl.DateFormat( 'd, MMM' ).format( 
        incomingMailsListItem.date
      );  
    }
    // If Older
    return intl.DateFormat('yyyy/MM/dd').format( incomingMailsListItem.date );
  } // End of formattedDateForPrintOut


  @override
  Widget build(BuildContext context) {


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
          print('Date: ${incomingMailsListItem.date}');
          print('Date: ${incomingMailsListItem.subject}');
          print('Date: ${incomingMailsListItem.emailId}');
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
                incomingMailsListItem.from ,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.title.color
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
                incomingMailsListItem.subject,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold ,
                  color: Theme.of(context).textTheme.title.color
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
                        color: Theme.of(context).textTheme.title.color,
                        fontWeight: FontWeight.w300
                      ),
                    )
                  ),

                  Text( 
                    // '  ${DateFormat('yyyy/MM/dd').format(incomingMailsListItem.date)}' ,
                    formattedDateForPrintOut,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.title.color,
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