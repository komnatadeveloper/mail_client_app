import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart' as jiffyPackage;
import 'package:provider/provider.dart';


// Providers
import '../../providers/mail_connection_provider.dart';

// Models
import '../../models/email_item_model.dart';

class MailItem extends StatelessWidget {

  // final EmailHeader   incomingMailsListItem;
  // final EmailHeader   incomingMailEmailItem.header;
  final EmailItemModel incomingMailEmailItem;

  MailItem( this.incomingMailEmailItem );


  String get formattedDateForPrintOut {   
    // If Today
    if( 
      intl.DateFormat( 'yyyy/MM/dd' ).format( DateTime.now() )
      == intl.DateFormat( 'yyyy/MM/dd' ).format( 
          incomingMailEmailItem.header.date!
        )   
    ) {
      return intl.DateFormat( 'HH:mm' ).format( incomingMailEmailItem.header.date! );
    }
    // If Yesterday
    if( 
      intl.DateFormat( 'yyyy/MM/dd' ).format(
        DateTime.now().subtract(
          Duration(days: 1)
        ) 
      )
      == intl.DateFormat( 'yyyy/MM/dd' ).format( 
        incomingMailEmailItem.header.date!
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
        incomingMailEmailItem.header.date!
      );  
    }
    // If Older
    return intl.DateFormat('yyyy/MM/dd').format( incomingMailEmailItem.header.date! );
  } // End of formattedDateForPrintOut


  @override
  Widget build(BuildContext context) {

    var hasAttachments =  incomingMailEmailItem.hasAttachments == true;
    if ( hasAttachments) {
      print(hasAttachments);
    }


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
          print('Date: ${incomingMailEmailItem.header.date}');
          print('Date: ${incomingMailEmailItem.header.subject}');
          print('Date: ${incomingMailEmailItem.header.emailId}');
          // Provider.of<MailConnectionProvider>(context, listen: false).fetchMessageItemBody(
          //   incomingEmailHeader: incomingMailEmailItem.header,
          //   context: context,
          // );
          Provider.of<MailConnectionProvider>(context, listen: false).seeMessageItemOnWebviewScreen(
            incomingEmailHeader: incomingMailEmailItem.header,
            context: context,
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
                incomingMailEmailItem.header.from ,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headline6?.color,
                ),
              ),
            ),


            // Email Title
            Container(
              // alignment: Alignment(-1.0, -1.0),
              margin: EdgeInsets.only(
                left: 5
              ),
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: Text( 
                      incomingMailEmailItem.header.subject,
                      style: TextStyle(
                        fontSize: 14,
                        // fontWeight: FontWeight.bold ,
                        color: Theme.of(context).textTheme.headline6?.color,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  if ( hasAttachments )   Icon(
                    Icons.attach_file, 
                    color: Theme.of(context).textTheme.headline6?.color,
                    size: 16,
                  ),
                ],
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
                      // incomingMailEmailItem.header.emailBody,
                      // 'This is Temporarily not OK',
                      incomingMailEmailItem.text ?? '-',
                      

                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.headline6?.color,
                        fontWeight: FontWeight.w300
                      ),
                    )
                  ),

                  Text( 
                    // '  ${DateFormat('yyyy/MM/dd').format(incomingMailEmailItem.header.date)}' ,
                    formattedDateForPrintOut,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.headline6?.color,
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