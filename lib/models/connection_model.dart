import 'dart:convert';

class ConnectionModel {
  static final String defaultPort = '5432';
  String connectionName;
  String host;
  String database;
  String user;
  String password;
  String port = defaultPort;
  List<String> savedQueries = [];
  List<String> historyQueries = [];

  ConnectionModel();

  @override
  String toString() {
    return '\nConnection Name - $connectionName\nHost - $host\nDatabase - $database\nUser - $user\nPassword - $password\nPort - $port';
  }



  factory ConnectionModel.fromJson(Map<String,String> connectionJSON){

    String getQueries(String queries){
      if(queries == null){
        return [].toString();
      }
      return queries;
    }

    ConnectionModel connectionModel = ConnectionModel();
    connectionModel.connectionName = connectionJSON['connection_name'];
    connectionModel.host = connectionJSON['host'];
    connectionModel.database = connectionJSON['database'];
    connectionModel.user = connectionJSON['user'];
    connectionModel.password = connectionJSON['password'];
    connectionModel.port = connectionJSON['port'];
    connectionModel.savedQueries = (jsonDecode(getQueries(connectionJSON['saved_queries'])) as List<dynamic>).cast<String>();
    connectionModel.historyQueries = (jsonDecode(getQueries(connectionJSON['history_queries'])) as List<dynamic>).cast<String>();
    return connectionModel;
  }

  Map<String,String> toJson(){
    Map<String,String> jsonData = {
      'connection_name' : connectionName,
      'host' : host,
      'database' : database,
      'user' : user,
      'password' : password,
      'port' : port,
      'saved_queries': jsonEncode(savedQueries),
      'history_queries': jsonEncode(historyQueries),
    };

    return jsonData;
  }
}
