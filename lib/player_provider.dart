import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:untitled/api/client.dart';
import 'package:untitled/api/entity.dart';
import 'package:untitled/store.dart';

class PlayerProvider extends ChangeNotifier {
  AudioPlayer player = AudioPlayer();
  Duration? duration;
  Duration? currentPosition;
  PlayerState? playerState;
  SongMeta? currentSong;
  ConcatenatingAudioSource? playlist;
  SequenceState? sequenceState;
  bool isHistoryLoaded = false;

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
      final index = sequenceState?.currentIndex;
      if (index != null && isHistoryLoaded) {
        updateIndexHistory(index);
      }
      notifyListeners();
    });
  }

  disposePlayer() async {
    await player.dispose();
  }

  playSongs(List<SongMeta> songs, {bool autoPlay = true}) async {
    List<AudioSource> audioSources = [];
    for (var song in songs) {
      audioSources.add(AudioSource.uri(Uri.parse(song.audioUrl!), tag: song));
    }
    playlist = ConcatenatingAudioSource(
      // Start loading next item just before reaching it
      useLazyPreparation: true,
      // Specify the playlist items
      children: audioSources,
    );
    await player.setAudioSource(playlist!,
        initialIndex: 0, initialPosition: Duration.zero);
    if (autoPlay) {
      await player.play();
    }
    // save playHistory
    await saveHistory();
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
      playlist!.insert(
          currentIndex + 1, AudioSource.uri(Uri.parse(url), tag: songMeta));
      // save playHistory
      await saveHistory();
      return;
    }

    notifyListeners();
  }

  addListToQueue(List<SongMeta> songMeta) async {
    List<AudioSource> audioSources = [];
    for (var song in songMeta) {
      audioSources.add(AudioSource.uri(Uri.parse(song.audioUrl!), tag: song));
    }
    if (playlist != null) {
      final currentIndex = player.currentIndex;
      if (currentIndex == null) {
        return;
      }
      playlist!.insertAll(currentIndex + 1, audioSources);
      await saveHistory();
      return;
    }
    // save playHistory
    notifyListeners();
  }

  seekQueue(int index) async {
    if (playlist != null) {
      await player.seek(Duration.zero, index: index);
    }
  }

  saveHistory() async {
    SunoClient client = SunoClient();
    final playlist = this.playlist?.sequence;
    if (playlist == null) {
      return;
    }
    final userId = client.userInfo?.id;
    if (userId == null) {
      return;
    }
    UserPlayHistory history = AppDataStore().playlistHistory.getHistory(userId);
    List<SongMeta> historyToSave = [];
    for (var element in playlist) {
      if (element.tag is SongMeta) {
        final song = element.tag as SongMeta;
        historyToSave.add(song);
      }
    }
    history.songs = historyToSave;
    AppDataStore().playlistHistory.setHistory(userId, history);
    await AppDataStore().saveHistory();
  }
  updateIndexHistory(int index) async {
    SunoClient client = SunoClient();
    final userId = client.userInfo?.id;
    if (userId == null) {
      return;
    }
    UserPlayHistory history = AppDataStore().playlistHistory.getHistory(userId);
    history.index = index;
    AppDataStore().playlistHistory.setHistory(userId, history);
    await AppDataStore().saveHistory();
  }

  loadHistory() async {
    SunoClient client = SunoClient();
    final userId = client.userInfo?.id;
    if (userId == null) {
      return;
    }
    if (AppDataStore().playlistHistory.historyMap.isNotEmpty) {
      final UserPlayHistory history = AppDataStore().playlistHistory.getHistory(userId);
      final songs = history.songs;
      await playSongs(songs, autoPlay: false);
      player.seek(Duration.zero, index: history.index);
    }
    isHistoryLoaded = true;
  }
}
