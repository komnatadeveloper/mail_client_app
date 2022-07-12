

class EmailAccount {

  String? senderName;  // Your prefered name
  String emailAddress;
  String emailPassword;
  String incomingMailsServer;
  String incomingMailsPort;
  String outgoingMailsServer;
  String outgoingMailsPort;

  DateTime? lastConnectionTime;



  // String emailAddress;
  // String emailPassword;
  // String incomingMailsServer;
  // String incomingPort;

  EmailAccount( {
    this.senderName,
    required this.emailAddress,
    required this.emailPassword,
    required this.incomingMailsServer,
    required this.incomingMailsPort,
    required this.outgoingMailsServer,
    required this.outgoingMailsPort,
  });



}