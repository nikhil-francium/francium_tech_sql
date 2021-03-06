import 'package:flutter/material.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/models/postgres_connection_model.dart';
import 'package:postgres/postgres.dart';

class PostgresConnectionProvider extends ChangeNotifier {
  ConnectionModel connectionModel;
  PostgreSQLConnection postgreSQLConnection;
  bool isConnected = false;
  String query = '';
  String executableQuery = '';
  String message = '';
  String connectionMessage = '';
  List<List<dynamic>> results = [];
  List<dynamic> columnHeaders = [];
  int selectedIndex;
  bool sortAscending = true;
  int minIndex = 0, maxIndex = 0, offset = 50, currentOffset = 0;
  bool reachedMaxRows = false, isQueryFailed = false;

  PostgresConnectionProvider({@required this.connectionModel});

  Future<void> connectToPostgres() async {
    await PostgresConnectionModel.getConnection(
            connectionModel: connectionModel)
        .then((PostgresConnectionModel postgresConnectionModel) {
      if (postgresConnectionModel.postgresConnection != null) {
        isConnected = !postgresConnectionModel.postgresConnection.isClosed;
      }else{
        connectionMessage = postgresConnectionModel.message;
      }
      this.postgreSQLConnection = postgresConnectionModel.postgresConnection;
    });
  }

  Future<void> closeConnection() async{
    if (postgreSQLConnection != null && !postgreSQLConnection.isClosed) {
      isConnected = false;
      await postgreSQLConnection.close();
    }
  }

  void updateQuery({@required String query}) {
    this.query = query;
    notifyListeners();
  }

  String getQuery() {
    return query;
  }

  updateConnectionModel({@required ConnectionModel currentConnectionModel}){
      connectionModel = currentConnectionModel;
  }

  Future<void> executeQuery(
      {String currentQuery, bool isForwardFetch = true}) async {
    try {
      resetFilters();
      String queryToBeExecuted =
          currentQuery ?? checkQuery(removeSemiColon(query.trim()));
      results = await postgreSQLConnection.query(queryToBeExecuted);
      if (results != null && results.isNotEmpty) {
        if (results.length <= offset) {
          reachedMaxRows = true;
        } else {
          List<List<dynamic>> currentResult = List.of(results);
          currentResult.removeLast();
          results = currentResult;
        }
        if (isForwardFetch) {
          if (results.length == offset) {
            minIndex = maxIndex + 1;
            maxIndex += offset;
            currentOffset = offset;
          } else {
            minIndex = maxIndex + 1;
            maxIndex += results.length;
            currentOffset = maxIndex - minIndex + 1;
          }
        } else {
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
        columnHeaders =
            await getColumnsFromMap(currentQuery: queryToBeExecuted);
        if(columnHeaders.isEmpty ||  columnHeaders.length != results[0].length){
          results = [];
          columnHeaders = [];
          resetPaginationCount();
          resetFilters();
          isQueryFailed = true;
          message = 'Row length incompatible with columns length';

        }else{
          message = 'Success';
        }
      } else {
        results = [];
        columnHeaders = [];
        message = 'Success';
        resetPaginationCount();
        resetFilters();
      }
      notifyListeners();
    } catch (e) {
      results = [];
      columnHeaders = [];
      resetPaginationCount();
      resetFilters();
      isQueryFailed = true;
      message = e.toString();

      notifyListeners();
    }
  }

  Future<List<dynamic>> getColumnsFromMap({String currentQuery}) async {

    List<dynamic> cells = [];

    try {
      var resultMap = await postgreSQLConnection.mappedResultsQuery(
          currentQuery);


      // Gets the column names as list
      Map tables = Map.from(resultMap.first);
      tables.forEach((k, v) {
        Map values = Map.from(v);
        var cols = values.keys.toList().map((col) => "$col").toList();
        cells.addAll(cols);
      });

    }catch(e){

    }
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
    isQueryFailed = false;
  }

  void resetPaginationCount() {
    minIndex = 0;
    maxIndex = 0;
    offset = 50;
    currentOffset = 0;
    reachedMaxRows = false;
  }

  void resetMaxRows() {
    if (reachedMaxRows) {
      reachedMaxRows = !reachedMaxRows;
      notifyListeners();
    }
  }

  String checkQuery(String currentQuery) {
    if(!currentQuery.toLowerCase().trim().startsWith('select')){
      return currentQuery.trim();
    }
    String query = '';
    String orderSubString = '', limitSubString = '', orderWithoutLimit = '';

    if (currentQuery.contains('order')) {
      orderSubString = currentQuery.substring(currentQuery.indexOf('order'));
    }
    if (currentQuery.contains('limit')) {
      limitSubString = currentQuery.substring(currentQuery.indexOf('limit'));
    }

    if (orderSubString.isNotEmpty) {
      if (orderSubString.contains('limit')) {
        orderWithoutLimit =
            orderSubString.replaceAll(limitSubString, '').trim();
      } else {
        orderWithoutLimit = orderSubString.trim();
      }

      query +=
          currentQuery.replaceAll(orderSubString, orderWithoutLimit).trim();
    } else if (limitSubString.isNotEmpty) {
      query += currentQuery.replaceAll(limitSubString, '').trim();
    } else {
      query += currentQuery.trim();
    }

    this.query = query;
    executableQuery = query;

    return executableQuery + ' ' + 'limit ${offset + 1}';
  }

  String removeSemiColon(String currentQuery) {
    if (currentQuery.trim().lastIndexOf(";") ==
        currentQuery.trim().length - 1) {
      currentQuery =
          currentQuery.trim().substring(0, currentQuery.trim().length - 1);
    }
    return currentQuery.trim();
  }
}
