import 'package:flutter/material.dart';
import 'package:francium_tech_sql/pages/connections/list_connections.dart';
import 'package:francium_tech_sql/providers/connections_list_provider.dart';
import 'package:provider/provider.dart';

class IntroSlides extends StatefulWidget {
  @override
  _IntroSlidesState createState() => _IntroSlidesState();
}

class _IntroSlidesState extends State<IntroSlides> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: PageView(
          controller: pageController,
          children: <Widget>[ListConnectionIntroPage(pageController: pageController,), DBOperationsPage(pageController: pageController,)],
        ),
    );
  }
}

class ListConnectionIntroPage extends StatelessWidget {
  final PageController pageController;
  ListConnectionIntroPage({@required this.pageController});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                              'assets/images/intro_slides/connections_list.png'))),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Center(child: Text('Remote database connection on the go.',textAlign: TextAlign.center,)),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Center(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: FlatButton(
                        child: Text('Next >>'),
                        onPressed: () {
                          pageController.animateToPage(1,duration: Duration(milliseconds: 500),curve: Curves.ease);
                        },
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DBOperationsPage extends StatelessWidget {
  final PageController pageController;
  DBOperationsPage({@required this.pageController});
  @override
  Widget build(BuildContext context) {
    final ConnectionsListProvider connectionsListProvider =
    Provider.of<ConnectionsListProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                              'assets/images/intro_slides/db_operations.png'))),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Center(child: Text('Perform Real Time Database Operations.',textAlign: TextAlign.center,)),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: FlatButton(
                            child: Text('<< Prev'),
                            onPressed: () {
                              pageController.animateToPage(0,duration: Duration(milliseconds: 500),curve: Curves.ease);
                            },
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: FlatButton(
                            child: Text('Goto Main Page >>'),
                            onPressed: () async{
                              await connectionsListProvider.sharedPreferences.setBool('isNewUser', false);
                             Navigator.push(context, MaterialPageRoute(builder: (context)=> ChangeNotifierProvider<ConnectionsListProvider>.value(
                               value: connectionsListProvider,
                               child: ConnectionsList(),
                             )));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
