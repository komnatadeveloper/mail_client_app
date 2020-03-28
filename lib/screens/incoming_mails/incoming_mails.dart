import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mail_connection_provider.dart';

import '../../models/incoming_mail_Item.dart';
import './mail_item.dart';



class IncomingMails  extends StatelessWidget {

  // final List<IncomingMailItem> incomingMailsList;
  final Size appBarPreferredHeight;

  IncomingMails( this.appBarPreferredHeight );



  


  @override
  Widget build(BuildContext context) {
    var mailConnectionProvider = Provider.of<MailConnectionProvider>(context);

    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          height: ( MediaQuery.of(context).size.height - appBarPreferredHeight.height - MediaQuery.of(context).padding.top - 24 ),

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


                child: MailItem( mailConnectionProvider.headersList[index] ),
                  

              );
            },
            itemCount: mailConnectionProvider.headersList.length,
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