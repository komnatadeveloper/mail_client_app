import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mail_client_app/models/incoming_mail_Item.dart';

class IncomingMails  extends StatelessWidget {

  final List<IncomingMailItem> incomingMailsList;

  IncomingMails(this.incomingMailsList);


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,

      child: ListView.builder(
        itemBuilder: ( ctx, index ) {

          return Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              bottom: 0,
              top: 0,
            ),
            decoration: BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.white)
            ),


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
                    incomingMailsList[index].senderName ,
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
                    incomingMailsList[index].emailTitle,
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
                          incomingMailsList[index].emailBody,

                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.headline1.color
                          ),
                        )
                      ),

                      Text( 
                        '  ${DateFormat('yyyy/MM/dd').format(incomingMailsList[index].date)}' ,
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
            )
              

          );
        },
        itemCount: incomingMailsList.length,
      )

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