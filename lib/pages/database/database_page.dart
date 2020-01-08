import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:francium_tech_sql/pages/database/tables_page.dart';
import 'package:francium_tech_sql/pages/query/query_page.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:francium_tech_sql/widgets/DrawerWidget.dart';
import 'package:provider/provider.dart';

class DatabasePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);

    return WillPopScope(
      onWillPop: () {
        postgresConnectionProvider.closeConnection();
        return Future.value(true);
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
                postgresConnectionProvider.postgreSQLConnection.databaseName),
          ),
          body: DefaultTabController(
            length: 4,
            child: Column(
              children: <Widget>[
                Container(
                    constraints: BoxConstraints(maxHeight: 150.0),
                    child: TabBar(
                      isScrollable: true,
                      labelPadding: EdgeInsets.symmetric(horizontal: 20.0),
                      tabs: [
                        Tab(
                          child: Text(
                            "Tables",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        Tab(
                            child: Text(
                          "File Upload",
                          style: TextStyle(color: Colors.black),
                        )),
                        Tab(
                            child: Text(
                          "Saved",
                          style: TextStyle(color: Colors.black),
                        )),
                        Tab(
                            child: Text(
                          "History",
                          style: TextStyle(color: Colors.black),
                        )),
                      ],
                    )),
                Expanded(
                    child: TabBarView(children: <Widget>[
                  TablesPage(),
                  FileUploadPage(),
                  SavedPage(),
                  HistoryPage()
                ]))
              ],
            ),
          ),
          endDrawer: DrawerWidget(),
          floatingActionButton: FloatingActionButton(
            child: Icon(FontAwesomeIcons.bolt),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider.value(
                          value: postgresConnectionProvider,
                          child: QueryPage())));
            },
          ),
        ),
      ),
    );
  }
}

class FileUploadPage extends StatelessWidget {
  String query;
  PostgresConnectionProvider postgresConnectionProvider;

  @override
  Widget build(BuildContext context) {
    postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            RaisedButton(
                child: Text('Upload Query'),
                onPressed: () async {
                  await readFile();
                  if (postgresConnectionProvider.getQuery().isNotEmpty) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider<
                                    PostgresConnectionProvider>.value(
                                value: postgresConnectionProvider,
                                child: QueryPage())));
                  }
                })
          ],
        ),
      ),
    );
  }

  Future<void> readFile() async {
    query = await getFileContent();
    postgresConnectionProvider.updateQuery(query: query);
  }

  getFileContent() async {
    try {
      File file = await FilePicker.getFile(type: FileType.ANY);
      String content = await file.readAsString();
      return content;
    } catch (e) {
      return '';
    }
  }
}

class SavedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    return QueryListUI(
        queries: postgresConnectionProvider.connectionModel.savedQueries,
        emptyQueriesText: 'No queries saved.');
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    return QueryListUI(
        queries: postgresConnectionProvider.connectionModel.historyQueries,
        emptyQueriesText: 'No history found.');
  }
}

class QueryListUI extends StatelessWidget {
  final List<String> queries;
  final String emptyQueriesText;
  QueryListUI({@required this.queries, @required this.emptyQueriesText});
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    return queries.isEmpty
        ? Center(
            child: Text(emptyQueriesText),
          )
        : Container(
            child: ListView.builder(
                itemCount: queries.length,
                itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          postgresConnectionProvider.updateQuery(
                              query: queries[index]);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return ChangeNotifierProvider<
                                PostgresConnectionProvider>.value(
                              value: postgresConnectionProvider,
                              child: QueryPage(),
                            );
                          }));
                        },
                        child: ListTile(
                          title: Text(queries[index]),
                        ),
                      ),
                    )),
          );
  }
}
