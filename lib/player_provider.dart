import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:untitled/api/entity.dart';
import 'package:untitled/screens/home/home.dart';

class PlayerProvider extends ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  Duration? duration;
  Duration? currentPosition;
  PlayerState? playerState;
  Song? currentSong;

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

  setUrlAndPlay(SongMeta songMeta) async {
    final url = songMeta.audioUrl;
    if (url == null) {
      return;
    }
    duration = await player.setUrl(url);
    currentSong = Song(
        id: songMeta.id!,
        title: songMeta.title!,
        imageUrl: songMeta.imageUrl!,
        duration: duration!);
    await player.play();
    notifyListeners();
  }
}
