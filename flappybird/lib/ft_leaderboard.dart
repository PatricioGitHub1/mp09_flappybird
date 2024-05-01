import 'package:cupertino_base/app_data.dart';
import 'package:cupertino_base/ft_game.dart';
import 'package:flutter/material.dart';

class LeaderboardScreen extends StatelessWidget {
  final FtGame game;

  const LeaderboardScreen({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color.fromARGB(253, 114, 109, 109),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Leaderboard:',
              style: TextStyle(
                fontSize: 60,
                color: Colors.orange,
                fontFamily: 'Game',
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.5, // Set width to 50% of screen width
                child: ListView.builder(
                  itemCount: AppData.finalLeaderboard.length,
                  itemBuilder: (context, index) {
                    final player = AppData.finalLeaderboard[index];
                    final playerId = player['id'];
                    return Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${player['nickname']}',
                            style: TextStyle(
                              fontSize: 24,
                              color: playerId == AppData.player_id
                                  ? Colors.orange
                                  : Colors.white,
                              fontFamily: 'Game',
                            ),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            'Score: ${player['score']}',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Game',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
