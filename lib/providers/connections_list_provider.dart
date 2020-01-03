


import 'package:flutter/cupertino.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';

class ConnectionsListProvider extends ChangeNotifier{

    List<PostgresConnectionProvider> connections = [];

    void addConnection({@required ConnectionModel connectionModel}){
      connections.add(PostgresConnectionProvider(connectionModel: connectionModel));
      notifyListeners();
    }
}