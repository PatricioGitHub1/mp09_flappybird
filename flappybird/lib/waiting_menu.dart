import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_data.dart';

class WaitingMenu extends StatefulWidget {
  @override
  _WaitingMenuState createState() => _WaitingMenuState();
}

class _WaitingMenuState extends State<WaitingMenu> {
  @override
  Widget build(BuildContext context) {
    AppData appData = Provider.of<AppData>(context);

    return Stack(
      children: [
        Container(
          child: ListView.builder(
            itemCount: appData.lobbyPlayers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(appData.lobbyPlayers[index]),
              );
            },
          ),
        ),
        Positioned.fill(
          child: Center(
            child: Text(
              appData.startCountdown,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize:  MediaQuery.of(context).size.width * 0.05
              ),
            ),
          ),
        ),
      ],
    );
  }
}
