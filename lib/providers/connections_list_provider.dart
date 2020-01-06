import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionsListProvider extends ChangeNotifier {
  SharedPreferences sharedPreferences;
  List<PostgresConnectionProvider> connections = [];
  bool isDarkTheme = false;

  ConnectionsListProvider() {
    initializeSharedPreferences();
  }

  void initializeSharedPreferences() async {
    if (sharedPreferences == null) {
      sharedPreferences = await SharedPreferences.getInstance();
      isDarkTheme = sharedPreferences.getBool('darkTheme') ?? false;
      List<String> connectionsList =
          sharedPreferences.getStringList('connections');
      if (connectionsList == null) {
        await sharedPreferences.setStringList('connections', []);
      } else {
        if (connectionsList.isNotEmpty) {
          connectionsList.forEach((connection) {
            Map<String, String> jsonConnection = jsonDecode(connection).cast<String,String>();
            connections.add(PostgresConnectionProvider(
                connectionModel: ConnectionModel.fromJson(jsonConnection)));
          });
        }
      }
      notifyListeners();
    }
  }


  Future<void> addConnection({@required ConnectionModel connectionModel}) async{
    connections
        .add(PostgresConnectionProvider(connectionModel: connectionModel));
    List<String> connectionsList =
        sharedPreferences.getStringList('connections');
    connectionsList.add(jsonEncode(connectionModel.toJson()));
    await sharedPreferences.setStringList('connections', connectionsList);
    notifyListeners();
  }

  Future<void> switchTheme() async {
    isDarkTheme = !isDarkTheme;
    await sharedPreferences.setBool('darkTheme', isDarkTheme);
    notifyListeners();
  }
}
