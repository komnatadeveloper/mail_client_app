

class  EmailHeader {
  String from;
  String subject;
  String date; 

  EmailHeader( {
    this.from,
    this.subject,
    this.date
  } ) ;
}



class EmailItemModel {
  EmailHeader header;

  EmailItemModel( {
    this.header
  });


}