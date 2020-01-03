
import 'package:flutter/material.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/models/postgres_connection_model.dart';
import 'package:postgres/postgres.dart';

class PostgresConnectionProvider  extends ChangeNotifier{

  final ConnectionModel connectionModel;
  PostgreSQLConnection postgreSQLConnection;
  bool isConnected = false;
  String query;
  String message = '';
  List<List<dynamic>> results = [];
  List<dynamic> columnHeaders = [];
  int selectedIndex = 0;
  bool sortAscending = true;
  Type selectedIndexType = String;
  List<dynamic> resultsFirstRow = [];


  PostgresConnectionProvider({@required this.connectionModel});

  Future<void> connectToPostgres() async{
    await PostgresConnectionModel.getConnection(connectionModel: connectionModel).then((postgreSQLConnection){
      if(postgreSQLConnection != null){
        isConnected = !postgreSQLConnection.isClosed;
      }
      this.postgreSQLConnection = postgreSQLConnection;
    });
  }

  void closeConnection(){
    if(postgreSQLConnection != null && !postgreSQLConnection.isClosed){
      postgreSQLConnection.close();
    }
  }

  void updateQuery({@required String query}){
    this.query = query;
  }

  String getQuery(){
    return query;
  }

  Future<void> executeQuery() async{
    try{
      resetFilters();
      results = await postgreSQLConnection.query(query);
      if(results != null && results.isNotEmpty) {
        resultsFirstRow = results[0];
        selectedIndexType = results[0][selectedIndex].runtimeType;
        columnHeaders = await getColumnsFromMap();
      }else{
        results = [];
        columnHeaders = [];
      }
      message = 'Success';
      notifyListeners();
    }catch(e){
      results = [];
      columnHeaders = [];
      message = 'Failed';
      notifyListeners();
    }
  }

  Future<List<dynamic>> getColumnsFromMap() async {

    var resultMap = await postgreSQLConnection.mappedResultsQuery(query);

    // Gets the column names as list
    Map tables = Map.from(resultMap.first);
    List<dynamic> cells = new List();
    tables.forEach((k, v) {
      Map values = Map.from(v);
      var cols = values.keys.toList().map((col) => "$col").toList();
      cells.addAll(cols);
    });
    return cells;
  }

  void updateResults({@required List<List<dynamic>> currentResult, @required int sortIndex, @required bool isSortAscending}){
    selectedIndex = sortIndex;
    sortAscending = isSortAscending;
    results = currentResult;
    notifyListeners();
  }

  void resetFilters(){
    selectedIndex = 0;
    sortAscending = true;
    selectedIndexType = String;
    notifyListeners();
  }


}