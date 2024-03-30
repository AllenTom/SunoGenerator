import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:untitled/api/client.dart';

import '../../api/entity.dart';
import 'home.dart';

class HomeProvider with ChangeNotifier {
  SunoClient client = SunoClient();
  List<SongMeta> songs = [];
  List<GenerateItem> generatingSong = [];
  bool isFirst = true;
  Song? currentSong;


  loadSongs() async {
    if (client.cookie.isEmpty) {
      return;
    }
    songs = await client.getSongMetadata();
    notifyListeners();
  }

  toInit() {
    songs = [];
    notifyListeners();
  }

  init() async {
    if (isFirst) {
      isFirst = false;
      loadSongs();
    }
  }


  updateCurrentSong(Song song) {
    currentSong = song;
    notifyListeners();
  }

  generateSong(String prompt, bool isInstrumental) async {
    var updateStateController = StreamController<List<GenerateItem>>();
    updateStateController.stream.listen((event) {
      generatingSong = event;
      notifyListeners();
    });
    await client.generateSong(
        prompt: prompt,
        updateStateController: updateStateController,
        instrumental: isInstrumental);

    generatingSong = [];
    notifyListeners();
    await loadSongs();
  }
}
