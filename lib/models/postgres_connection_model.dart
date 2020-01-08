import 'package:flutter/cupertino.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:postgres/postgres.dart';


class PostgresConnectionModel {

  String message = '';
  PostgreSQLConnection postgresConnection;


  static Future<PostgresConnectionModel> getConnection(
      {@required ConnectionModel connectionModel}) async {
    PostgresConnectionModel postgresConnectionModel = PostgresConnectionModel();
    PostgreSQLConnection postgreSQLConnection;
    try {
      postgreSQLConnection = new PostgreSQLConnection(connectionModel.host,
          int.parse(connectionModel.port), connectionModel.database,
          username: connectionModel.user, password: connectionModel.password);
      await postgreSQLConnection.open();
      postgresConnectionModel.postgresConnection = postgreSQLConnection;
    } catch (e) {
      postgresConnectionModel.message = e.toString();
    }
    return postgresConnectionModel;
  }
}
