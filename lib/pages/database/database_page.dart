import 'package:flutter/material.dart';
import 'package:francium_tech_sql/pages/database/tables_page.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
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
    return Container();
  }
}
class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
