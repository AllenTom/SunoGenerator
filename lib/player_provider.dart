import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerProvider extends ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  Duration? duration;
  Duration? currentPosition;
  PlayerState? playerState;

  PlayerProvider() {
    player.positionStream.listen((event) {
      currentPosition = event;
      notifyListeners();
    });
    player.playerStateStream.listen((event) {
      playerState = event;
      notifyListeners();
    });
  }

  disposePlayer() async {
    await player.dispose();
  }

  setUrlAndPlay(String url) async {
    duration = await player.setUrl(url);
    await player.play();
    notifyListeners();
  }
}
