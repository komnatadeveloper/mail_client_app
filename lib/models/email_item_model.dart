


class  EmailHeader {
  String from;
  String subject;
  String date; 
  List<String> recipients;  // list of people, when sending email

  EmailHeader( {
    this.from,
    this.subject,
    this.date
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