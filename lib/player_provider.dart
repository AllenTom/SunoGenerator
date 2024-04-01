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
  SongMeta? currentSong;

  PlayerProvider() {
    player.positionStream.listen((event) {
      currentPosition = event;
      notifyListeners();
    });
    player.playerStateStream.listen((event) {
      playerState = event;
      notifyListeners();
    });
    player.sequenceStateStream.listen((event) {
      if (event != null) {
        SongMeta? meta = event.currentSource!.tag as SongMeta?;
        if (meta != null) {
          currentSong = meta;
          notifyListeners();
        }
      }
    });
    player.durationStream.listen((event) {
      duration = event;
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
    await player.play();
    notifyListeners();
  }

  playSongs(List<SongMeta> songs) async {
    List<AudioSource> audioSources = [];
    for (var song in songs) {
      audioSources.add(
          AudioSource.uri(
              Uri.parse(song.audioUrl!),
              tag: song
          )
      );
    }
    final playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Specify the playlist items
      children: audioSources,
    );
    await player.setAudioSource(playlist,initialIndex: 0, initialPosition: Duration.zero);
    await player.play();
  }
}
