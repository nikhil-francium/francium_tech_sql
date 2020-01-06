import 'package:flutter/material.dart';
import 'package:francium_tech_sql/pages/connections/list_connections.dart';
import 'package:francium_tech_sql/providers/connections_list_provider.dart';
import 'package:francium_tech_sql/themes/Themes.dart';
import 'package:provider/provider.dart';
import 'providers/connections_list_provider.dart';

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
      child: MaterialAppWithTheme()
    );
  }
}
class MaterialAppWithTheme extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final connectionList = Provider.of<ConnectionsListProvider>(context);
    return MaterialApp(
      title: 'FranciumSQL',
      home: ConnectionsList(),
      theme: connectionList.isDarkTheme ? Themes.colorDark : Themes.colorLight
    );
  }
}


