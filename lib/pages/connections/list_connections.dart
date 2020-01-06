import 'package:flutter/material.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/pages/connections/new_connection.dart';
import 'package:francium_tech_sql/pages/database/database_page.dart';
import 'package:francium_tech_sql/providers/connections_list_provider.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:francium_tech_sql/widgets/DrawerWidget.dart';
import 'package:provider/provider.dart';

class ConnectionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ConnectionsListProvider connectionsListProvider =
        Provider.of<ConnectionsListProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Francium SQL'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(15.0),
          child:  connectionsListProvider.connections.isEmpty
              ? Center(
                  child: Text(connectionsListProvider.sharedPreferences != null ? 'No Connections Found' : 'Loading connections...'),
                )
              : ListView(
                  children: connectionsListProvider.connections
                      .map((connectionProvider) => ChangeNotifierProvider<
                              PostgresConnectionProvider>.value(
                            value: connectionProvider,
                            child: ConnectionUI(
                              connectionModel:
                                  connectionProvider.connectionModel,
                            ),
                          ))
                      .toList()),
        ),
      ),
      drawer: DrawerWidget(),
      floatingActionButton: Visibility(
        visible: connectionsListProvider.sharedPreferences != null,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => NewConnectionPage()));
          },
          tooltip: 'Add Connection',
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}

class ConnectionUI extends StatelessWidget {
  final ConnectionModel connectionModel;
  ConnectionUI({@required this.connectionModel});

  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15.0),
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => ConnectingDialog(
                    postgresConnectionProvider: postgresConnectionProvider,
                  ));
        },
        child: Card(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Text('Connection Name - ${connectionModel.connectionName}'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Host - ${connectionModel.host}'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('User - ${connectionModel.user}'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Database - ${connectionModel.database}'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectingDialog extends StatefulWidget {
  final PostgresConnectionProvider postgresConnectionProvider;
  ConnectingDialog({@required this.postgresConnectionProvider});

  @override
  _ConnectingDialogState createState() => _ConnectingDialogState();
}

class _ConnectingDialogState extends State<ConnectingDialog> {
  bool connectionError = false;

  Future<void> executeAfterBuild(BuildContext context,
      PostgresConnectionProvider postgresConnectionProvider) async {
    await postgresConnectionProvider.connectToPostgres();
    if (postgresConnectionProvider.isConnected) {
      Navigator.of(context).pop();
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ChangeNotifierProvider<PostgresConnectionProvider>.value(
          value: postgresConnectionProvider,
          child: DatabasePage()
      )));
    } else {
      setState(() {
        connectionError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    executeAfterBuild(context, widget.postgresConnectionProvider);
    return AlertDialog(
      title: Row(
        children: <Widget>[
          connectionError
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: CircularProgressIndicator()),
          Container(
              child: Text(
                  '${connectionError ? 'Invalid Connection' : 'Connecting...'}'))
        ],
      ),
      actions: <Widget>[
        connectionError
            ? FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : Container()
      ],
    );
  }
}
