import 'package:flutter/material.dart';
import 'package:francium_tech_sql/providers/postgres_connection_provider.dart';
import 'package:provider/provider.dart';

class ResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);

    return Scaffold(
        appBar: AppBar(title: Text('Results')),
        body: Column(
          children: <Widget>[
            postgresConnectionProvider.minIndex != 0 &&
                    postgresConnectionProvider.maxIndex != 0
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Visibility(
                          visible: postgresConnectionProvider.minIndex > 1,
                          child: IconButton(
                            icon: Icon(Icons.arrow_left),
                            onPressed: () async {
                              postgresConnectionProvider.reachedMaxRows = false;
                              String currentQuery =
                                  '${postgresConnectionProvider.executableQuery}  limit ${postgresConnectionProvider.offset + 1} offset ${postgresConnectionProvider.minIndex - postgresConnectionProvider.offset - 1}';
                              await postgresConnectionProvider.executeQuery(
                                  currentQuery: currentQuery,
                                  isForwardFetch: false);
                            },
                          ),
                        ),
                        Text(
                            '${postgresConnectionProvider.minIndex} - ${postgresConnectionProvider.maxIndex}'),
                        Visibility(
                          visible: !postgresConnectionProvider.reachedMaxRows,
                          child: IconButton(
                            icon: Icon(Icons.arrow_right),
                            onPressed: () async {
                              String currentQuery =
                                  '${postgresConnectionProvider.executableQuery}  limit ${postgresConnectionProvider.offset + 1} offset ${postgresConnectionProvider.minIndex + postgresConnectionProvider.offset - 1}';
                              await postgresConnectionProvider.executeQuery(
                                  currentQuery: currentQuery);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Expanded(
              child: postgresConnectionProvider.results.isEmpty
                  ? Center(
                      child: Text('No results found'),
                    )
                  : ListView(
                      children: <Widget>[
                        Container(
                          child: Scrollbar(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                child: SafeArea(
                                  child: DataTableUI(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ));
  }
}

class DataTableUI extends StatefulWidget {
  @override
  _DataTableUIState createState() => _DataTableUIState();
}

class _DataTableUIState extends State<DataTableUI> {
  @override
  Widget build(BuildContext context) {
    final PostgresConnectionProvider postgresConnectionProvider =
        Provider.of<PostgresConnectionProvider>(context);
    void sortFunction(int index, bool needSortAsc) {
      bool sortAscending = false;
      int selectedIndex = index;
      List<List<dynamic>> currentResult =
          List.of(postgresConnectionProvider.results);
      if (index != postgresConnectionProvider.selectedIndex) {
        sortAscending = true;
      } else {
        sortAscending = needSortAsc;
      }
      currentResult.sort((a, b) {
        if (needSortAsc) {
          try {
            return a[selectedIndex].compareTo(b[selectedIndex]);
          } catch (e) {
            return a[selectedIndex]
                .toString()
                .compareTo(b[selectedIndex].toString());
          }
        }
        try {
          return b[selectedIndex].compareTo(a[selectedIndex]);
        } catch (e) {
          return b[selectedIndex]
              .toString()
              .compareTo(a[selectedIndex].toString());
        }
      });

      postgresConnectionProvider.updateResults(
          currentResult: currentResult,
          sortIndex: selectedIndex,
          isSortAscending: sortAscending);
    }

    List<DataColumn> getColumnHeaders() {
      List<DataColumn> columns = [];

      if (postgresConnectionProvider.columnHeaders.isEmpty) {
        return columns;
      }
      postgresConnectionProvider.columnHeaders
          .asMap()
          .forEach((columnIndex, value) {
        DataColumn dc = DataColumn(
            onSort: sortFunction,
            label: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            tooltip: value.toString());
        columns.add(dc);
      });
      return columns;
    }

    buildRow(List<dynamic> record) {
      List<DataCell> row = new List<DataCell>();
      record.asMap().forEach((index, value) {
        row.add(DataCell(
          Text(value.toString()),
        ));
      });

      return row;
    }

    List<DataRow> getRows() {
      List<DataRow> rows = [];

      if (postgresConnectionProvider.results.isEmpty) {
        return rows;
      }

      postgresConnectionProvider.results.forEach((row) {
        rows.add(DataRow(cells: buildRow(row)));
      });

      return rows;
    }

    return DataTable(
      sortColumnIndex: postgresConnectionProvider.selectedIndex,
      sortAscending: postgresConnectionProvider.sortAscending,
      columns: getColumnHeaders(),
      rows: getRows(),
    );
  }
}
