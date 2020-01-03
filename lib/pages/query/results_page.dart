import 'package:flutter/material.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:provider/provider.dart';

class ResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
    Provider.of<PostgresConnectionProvider>(context);


    List<DataColumn> getColumnHeaders(){
      List<DataColumn> columns = [];

      if(postgresConnectionProvider.columnHeaders.isEmpty){
        return columns;
      }
      postgresConnectionProvider.columnHeaders.forEach((column){
        DataColumn dc = DataColumn(
            label: Text(
              column.toString(),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            numeric: false,
            tooltip: column.toString());
        columns.add(dc);
      });
      return columns;
    }

    buildRow(record) {
      List<DataCell> row = new List<DataCell>();
      for (var value in record) {
        row.add(DataCell(
          Text(value.toString()),
        ));
      }
      return row;
    }

    List<DataRow> getRows() {
      List<DataRow> rows = [];

      if(postgresConnectionProvider.results.isEmpty){
        return rows;
      }

      postgresConnectionProvider.results.forEach((row){
        rows.add(DataRow(cells: buildRow(row)));
      });

      return rows;
    }


    return Scaffold(
      appBar: AppBar(title: Text('Results')),
      body: postgresConnectionProvider.results.isEmpty ? Center(child: Text('No results found'),) :  Scrollbar(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SafeArea(
              child: DataTable(
                sortColumnIndex: 0,
                sortAscending: true,
                columns: getColumnHeaders(),
                rows: getRows(),
              )
            ),
          ),
        ),
      )
    );
  }

}
