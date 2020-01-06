import 'package:flutter/material.dart';

class Themes {
  static dynamic colorDark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.grey[900],
    accentColor: Colors.grey[900],
    buttonTheme: ButtonThemeData(
        minWidth: 12,
        buttonColor: Colors.blue,
        textTheme: ButtonTextTheme.primary
    ),
    fontFamily: 'Montserrat',
    toggleButtonsTheme: ToggleButtonsThemeData(
      fillColor: Colors.grey[850],
      selectedColor: Colors.black,
      borderWidth: 1,
      color: Colors.white,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      indicator: BoxDecoration(
         border: Border(bottom: BorderSide(color: Colors.white, width: 4.0))
      )
    ),
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
      body1: TextStyle(fontSize: 18.0, letterSpacing: 0.5),
      body2: TextStyle(fontSize: 22.0, letterSpacing: 0.5, fontWeight: FontWeight.w600),
      // : TextStyle(fontSize: 20, fontWeight: FontWeight.w300)
    ),
  );

  static dynamic colorLight = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue[900],
    accentColor: Colors.blue[900],
    canvasColor: Colors.white,
    buttonTheme: ButtonThemeData(
      minWidth: 12,
      buttonColor: Colors.blue[900],
      textTheme: ButtonTextTheme.primary
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
        fillColor: Colors.white,
        selectedColor: Colors.blue[900],
        borderWidth: 0,
        color: Colors.white,
        focusColor: Colors.white
    ),
    fontFamily: 'Montserrat',
    splashColor: Colors.blue[900],
    tabBarTheme: TabBarTheme(
      labelColor: Colors.blue[900],
      unselectedLabelColor: Colors.black,
      indicator: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.blue[900], width: 4.0))
      )
    ),
    textTheme: TextTheme(
      headline: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      title: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
      body1: TextStyle(fontSize: 18.0, letterSpacing: 0.5),
      body2: TextStyle(fontSize: 22.0, letterSpacing: 0.5, fontWeight: FontWeight.w600)
    ),
  );
}
