import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/clients_provider.dart';

import '../../screens/settings/settings_screen.dart';
import './incoming_account_item.dart';





class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor
        ),
        child: SingleChildScrollView(        
          child: Container(
            child: Column(
              children: <Widget>[

                // Incoming Row
                Container(
                  padding: EdgeInsets.only(
                    top: 12
                  ),
                  color: Color.fromRGBO(0, 51, 102, 0.8),
                  child: ListTile(

                    leading: Icon(
                      Icons.system_update_alt,
                      color: Colors.blueGrey
                    ),
                    title: Text(
                      'Incoming',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18
                      ),
                    ),
                    subtitle: Text(
                      'All Accounts',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontWeight: FontWeight.w200,
                        fontSize: 12
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.keyboard_arrow_up),
                      color: Theme.of(context).textTheme.title.color,
                      onPressed: ( ) {
                        print( 'AppDrawer Incoming Icon Button');
                      },
                    ),
                    onTap: () {
                      // Navigator.of(context).pushReplacementNamed('/');
                      print( 'AppDrawer Incoming List Tile');
                    },
                  ),
                ),

                // List of Incoming Mails
                Consumer<ClientsProvider>(
                  builder: ( ctx2, clientsProvider, child ) => Container(
                    height: clientsProvider.clientList.length * 55.0,
                    child: ListView.builder(
                      itemCount: clientsProvider.clientList.length,
                      itemBuilder: (ctx2, index) {
                        return IncomingAccountItem(
                          clientsProvider.clientList[index].emailAccount.emailAddress,
                          '50'  // To be Done dynamically
                        );
                      },
                    ),
                  ),
                ),
                

                Row(
                  children: <Widget>[
                    Text(
                      'Folders',
                      style: TextStyle(
                        color: Colors.grey
                      ),                    
                    )
                  ],
                ),
                // AppBar(
                //   title: Text(
                //     'Hello Friend!',
                //   ),
                //   automaticallyImplyLeading: false,
                // ),
                Container(
                  color: Color.fromRGBO(0, 51, 102, 0.8),
                  child: ListTile(

                    leading: Icon(
                      Icons.mail_outline,
                      color: Colors.blueGrey
                    ),
                    title: Text(
                      'Viewed',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18
                      ),
                    ),                
                    onTap: () {
                      // Navigator.of(context).pushReplacementNamed('/');
                      print( 'AppDrawer Incoming List Tile');
                    },
                  ),
                ),
                Container(
                  color: Color.fromRGBO(0, 51, 102, 0.8),
                  child: ListTile(

                    leading: Icon(
                      Icons.send,
                      color: Colors.blueGrey
                    ),
                    title: Text(
                      'Sent',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.keyboard_arrow_up),
                      color: Theme.of(context).textTheme.title.color,
                      onPressed: ( ) {
                        print( 'AppDrawer Incoming Icon Button');
                      },
                    ),
                    onTap: () {
                      // Navigator.of(context).pushReplacementNamed('/');
                      print( 'AppDrawer Incoming List Tile');
                    },
                  ),
                ),
                Container(
                  color: Color.fromRGBO(0, 51, 102, 0.8),
                  child: ListTile(

                    leading: Icon(
                      Icons.archive,
                      color: Colors.blueGrey
                    ),
                    title: Text(
                      'Archieve',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.keyboard_arrow_up),
                      color: Theme.of(context).textTheme.title.color,
                      onPressed: ( ) {
                        print( 'AppDrawer Incoming Icon Button');
                      },
                    ),
                    onTap: () {
                      // Navigator.of(context).pushReplacementNamed('/');
                      print( 'AppDrawer Incoming List Tile');
                    },
                  ),
                ),
                Container(
                  color: Color.fromRGBO(0, 51, 102, 0.8),
                  child: ListTile(

                    leading: Icon(
                      Icons.delete,
                      color: Colors.blueGrey
                    ),
                    title: Text(
                      'Trash',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.keyboard_arrow_up),
                      color: Theme.of(context).textTheme.title.color,
                      onPressed: ( ) {
                        print( 'AppDrawer Incoming Icon Button');
                      },
                    ),
                    onTap: () {
                      // Navigator.of(context).pushReplacementNamed('/');
                      print( 'AppDrawer Incoming List Tile');
                    },
                  ),
                ),
                Container(
                  color: Color.fromRGBO(0, 51, 102, 0.8),
                  child: ListTile(

                    leading: Icon(
                      Icons.settings,
                      color: Colors.blueGrey
                    ),
                    title: Text(
                      'Settings',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.title.color,
                        fontSize: 18
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed(SettingsScreen.routeName);
                      // Navigator.of(context).pushReplacementNamed('/');

                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}