import 'package:flutter/cupertino.dart';

class ConnectionValidator {

  String validateInput({@required String input, @required String inputType}){
    if(input == null || input.isEmpty || input.trim().isEmpty){
      return '$inputType required.';
    }
    return null;
  }
}