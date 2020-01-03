import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:francium_tech_sql/models/connection_model.dart';
import 'package:francium_tech_sql/pages/connections/list_connections.dart';
import 'package:francium_tech_sql/providers/connections_list_provider.dart';
import 'package:francium_tech_sql/validators/connection_validators.dart';
import 'package:provider/provider.dart';

class NewConnectionPage extends StatefulWidget {
  @override
  _NewConnectionPageState createState() => _NewConnectionPageState();
}

class _NewConnectionPageState extends State<NewConnectionPage> {
  ConnectionValidator connectionValidator;
  GlobalKey<FormState> formKey;
  ConnectionModel connectionModel;
  TextEditingController connectionNameController,
      hostController,
      databaseController,
      userController,
      passwordController,
      portController;
  @override
  void initState() {
    connectionValidator = ConnectionValidator();
    formKey = GlobalKey<FormState>();
    connectionModel = ConnectionModel();
    connectionNameController = TextEditingController();
    hostController = TextEditingController();
    databaseController = TextEditingController();
    userController = TextEditingController();
    passwordController = TextEditingController();
    portController = TextEditingController(text: ConnectionModel.defaultPort);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Connection'),
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Center(
            child: Form(
              key: formKey,
              child: ListView(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      leading: const Icon(Icons.settings_input_component),
                      title: TextFormField(
                          controller: connectionNameController,
                          onChanged: (String value) {
                            if (value.trim().isNotEmpty) {
                              connectionModel.connectionName = value.trim();
                            }
                          },
                          validator: (value) =>
                              connectionValidator.validateInput(
                                  input: value, inputType: 'Connection Name'),
                          decoration: InputDecoration(
                              labelText: 'Connection Name',
                              border: OutlineInputBorder())),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      leading: const Icon(FontAwesomeIcons.server),
                      title: TextFormField(
                          controller: hostController,
                          onChanged: (String value) {
                            if (value.trim().isNotEmpty) {
                              connectionModel.host = value.trim();
                            }
                          },
                          validator: (value) => connectionValidator
                              .validateInput(input: value, inputType: 'Host'),
                          decoration: InputDecoration(
                              labelText: 'Host', border: OutlineInputBorder())),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      leading: const Icon(FontAwesomeIcons.database),
                      title: TextFormField(
                          controller: databaseController,
                          onChanged: (String value) {
                            if (value.trim().isNotEmpty) {
                              connectionModel.database = value.trim();
                            }
                          },
                          validator: (value) =>
                              connectionValidator.validateInput(
                                  input: value, inputType: 'Database'),
                          decoration: InputDecoration(
                              labelText: 'Database',
                              border: OutlineInputBorder())),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: TextFormField(
                          controller: userController,
                          onChanged: (String value) {
                            if (value.trim().isNotEmpty) {
                              connectionModel.user = value.trim();
                            }
                          },
                          validator: (value) => connectionValidator
                              .validateInput(input: value, inputType: 'User'),
                          decoration: InputDecoration(
                              labelText: 'User', border: OutlineInputBorder())),
                    ),
                  ),
                  PasswordTextField(
                    connectionValidator: connectionValidator,
                    passwordController: passwordController,
                    connectionModel: connectionModel,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      leading: const Icon(Icons.power_input),
                      title: TextFormField(
                          controller: portController,
                          onChanged: (String value) {
                            if (value.trim().isNotEmpty) {
                              connectionModel.port = value.trim();
                            }
                          },
                          maxLength: 5,
                          validator: (value) => connectionValidator
                              .validateInput(input: value, inputType: 'Port'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            WhitelistingTextInputFormatter.digitsOnly
                          ],
                          decoration: InputDecoration(
                              labelText: 'Port', border: OutlineInputBorder())),
                    ),
                  ),
                  CreateConnection(
                    formKey: formKey,
                    connectionModel: connectionModel,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final ConnectionValidator connectionValidator;
  final TextEditingController passwordController;
  final ConnectionModel connectionModel;
  PasswordTextField(
      {@required this.connectionValidator,
      @required this.passwordController,
      @required this.connectionModel});
  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool isPasswordHidden = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        leading: const Icon(Icons.vpn_key),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: TextFormField(
                  controller: widget.passwordController,
                  onChanged: (String value) {
                    if (value.trim().isNotEmpty) {
                      widget.connectionModel.password = value.trim();
                    }
                  },
                  validator: (value) => widget.connectionValidator
                      .validateInput(input: value, inputType: 'Password'),
                  obscureText: isPasswordHidden,
                  decoration: InputDecoration(
                      labelText: 'Password', border: OutlineInputBorder())),
            ),
            Container(
              child: IconButton(
                icon: Icon(
                    isPasswordHidden ? Icons.visibility_off : Icons.visibility),
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CreateConnection extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final ConnectionModel connectionModel;
  CreateConnection({@required this.formKey, @required this.connectionModel});
  @override
  _CreateConnectionState createState() => _CreateConnectionState();
}

class _CreateConnectionState extends State<CreateConnection> {
  @override
  Widget build(BuildContext context) {
    final ConnectionsListProvider connectionsListProvider =
        Provider.of<ConnectionsListProvider>(context);
    return Container(
      margin: EdgeInsets.all(15.0),
      child: RaisedButton(
        padding: EdgeInsets.symmetric(vertical: 15.0),
        child: Text('Add Connection'),
        onPressed: () {
          FocusScope.of(context).requestFocus(FocusNode());
          if (widget.formKey.currentState.validate()) {
            connectionsListProvider.addConnection(
                connectionModel: widget.connectionModel);
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => ConnectionsList()),(Route<dynamic> route) => false);
          }
        },
      ),
    );
  }
}
