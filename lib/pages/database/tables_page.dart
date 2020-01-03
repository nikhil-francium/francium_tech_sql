import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:francium_tech_sql/pages/query/query_page.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:provider/provider.dart';

class TablesPage extends StatelessWidget {
  Future<List<dynamic>> getTables(
      {@required PostgresConnectionProvider postgresConnectionProvider}) async {
    List<dynamic> tableSchema =
        await postgresConnectionProvider.postgreSQLConnection.query(
            "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'");
    return tableSchema;
  }

  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);

    return Container(
        padding: EdgeInsets.all(15.0),
        child: FutureBuilder(
          future: getTables(
              postgresConnectionProvider: postgresConnectionProvider),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text('Fetching Tables'),
              );
            }
            return _TablesListUI(
              tablesList: snapshot.data,
            );
          },
        ));
  }
}

class _TablesListUI extends StatelessWidget {
  final List<dynamic> tablesList;
  _TablesListUI({@required this.tablesList});
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
    Provider.of<PostgresConnectionProvider>(context);
    return tablesList == null || tablesList.isEmpty
        ? Center(
            child: Text('No tables found.'),
          )
        : Container(
            child: ListView.builder(
                itemCount: tablesList.length,
                itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: (){
                          postgresConnectionProvider.updateQuery(query: 'select * from ${tablesList[index][0]} limit 50');
                          Navigator.push(context, MaterialPageRoute(builder: (context){
                            return ChangeNotifierProvider<PostgresConnectionProvider>.value(
                              value: postgresConnectionProvider,
                              child: QueryPage(),
                            );
                          }));
                        },
                        child: ListTile(
                          leading: Icon(FontAwesomeIcons.table),
                          title: Text(tablesList[index][0]),
                        ),
                      ),
                    )),
          );
  }
}
