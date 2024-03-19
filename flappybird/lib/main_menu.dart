import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'package:provider/provider.dart';
import 'package:cupertino_base/app_data.dart';

class MainMenuForm extends StatefulWidget {
  @override
  _MainMenuFormState createState() => _MainMenuFormState();
}

class _MainMenuFormState extends State<MainMenuForm> {
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _nicknameController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _ipController,
            decoration: InputDecoration(
              labelText: 'IP',
            ),
          ),
          SizedBox(height: 20.0),
          TextField(
            controller: _portController,
            decoration: InputDecoration(
              labelText: 'Port',
            ),
            keyboardType: TextInputType.number, // Set keyboard type to number
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')), // Allow only numbers
            ],
          ),
          SizedBox(height: 20.0),
          TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: 'Nickname',
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              String ip = _ipController.text;
              int port = int.tryParse(_portController.text) ?? 0; // Convert to int, default to 0 if invalid input
              String nickname = _nicknameController.text;

              if (kDebugMode) {
                print('IP: $ip');
                print('Port: $port');
                print('Nickname: $nickname');
              }
              
              AppData appData = Provider.of<AppData>(context, listen: false);
              appData.nickname = nickname;

              appData.initializeWebSocket(ip, port);
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }
}
