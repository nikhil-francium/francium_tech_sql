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
  int currentConnectionIndex;
  List<int> selectedConnectionIndexes = [];

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
        await sharedPreferences.setBool('isNewUser', true);
      } else {
        if (connectionsList.isNotEmpty) {
          connectionsList.forEach((connection) {
            Map<String, String> jsonConnection =
                jsonDecode(connection).cast<String, String>();
            connections.add(PostgresConnectionProvider(
                connectionModel: ConnectionModel.fromJson(jsonConnection)));
          });
        }
      }
      notifyListeners();
    }
  }

  Future<void> addConnection(
      {@required ConnectionModel connectionModel}) async {
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

  Future<void> editConnection(
      {@required ConnectionModel connectionModel, @required int index}) async {
    connections[index]
        .updateConnectionModel(currentConnectionModel: connectionModel);
    List<String> connectionsList =
        sharedPreferences.getStringList('connections');
    connectionsList[index] = jsonEncode(connectionModel.toJson());
    await sharedPreferences.setStringList('connections', connectionsList);
    notifyListeners();
  }

  Future<void> deleteConnection(index) async {
    connections.removeAt(index);
    List<String> connectionsList =
        sharedPreferences.getStringList('connections');
    connectionsList.removeAt(index);
    await sharedPreferences.setStringList('connections', connectionsList);
    notifyListeners();
  }

  selectConnection({@required int selectedIndex}) {
    if (selectedConnectionIndexes.contains(selectedIndex)) {
      selectedConnectionIndexes.remove(selectedIndex);
    } else {
      selectedConnectionIndexes.add(selectedIndex);
    }
    notifyListeners();
  }

  selectAllConnections() {
    if (selectedConnectionIndexes.length != connections.length) {
      selectedConnectionIndexes =
          Iterable<int>.generate(connections.length).toList();
    } else {
      selectedConnectionIndexes = [];
    }
    notifyListeners();
  }

  unselectConnection() {
    selectedConnectionIndexes = [];
    notifyListeners();
  }

  Future<void> deleteAllConnections() async{
    List<String> newConnection = [];
    for (var index in selectedConnectionIndexes) {
      connections[index] = null;
    }
    connections.removeWhere((value) => value == null);
    for (var connection in connections) {
      newConnection.add(jsonEncode(connection.connectionModel));
    }
    await sharedPreferences.setStringList('connections', newConnection);
    selectedConnectionIndexes = [];
    notifyListeners();
  }
}
