import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/pages/connections/new_connection.dart';
import 'package:francium_tech_sql/pages/database/database_page.dart';
import 'package:francium_tech_sql/providers/connections_list_provider.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:francium_tech_sql/widgets/DrawerWidget.dart';
import 'package:francium_tech_sql/widgets/IntroSlides.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class ConnectionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ConnectionsListProvider connectionsListProvider =
        Provider.of<ConnectionsListProvider>(context);

    List<Widget> multiSelectOptions() {
      return [
        if (connectionsListProvider.selectedConnectionIndexes.length == 1)
          IconButton(
              icon: Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewConnectionPage(
                            index: connectionsListProvider
                                .selectedConnectionIndexes[0])));
                connectionsListProvider.unselectConnection();
              }),
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
      appBar: !(connectionsListProvider.sharedPreferences == null ||
              connectionsListProvider.sharedPreferences.getBool('isNewUser') ?? true)
          ? customAppBar()
          : null,
      body: SafeArea(
        child: connectionsListProvider.sharedPreferences == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : connectionsListProvider.sharedPreferences.getBool('isNewUser')?? true
                ? IntroSlides()
                : Container(
                    child: connectionsListProvider.connections.isEmpty
                        ? Center(
                            child: Text(
                                connectionsListProvider.sharedPreferences !=
                                        null
                                    ? 'No Connections Found'
                                    : 'Loading connections...'),
                          )
                        : ListView.builder(
                            itemCount:
                                connectionsListProvider.connections.length,
                            itemBuilder: (context, index) =>
                                ChangeNotifierProvider<
                                    PostgresConnectionProvider>.value(
                                  value: connectionsListProvider
                                      .connections[index],
                                  child: ConnectionUI(
                                    currentIndex: index,
                                    connectionModel: connectionsListProvider
                                        .connections[index].connectionModel,
                                  ),
                                )),
                  ),
      ),
      drawer: Visibility(
          visible: !(connectionsListProvider.sharedPreferences == null ||
              connectionsListProvider.sharedPreferences.getBool('isNewUser')?? true),
          child: DrawerWidget()),
      floatingActionButton: Visibility(
        visible: !(connectionsListProvider.sharedPreferences == null ||
            connectionsListProvider.sharedPreferences.getBool('isNewUser')?? true),
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

    Widget _buildIconText(text, IconData icon, TextStyle style) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
              flex: 3,
              child: Icon(
                icon,
                size: 18,
              )),
          SizedBox(
            width: 5,
          ),
          Flexible(
            flex: 17,
            child: Text(
              "$text",
              style: style,
            ),
          )
        ],
      );
    }

    Widget cardDetails() {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 5.0, 10.0),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildIconText(
                    connectionModel.connectionName,
                    Icons.settings_input_component,
                    Theme.of(context).textTheme.body2),
                SizedBox(
                  height: 10,
                ),
                _buildIconText(connectionModel.host, FontAwesomeIcons.server,
                    Theme.of(context).textTheme.body1),
                SizedBox(
                  height: 10,
                ),
                _buildIconText(connectionModel.user, Icons.person,
                    Theme.of(context).textTheme.body1),
                SizedBox(
                  height: 10,
                ),
                _buildIconText(
                    connectionModel.database,
                    FontAwesomeIcons.database,
                    Theme.of(context).textTheme.body1),
              ],
            ),
          ),
        ),
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
            if (connectionsListProvider.selectedConnectionIndexes.length > 0) {
              highlightConnection(currentIndex);
            } else {
              postgresConnectionProvider.connectionMessage = '';
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
                  '${connectionError ? 'Invalid Connection' : 'Connecting...'}')),
          Container(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: Text(
                widget.postgresConnectionProvider.connectionMessage,
                style: TextStyle(fontSize: 14),
              )),
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
