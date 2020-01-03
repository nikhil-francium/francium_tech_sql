import 'package:flutter/material.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/models/postgres_connection_model.dart';
import 'package:postgres/postgres.dart';

class PostgresConnectionProvider extends ChangeNotifier {
  final ConnectionModel connectionModel;
  PostgreSQLConnection postgreSQLConnection;
  bool isConnected = false;
  String query;
  String message = '';
  List<List<dynamic>> results = [];
  List<dynamic> columnHeaders = [];
  int selectedIndex;
  bool sortAscending = true;
  int minIndex = 0, maxIndex = 0, offset = 50, currentOffset = 0;
  bool reachedMaxRows = false;

  PostgresConnectionProvider({@required this.connectionModel});

  Future<void> connectToPostgres() async {
    await PostgresConnectionModel.getConnection(
            connectionModel: connectionModel)
        .then((postgreSQLConnection) {
      if (postgreSQLConnection != null) {
        isConnected = !postgreSQLConnection.isClosed;
      }
      this.postgreSQLConnection = postgreSQLConnection;
    });
  }

  void closeConnection() {
    if (postgreSQLConnection != null && !postgreSQLConnection.isClosed) {
      postgreSQLConnection.close();
    }
  }

  void updateQuery({@required String query}) {
    this.query = query;
  }

  String getQuery() {
    return query;
  }

  Future<void> executeQuery({String currentQuery, bool isForwardFetch = true}) async {
    try {
      resetFilters();
      results = await postgreSQLConnection
          .query(currentQuery ?? '${query.trim()} limit ${offset + 1}');
      if (results != null && results.isNotEmpty) {
        if (results.length <= offset) {
          reachedMaxRows = true;
        }else {
          List<List<dynamic>> currentResult = List.of(results);
          currentResult.removeLast();
          results = currentResult;
        }
        if(isForwardFetch){
          if (results.length == offset) {
            minIndex = maxIndex + 1;
            maxIndex += offset;
            currentOffset = offset;
          } else {
            minIndex = maxIndex + 1;
            maxIndex += results.length;
            currentOffset = maxIndex - minIndex + 1;
          }
        }else {
          if (maxIndex - minIndex + 1 < offset) {
            maxIndex -= currentOffset;
          } else {
            maxIndex -= offset;
          }
          if (minIndex - offset >= 1) {
            minIndex -= offset;
          } else {
            minIndex = 1;
          }
        }
        columnHeaders = await getColumnsFromMap(currentQuery: currentQuery);
      } else {
        results = [];
        columnHeaders = [];
      }
      message = 'Success';
      notifyListeners();
    } catch (e) {
      results = [];
      columnHeaders = [];
      message = 'Failed';
      notifyListeners();
    }
  }

  Future<List<dynamic>> getColumnsFromMap({String currentQuery}) async {
    var resultMap = await postgreSQLConnection.mappedResultsQuery(
        currentQuery ?? '${query.trim()} limit ${offset + 1}');

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

  void updateResults(
      {@required List<List<dynamic>> currentResult,
      @required int sortIndex,
      @required bool isSortAscending}) {
    selectedIndex = sortIndex;
    sortAscending = isSortAscending;
    results = currentResult;
    notifyListeners();
  }

  void resetFilters() {
    selectedIndex = null;
    sortAscending = true;
  }

  void resetPaginationCount(){
    minIndex = 0;
    maxIndex = 0;
    offset = 50;
    currentOffset = 0;
    reachedMaxRows = false;
  }

  void resetMaxRows(){
    if(reachedMaxRows){
      reachedMaxRows = !reachedMaxRows;
      notifyListeners();
    }
  }
}
