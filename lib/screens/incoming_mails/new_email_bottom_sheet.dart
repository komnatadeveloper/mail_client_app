import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mail_connection_provider.dart';

class NewEmailBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        children: <Widget>[

          // TOP ROW
          Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(
                color: Colors.grey,
                width: 0.2
              ))
            ),
            child: Row(             
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).textTheme.title.color,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  'komnatadeveloper@gmail.com',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.title.color
                  ),                             
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).textTheme.title.color,
                  ),
                  onPressed: () {  
                    // Provider.of<MailConnectionProvider>(context, listen: false).sendEmail();
                    // Provider.of<MailConnectionProvider>(context, listen: false).sendMailByEnough();
                    Provider.of<MailConnectionProvider>(context, listen: false).sendMailByMailer2();
                  },
                ), 
              ],
            ),
          ),


          Expanded(
            child: LayoutBuilder(
              builder: ( ctx, constraints ) => SingleChildScrollView(
                child: Container(
                  
                  child: Column(
                    children: <Widget>[

                      // TO
                      Row(
                        children: <Widget>[
                          Text(
                            'To',
                            style: TextStyle(
                              color: Colors.grey
                            ),
                          ),
                          
                          Expanded(
                            child: TextField(
                              maxLines: null,
                              keyboardType: TextInputType.multiline,

                            ),
                          ),
                          OutlineButton(
                            borderSide: BorderSide(
                              color: Colors.blue
                            ),
                            child: Text(
                              'Cc: Bcc',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10
                              ),
                            ),
                            onPressed: () {

                            },
                          )
                        ],
                      ),

                      // TITLE
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Subject',
                          labelStyle: TextStyle(
                            color: Colors.grey
                          ),

                          
                        ),

                      ),

                      // MAIL CONTENT
                      TextField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: 'Content',
                          labelStyle: TextStyle(
                            color: Colors.grey
                          ),
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none
                          
                        ),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.title.color
                        ),
                        
                      ),




                    ],
                  ),
                ),

              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      ),
    );
  }
}