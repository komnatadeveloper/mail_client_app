import 'package:mailer2/mailer.dart' as mailer2;
import 'package:enough_mail/enough_mail.dart' as enoughMail;
import './email_account.dart';


class ClientItem {

  enoughMail.ImapClient imapClient;


  EmailAccount emailAccount;

  ClientItem({
    this.imapClient,
    this.emailAccount
  });

}

