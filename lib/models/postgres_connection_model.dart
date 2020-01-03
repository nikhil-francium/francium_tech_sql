import 'package:flutter/cupertino.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:postgres/postgres.dart';

class PostgresConnectionModel {

  static Future<PostgreSQLConnection> getConnection(
      {@required ConnectionModel connectionModel}) async {
    PostgreSQLConnection postgreSQLConnection;
    try {
      postgreSQLConnection = new PostgreSQLConnection(connectionModel.host,
          int.parse(connectionModel.port), connectionModel.database,
          username: connectionModel.user, password: connectionModel.password);
      await postgreSQLConnection.open();
    } catch (e) {
      return postgreSQLConnection;
    }
    return postgreSQLConnection;
  }
}
