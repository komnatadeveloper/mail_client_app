import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jiffy/jiffy.dart' as jiffyPackage;


// In IncomingMailsScreen we see when the email has been sent as a summary. 
// To See it in the Form that we wish, we are using this method
String  formattedDateForPrintOut (
  DateTime inputDate
) {   
    // If Today
    if( 
      intl.DateFormat( 'yyyy/MM/dd' ).format( DateTime.now() )
      == intl.DateFormat( 'yyyy/MM/dd' ).format( 
          inputDate
        )   
    ) {
      return intl.DateFormat( 'HH:mm' ).format( inputDate );
    }
    // If Yesterday
    if( 
      intl.DateFormat( 'yyyy/MM/dd' ).format(
        DateTime.now().subtract(
          Duration(days: 1)
        ) 
      )
      == intl.DateFormat( 'yyyy/MM/dd' ).format( 
        inputDate
      )   
    ) {
      return 'Yesterday';
    }
    // If Last 7 Days
    if( DateTime.now().isAfter(
      jiffyPackage.Jiffy(      
      intl.DateFormat( 'dd, MMM yyyy' ).format(
        DateTime.now()
          .subtract(
            Duration(days: 6)
          )
      ),
      'dd, MMM yyyy'
      ).dateTime
    )) {
      return intl.DateFormat( 'd, MMM' ).format( 
        inputDate
      );  
    }
    // If Older
    return intl.DateFormat('yyyy/MM/dd').format( inputDate );
  } // End of formattedDateForPrintOut