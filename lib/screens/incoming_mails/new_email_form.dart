import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/mail_connection_provider.dart';


import '../../models/email_item_model.dart';

class NewEmailForm extends StatefulWidget {
  @override
  _NewEmailFormState createState() => _NewEmailFormState();
}

// STATE
class _NewEmailFormState extends State<NewEmailForm> {

  var _editedEnvelope = EmailItemModel.whenSendingEmail(
    header: EmailHeader.whenSendingEmail(
      from: '',
      recipients: [],
      subject: ''
    ),
    text: ''
  );

  final _toFocusNode = FocusNode();
  final _subjectFocusNode = FocusNode();
  final _contentFocusNode = FocusNode();

  final _formSendEmailobalKey = GlobalKey<FormState>();


  Future <void> _saveForm (  ) async {
    // final isValid = _formGlobalKey.currentState.validate();
    // if( !isValid ) {
    //   return;
    // }
    _formSendEmailobalKey.currentState.save(); 
    Provider.of<MailConnectionProvider>(context).sendMail( _editedEnvelope );
  }  // end of _saveForm

  @override
  void dispose() {
    _toFocusNode.dispose();
    _subjectFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var senderAccount = Provider.of<MailConnectionProvider>(context).clientList[0];
    return Column(
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
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Text(
                  senderAccount.emailAccount.emailAddress,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headline6.color
                  ),                             
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: Theme.of(context).textTheme.headline6.color,
                  ),
                  onPressed: () async {  

                    // Provider.of<MailConnectionProvider>(context, listen: false).sendMailByMailer2();
                    print(_editedEnvelope.header);
                    print(_editedEnvelope.text);
                    await _saveForm();
                  },
                ), 
              ],
            ),
          ),


          Expanded(
            child: LayoutBuilder(
              builder: ( ctx, constraints ) => SingleChildScrollView(
                child: Container(
                  
                  child: Form(
                    key: _formSendEmailobalKey,
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
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.headline6.color
                                ),
                                focusNode: _toFocusNode,
                                onSaved: ( value ) {
                                  _editedEnvelope = EmailItemModel.whenSendingEmail(
                                    header: EmailHeader.whenSendingEmail(
                                      from: _editedEnvelope.header.from,
                                      recipients: [ value ],
                                      subject: _editedEnvelope.header.subject
                                    ),
                                    text: _editedEnvelope.text
                                  );
                                },

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

                        // SUBJECT
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Subject',
                            labelStyle: TextStyle(
                              color: Colors.grey
                            ),

                            
                          ),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.headline6.color
                          ),
                          focusNode: _subjectFocusNode,
                          onFieldSubmitted: ( _ ) {
                            FocusScope.of(context).requestFocus( _contentFocusNode );
                          },
                          onSaved: ( value ) {
                            _editedEnvelope = EmailItemModel.whenSendingEmail(
                              header: EmailHeader.whenSendingEmail(
                                from: _editedEnvelope.header.from,
                                recipients: _editedEnvelope.header.recipients,
                                subject: value
                              ),
                              text: _editedEnvelope.text
                            );
                          },

                        ),

                        // MAIL CONTENT
                        TextFormField(
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
                            color: Theme.of(context).textTheme.headline6.color
                          ),
                          focusNode: _contentFocusNode,
                          onSaved: ( value ) {
                            _editedEnvelope = EmailItemModel.whenSendingEmail(
                              header: EmailHeader.whenSendingEmail(
                                from: _editedEnvelope.header.from,
                                recipients: _editedEnvelope.header.recipients,
                                subject: _editedEnvelope.header.subject
                              ),
                              text: value
                            );
                          },
                          
                        ),




                      ],
                    ),
                  )
                ),

              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).viewInsets.bottom,
          )
        ],
      );
  }
}


























      