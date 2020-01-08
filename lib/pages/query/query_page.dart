import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:francium_tech_sql/pages/query/results_page.dart';
import 'package:francium_tech_sql/providers/connections_list_provider.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:provider/provider.dart';

class QueryPage extends StatefulWidget {
  @override
  _QueryPageState createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  StreamController<int> streamController;
  List<Widget> tabs;

  @override
  void initState() {
    streamController = StreamController();
    tabs = [
      MessagePage(),
      QueryEditorPage(
        streamController: streamController,
      ),
      ResultsPage(),
    ];
    super.initState();
  }

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: streamController.stream,
        initialData: 1,
        builder: (context, AsyncSnapshot<int> snapshot) {
          return Scaffold(
            body: tabs[snapshot.data],
            bottomNavigationBar: BottomNavigationBar(
              onTap: (int selectedIndex) {
                streamController.sink.add(selectedIndex);
              },
              currentIndex: snapshot.data,
              items: [
                BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_turned_in),
                    title: Text('Message')),
                BottomNavigationBarItem(
                  icon: Icon(Icons.query_builder),
                  title: Text('Query'),
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.assignment_turned_in),
                    title: Text('Results')),
              ],
            ),
          );
        });
  }
}

class QueryEditorPage extends StatelessWidget {
  final StreamController streamController;
  QueryEditorPage({@required this.streamController});
  @override
  Widget build(BuildContext context) {
    Future<void> saveQueries() async {
      final ConnectionsListProvider connectionsListProvider =
          Provider.of<ConnectionsListProvider>(context, listen: false);
      final PostgresConnectionProvider postgresConnectionProvider =
          Provider.of<PostgresConnectionProvider>(context,listen: false);

      List<String> connectionsList = List.of(connectionsListProvider
          .sharedPreferences
          .getStringList('connections'));
      connectionsList[connectionsListProvider.currentConnectionIndex] =
          jsonEncode(postgresConnectionProvider.connectionModel.toJson());
      await connectionsListProvider.sharedPreferences
          .setStringList('connections', connectionsList);
    }

    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Execute Query'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              color: Colors.white,
              onPressed: () async {
                postgresConnectionProvider.connectionModel.savedQueries
                    .add(postgresConnectionProvider.getQuery().trim());
                await saveQueries();
              })
        ],
      ),
      body: Container(
        child: Column(children: [
          Container(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              initialValue: postgresConnectionProvider.getQuery(),
              onChanged: (String value) {
                postgresConnectionProvider.updateQuery(query: value.trim());
              },
              style: TextStyle(fontSize: 20.0),
              decoration:
                  InputDecoration.collapsed(hintText: 'Enter the query here'),
              autofocus: true,
              maxLines: null,
            ),
          ),
        ]),
      ),
      floatingActionButton: Visibility(
        visible: postgresConnectionProvider.getQuery().trim().isNotEmpty,
        child: FloatingActionButton(
          onPressed: () async {
            postgresConnectionProvider.resetPaginationCount();
            postgresConnectionProvider.resetFilters();
            postgresConnectionProvider.connectionModel.historyQueries
                .add(postgresConnectionProvider.getQuery().trim());
            showDialog(context: context,barrierDismissible: false, builder: (context){
              return AlertDialog(
                title: Wrap(
                  children: <Widget>[
                    CircularProgressIndicator(),
                    Text('Executing Query...')
                  ],
                ),
              );
            });
            await saveQueries();
            await postgresConnectionProvider.executeQuery();
            Navigator.pop(context);
            if(postgresConnectionProvider.isQueryFailed){
              streamController.sink.add(0);
            }else{
              streamController.sink.add(2);
            }
          },
          child: Icon(FontAwesomeIcons.bolt),
        ),
      ),
    );
  }
}

class MessagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:10.0),
          child: Text(postgresConnectionProvider.message.toString()),
        ),
      ),
    );
  }
}
