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
  ConcatenatingAudioSource? playlist;
  SequenceState? sequenceState;
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
    player.sequenceStateStream.listen((event) {
      sequenceState = event;
      notifyListeners();
    });
  }

  disposePlayer() async {
    await player.dispose();
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
    playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Specify the playlist items
      children: audioSources,
    );
    await player.setAudioSource(playlist!,initialIndex: 0, initialPosition: Duration.zero);
    await player.play();
  }

  addToQueue(SongMeta songMeta) async {
    final url = songMeta.audioUrl;
    if (url == null) {
      return;
    }
    if (playlist != null) {
      final currentIndex = player.currentIndex;
      if (currentIndex == null) {
        return;
      }
      playlist!.insert(currentIndex + 1, AudioSource.uri(Uri.parse(url), tag: songMeta));
      return;
    }
    notifyListeners();
  }
  addListToQueue(List<SongMeta> songMeta) async {
    List<AudioSource> audioSources = [];
    for (var song in songMeta) {
      audioSources.add(
          AudioSource.uri(
              Uri.parse(song.audioUrl!),
              tag: song
          )
      );
    }
    if (playlist != null) {
      final currentIndex = player.currentIndex;
      if (currentIndex == null) {
        return;
      }
      playlist!.insertAll(currentIndex + 1, audioSources);
      return;
    }
    notifyListeners();
  }
  seekQueue(int index) async {
    if (playlist != null) {
      await player.seek(Duration.zero, index: index);
    }
  }
}
