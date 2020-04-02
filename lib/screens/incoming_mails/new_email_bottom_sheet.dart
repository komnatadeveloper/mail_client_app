import 'package:flutter/material.dart';


import './new_email_form.dart';


class NewEmailBottomSheet extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    

    return Container(
      color: Theme.of(context).backgroundColor,
      child: NewEmailForm()
    );
  }
}