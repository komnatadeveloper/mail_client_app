import 'package:enough_mail/enough_mail.dart' as enoughMail;

import './email_account.dart';


class ClientItem {

  enoughMail.ImapClient? imapClient;


  EmailAccount emailAccount;

  ClientItem({
    required this.imapClient,
    required this.emailAccount
  });

}

