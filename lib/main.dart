import 'package:flutter/material.dart';
import 'package:francium_tech_sql/pages/connections/list_connections.dart';
import 'package:francium_tech_sql/providers/connections_list_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ConnectionsListProvider>(
          create: (_) => ConnectionsListProvider(),
        )
      ],
      child: MaterialApp(
        title: 'Francium SQL',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: ConnectionsList(),
      ),
    );
  }
}
