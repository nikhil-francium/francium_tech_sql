import 'package:flutter/material.dart';
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              postgresConnectionProvider.postgreSQLConnection.databaseName),
        ),
        body: SafeArea(
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: <Widget>[
                Container(
                    constraints: BoxConstraints(maxHeight: 150.0),
                    child: TabBar(
                      isScrollable: true,
                      labelPadding: EdgeInsets.symmetric(horizontal: 20.0),
                      tabs: [
                        Tab( child: Text("Tables",style: TextStyle(color: Colors.black),), ),
                        Tab( child: Text("File Upload",style: TextStyle(color: Colors.black),) ),
                        Tab( child: Text("Saved",style: TextStyle(color: Colors.black),) ),
                        Tab( child: Text("History",style: TextStyle(color: Colors.black),) ),
                      ],
                    )
                ),
                Expanded(
                    child: TabBarView(
                        children: <Widget>[
                          TablesPage(),
                          FileUploadPage(),
                          SavedPage(),
                          HistoryPage()
                        ]
                    )
                )
              ],
            ),
          ),
        ),
        endDrawer: DrawerWidget(),
      ),
    );
  }
}


class FileUploadPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class SavedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
    Provider.of<PostgresConnectionProvider>(context);
    return QueryListUI(queries: postgresConnectionProvider.connectionModel.savedQueries, emptyQueriesText: 'No queries saved.');
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
    Provider.of<PostgresConnectionProvider>(context);
    return QueryListUI(queries: postgresConnectionProvider.connectionModel.historyQueries, emptyQueriesText: 'No history found.');
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
              onTap: (){
                postgresConnectionProvider.updateQuery(query: queries[index]);
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ChangeNotifierProvider<PostgresConnectionProvider>.value(
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
