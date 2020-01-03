class ConnectionModel {
  static final String defaultPort = '5432';
  String connectionName;
  String host;
  String database;
  String user;
  String password;
  String port = defaultPort;

  @override
  String toString() {
    return '\nConnection Name - $connectionName\nHost - $host\nDatabase - $database\nUser - $user\nPassword - $password\nPort - $port';
  }
}
