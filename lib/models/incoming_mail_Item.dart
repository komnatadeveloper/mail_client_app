import 'package:flutter/foundation.dart';   // to use @required decorator

class IncomingMailItem {
  final String senderName;
  final String emailTitle;
  final String emailBody;
  final DateTime date;

  IncomingMailItem ( {
    @required this.senderName,
    @required this.emailTitle,
    @required this.emailBody,
    @required this.date
  } );
}