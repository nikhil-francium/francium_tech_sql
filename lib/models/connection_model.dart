class ConnectionModel {
  static final String defaultPort = '5432';
  String connectionName;
  String host;
  String database;
  String user;
  String password;
  String port = defaultPort;

  ConnectionModel();

  @override
  String toString() {
    return '\nConnection Name - $connectionName\nHost - $host\nDatabase - $database\nUser - $user\nPassword - $password\nPort - $port';
  }

  factory ConnectionModel.fromJson(Map<String,String> connectionJSON){
    ConnectionModel connectionModel = ConnectionModel();
    connectionModel.connectionName = connectionJSON['connection_name'];
    connectionModel.host = connectionJSON['host'];
    connectionModel.database = connectionJSON['database'];
    connectionModel.user = connectionJSON['user'];
    connectionModel.password = connectionJSON['password'];
    connectionModel.port = connectionJSON['port'];
    return connectionModel;
  }

  Map<String,String> toJson(){
    Map<String,String> jsonData = {
      'connection_name' : connectionName,
      'host' : host,
      'database' : database,
      'user' : user,
      'password' : password,
      'port' : port
    };

    return jsonData;
  }
}
