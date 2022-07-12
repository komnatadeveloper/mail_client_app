


class  EmailHeader {
  String from;
  String subject;
  DateTime? date; 
  List<String>? recipients;  // list of people, when sending email
  int? emailId;
  String? messageId;
  String? clientEmail;

  EmailHeader( {
    required this.from,
    required this.subject,
    this.date
  });

  EmailHeader.withId( {
    required this.from,
    required this.subject,
    this.date,
    required this.emailId,
    this.messageId,
    this.clientEmail,
  });


  EmailHeader.whenSendingEmail( {
    required this.from,
    required this.subject,
    required this.recipients
  });

}



class EmailItemModel {
  EmailHeader header;

  // When Sending
  String? text;

  String? emailHtml;

  String? mediaType;

  bool? hasAttachments;


  EmailItemModel( {
    required this.header,
    this.text,
    this.emailHtml,
    this.mediaType,
    this.hasAttachments,
  });

  EmailItemModel.whenSendingEmail( {
    required this.header,
    required this.text
  });



  EmailItemModel.fetchedBody({    
    required this.header,
    required this.text,
    this.emailHtml,
  });




}