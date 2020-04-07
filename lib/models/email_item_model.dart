


class  EmailHeader {
  String from;
  String subject;
  DateTime date; 
  List<String> recipients;  // list of people, when sending email
  int emailId;

  EmailHeader( {
    this.from,
    this.subject,
    this.date
  });

  EmailHeader.withId( {
    this.from,
    this.subject,
    this.date,
    this.emailId
  });


  EmailHeader.whenSendingEmail( {
    this.from,
    this.subject,
    this.recipients
  });

}



class EmailItemModel {
  EmailHeader header;

  // When Sending
  String text;


  EmailItemModel( {
    this.header
  });

  EmailItemModel.whenSendingEmail( {
    this.header,
    this.text
  });


}