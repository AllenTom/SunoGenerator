import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/player_provider.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, PlayerProvider playerProvider, child) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Stack(

          children: [
            Image.network(
              playerProvider.currentSong?.imageUrl ?? "",
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
            Container(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.95),
            ),
            Container(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 300,
                    height: 300,
                    child: Image.network(
                      playerProvider.currentSong?.imageUrl ?? "",
                      width: 300,
                      height: 300,
                    ),
                  ),
                  Text(
                    playerProvider.currentSong?.title ?? "",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Builder(
                    builder: (context) {
                      final duration = playerProvider.duration;
                      final currentPosition = playerProvider.currentPosition;
                      if (duration == null || currentPosition == null) {
                        return Container();
                      }
                      return Container(
                        margin: EdgeInsets.only(top: 120),
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                    "${playerProvider.currentPosition!.inMinutes}:${(playerProvider.currentPosition!.inSeconds % 60).toString().padLeft(2, '0')}"),
                                Expanded(child: Container()),
                                Text(
                                    "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}"),
                              ],
                            ),
                            Slider(
                              value:
                                  currentPosition.inSeconds.toDouble(),
                              onChanged: (value) {
                                playerProvider.player
                                    .seek(Duration(seconds: value.toInt()));
                              },
                              min: 0,
                              max: duration.inSeconds
                                  .toDouble(),
                              inactiveColor:
                                  Theme.of(context).colorScheme.secondaryFixedDim,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(size: 48, Icons.skip_previous_rounded),
                                  onPressed: () {
                                    playerProvider.player.seekToPrevious();
                                  },
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 16, right: 16),
                                  child: IconButton(
                                    icon: Icon(
                                        size: 48,
                                        playerProvider.playerState!.playing
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded),
                                    onPressed: () {
                                      if (playerProvider.playerState!.playing) {
                                        playerProvider.player.pause();
                                      } else {
                                        playerProvider.player.play();
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(size: 48, Icons.skip_next_rounded),
                                  onPressed: () {
                                    playerProvider.player.seekToNext();
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    }
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
