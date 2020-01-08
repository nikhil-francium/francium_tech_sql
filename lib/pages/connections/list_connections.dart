import 'package:flutter/material.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/pages/connections/new_connection.dart';
import 'package:francium_tech_sql/pages/database/database_page.dart';
import 'package:francium_tech_sql/providers/connections_list_provider.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:francium_tech_sql/widgets/DrawerWidget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ConnectionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ConnectionsListProvider connectionsListProvider =
        Provider.of<ConnectionsListProvider>(context);

    List<Widget> multiSelectOptions() {
      return [
        if(connectionsListProvider.selectedConnectionIndexes.length == 1)
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => NewConnectionPage( index:
            connectionsListProvider.selectedConnectionIndexes[0])));
            connectionsListProvider.unselectConnection();
          }
        ),
        IconButton(
          icon: Icon(Icons.select_all),
          onPressed: () {
            connectionsListProvider.selectAllConnections();
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            connectionsListProvider.deleteAllConnections();
          },
        )
      ];
    }

    Widget appbarTitle() {
      return Row(children: <Widget>[
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            connectionsListProvider.unselectConnection();
          },
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text(connectionsListProvider.selectedConnectionIndexes.length
              .toString()),
        )
      ]);
    }

    Widget customAppBar() {
      List<int> selectedIndexes =
          connectionsListProvider.selectedConnectionIndexes;
      return AppBar(
          title: (selectedIndexes.length > 0)
              ? appbarTitle()
              : Text('Francium SQL'),
          automaticallyImplyLeading: !(selectedIndexes.length > 0),
          actions: (selectedIndexes.length > 0) ? multiSelectOptions() : []);
    }

    return Scaffold(
      appBar: customAppBar(),
      body: SafeArea(
        child: Container(
          child: connectionsListProvider.connections.isEmpty
              ? Center(
                  child: Text(connectionsListProvider.sharedPreferences != null
                      ? 'No Connections Found'
                      : 'Loading connections...'),
                )
              : ListView.builder(
                  itemCount: connectionsListProvider.connections.length,
                  itemBuilder: (context, index) =>
                      ChangeNotifierProvider<PostgresConnectionProvider>.value(
                        value: connectionsListProvider.connections[index],
                        child: ConnectionUI(
                          currentIndex: index,
                          connectionModel: connectionsListProvider
                              .connections[index].connectionModel,
                        ),
                      )),
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
  final int currentIndex;
  ConnectionUI({@required this.connectionModel, @required this.currentIndex});
  ConnectionsListProvider connectionsListProvider;

  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    connectionsListProvider = Provider.of<ConnectionsListProvider>(context);

    Widget cardDetails() {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Connection Name - ${connectionModel.connectionName}'),
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
      );
    }

    return Container(
        child: Card(
      shape: RoundedRectangleBorder(
          side: BorderSide(
              color: connectionsListProvider.selectedConnectionIndexes
                      .contains(currentIndex)
                  ? Colors.blue[900]
                  : Colors.white)),
      child: GestureDetector(
        onLongPress: () {
          highlightConnection(currentIndex);
        },
        child: InkWell(
          onTap: () {
            if (connectionsListProvider.selectedConnectionIndexes
                .contains(currentIndex)) {
              connectionsListProvider.selectConnection(
                  selectedIndex: currentIndex);
            } else {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => ConnectingDialog(
                        postgresConnectionProvider: postgresConnectionProvider,
                        currentIndex: currentIndex,
                      ));
            }
          },
          child: (connectionsListProvider.selectedConnectionIndexes.length == 0)
              ? Slidable(
                  actionPane: SlidableStrechActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Edit',
                      color: Colors.grey[200],
                      icon: Icons.edit,
                      onTap: () => editConnection(currentIndex, context),
                    ),
                    IconSlideAction(
                      caption: 'Delete',
                      icon: Icons.delete,
                      color: Colors.grey[200],
                      onTap: () => connectionsListProvider
                          .deleteConnection(currentIndex),
                    ),
                  ],
                  child: cardDetails())
              : cardDetails(),
        ),
      ),
    ));
  }

  editConnection(index, context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NewConnectionPage(index: index)));
  }

  highlightConnection(int currentIndex) {
    connectionsListProvider.selectConnection(selectedIndex: currentIndex);
  }
}

class ConnectingDialog extends StatefulWidget {
  final PostgresConnectionProvider postgresConnectionProvider;
  final int currentIndex;
  ConnectingDialog(
      {@required this.postgresConnectionProvider, @required this.currentIndex});

  @override
  _ConnectingDialogState createState() => _ConnectingDialogState();
}

class _ConnectingDialogState extends State<ConnectingDialog> {
  bool connectionError = false;

  Future<void> executeAfterBuild(BuildContext context,
      PostgresConnectionProvider postgresConnectionProvider) async {
    final ConnectionsListProvider connectionsListProvider =
        Provider.of<ConnectionsListProvider>(context);

    await postgresConnectionProvider.connectToPostgres();
    if (postgresConnectionProvider.isConnected) {
      connectionsListProvider.currentConnectionIndex = widget.currentIndex;
      Navigator.of(context).pop();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ChangeNotifierProvider<PostgresConnectionProvider>.value(
                      value: postgresConnectionProvider,
                      child: DatabasePage())));
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
      title: Wrap(
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
