import 'package:flutter/material.dart';

class IncomingAccountItem extends StatelessWidget {
  final String email;
  final String unreadCount;

  IncomingAccountItem(
    this.email,
    this.unreadCount
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            email,
            style: TextStyle(
              color: Theme.of(context).textTheme.headline6.color
            ),
          ),
          Chip(
            padding: EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 0
            ),
            label: Text(
              unreadCount,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).textTheme.headline6.color
              ),
            ),
            labelPadding: EdgeInsets.symmetric(
              horizontal: 0,
              vertical: 0
            ),
            backgroundColor: Colors.blue,
          )
        ],
      ),

    );
  }
}