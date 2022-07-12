import 'package:flutter/material.dart';
import 'package:mail_client_app/models/mail_connection_provider_status.dart';
import 'package:provider/provider.dart';

import './providers/mail_connection_provider.dart';
import './providers/clients_provider.dart';


import './screens/incoming_mails/incoming_mails_screen.dart';
import './screens/accounts/accounts_screen.dart';
import './screens/settings/settings_screen.dart';
import './screens/splash_screen.dart';
import './screens/add_exchange_account/add_exchange_account_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [


        ChangeNotifierProvider.value(
          value: ClientsProvider()
        ),

        ChangeNotifierProxyProvider<ClientsProvider, MailConnectionProvider>(
          create: ( ctx ) => MailConnectionProvider( 
            mailConnectionProviderStatus: MailConnectionProviderStatus(),
            clientList: [],
            emailList: [],
            reconnectAccounts: null  
          ),
          update: ( _, clientsProvider, previosMailConnectionProvider ) => MailConnectionProvider(
            mailConnectionProviderStatus: previosMailConnectionProvider?.mailConnectionProviderStatus,
            clientList: clientsProvider.clientList,
            emailList: previosMailConnectionProvider!.emailList  ,
            reconnectAccounts: clientsProvider.connectAndAddAllAccounts1
          )

        )
        
      ],

      child: VarMaterialApp()

      
    );
    
    
  }
}


class VarMaterialApp extends StatefulWidget {
  @override
  _VarMaterialAppState createState() => _VarMaterialAppState();
}

// STATE
class _VarMaterialAppState extends State<VarMaterialApp> {

  // var _isInited = false;

  @override
  void initState() {
    Provider.of<ClientsProvider>(
      context,
      listen: false
    ).initialiseApp()
      .then( ( _ )  {
        setState((){
          // _isInited = true;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'MailClientApp',
        theme: ThemeData(
          // primarySwatch: Colors.black.[400],
          textTheme: ThemeData.light().textTheme.copyWith(

            headline6: TextStyle(
              color: Colors.white
            ),

            // headline1: TextStyle(
            //   color: Colors.white
            // )
          ),
          backgroundColor: Color.fromARGB(240, 20, 20, 20)
        ),
        // home: IncomingMailsScreen(),
        home: Consumer<ClientsProvider>(
          builder: ( ctx, clientsProvider, _ ) => clientsProvider.isInitialising
            ? SplashScreen( 'Initialising...' )
            : IncomingMailsScreen()

        ),
        routes: {
          SettingsScreen.routeName : (ctx) => SettingsScreen(),
          IncomingMailsScreen.routeName : (ctx) => IncomingMailsScreen(),
          AccountsScreen.routeName : (ctx) => AccountsScreen(),
          AddExchangeAccountScreen.routeName : (ctx) => AddExchangeAccountScreen(),
        }
      ); 
  }
}


