import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';

import '../providers/connections_list_provider.dart';

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  @override
  Widget build(BuildContext context) {
    final ConnectionsListProvider connectionsListProvider =
        Provider.of<ConnectionsListProvider>(context);

    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(0.0),
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Francium Sql'.toUpperCase(),
              // AppLocalizations.of(context).translate('francium_sql'),
              style: TextStyle(color: Colors.white),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).accentColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Dark Theme',
                  // AppLocalizations.of(context).translate('dark_theme')
                ),
                Switch(
                  value: connectionsListProvider.isDarkTheme,
                  onChanged: (newVal) async {
                    await connectionsListProvider.switchTheme();
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: InkWell(child: Text('Quit'), onTap: () => exit(0))),
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: InkWell(
                  child: Text('About App'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutFrancium()),
                    );
                  })),
          SizedBox(
            height: 20,
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0, 0, 0),
              child: InkWell(
                  child: Text('About Francium'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutFrancium()),
                    );
                  })),
        ],
      ),
    );
  }
}

class AboutFrancium extends StatefulWidget {
  @override
  _AboutFranciumState createState() => _AboutFranciumState();
}

class _AboutFranciumState extends State<AboutFrancium> {
  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      withJavascript: true,
      url: "https://francium.tech",
      appBar: new AppBar(
        title: new Text("About Francium"),
      ),
    );
  }
}
