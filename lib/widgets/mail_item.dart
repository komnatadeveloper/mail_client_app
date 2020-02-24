import 'package:flutter/material.dart';
import 'package:mail_client_app/widgets/incoming_mails.dart';
import 'package:intl/intl.dart';

class MailItem extends StatelessWidget {

  final   incomingMailsListItem;

  MailItem( this.incomingMailsListItem );

  @override
  Widget build(BuildContext context) {
    return Column(
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
                    incomingMailsListItem.senderName ,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headline1.color
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
                    incomingMailsListItem.emailTitle,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold ,
                      color: Theme.of(context).textTheme.headline1.color
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
                          incomingMailsListItem.emailBody,

                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.headline1.color
                          ),
                        )
                      ),

                      Text( 
                        '  ${DateFormat('yyyy/MM/dd').format(incomingMailsListItem.date)}' ,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.headline1.color
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
            );
  }
}