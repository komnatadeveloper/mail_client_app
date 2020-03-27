import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/mail_connection_provider.dart';


import './screens/incoming_mails/incoming_mails_screen.dart';
import './screens/accounts/accounts_screen.dart';
import './screens/settings/settings_screen.dart';
import './screens/add_exchange_account/add_exchange_account_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: MailConnectionProvider()
        )
        
      ],

      child: MaterialApp(
        title: 'MailClientApp',
        theme: ThemeData(
          // primarySwatch: Colors.black.[400],
          textTheme: ThemeData.light().textTheme.copyWith(

            title: TextStyle(
              color: Colors.white
            ),

            // headline1: TextStyle(
            //   color: Colors.white
            // )
          ),
          backgroundColor: Color.fromARGB(240, 20, 20, 20)
        ),
        home: IncomingMailsScreen(),
        routes: {
          SettingsScreen.routeName : (ctx) => SettingsScreen(),
          IncomingMailsScreen.routeName : (ctx) => IncomingMailsScreen(),
          AccountsScreen.routeName : (ctx) => AccountsScreen(),
          AddExchangeAccountScreen.routeName : (ctx) => AddExchangeAccountScreen(),

        }
      )   //Material App,

      
    );
      
    
    
    
  }
}


