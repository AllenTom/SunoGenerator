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

  loadSongs({bool force = false}) async {
    if (client.cookie.isEmpty && !force) {
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

  generateSong(String? prompt, String? lyrics, bool isInstrumental,
      String? style, String? title) async {
    var updateStateController = StreamController<List<GenerateItem>>();
    updateStateController.stream.listen((event) {
      generatingSong = event;
      notifyListeners();
    });
    await client.generateSong(
        updateStateController: updateStateController,
        prompt: prompt,
        lyrics: lyrics,
        isInstrumental: isInstrumental,
        style: style,
        title: title);

    generatingSong = [];
    notifyListeners();
    await loadSongs();
  }

  deleteSong(String id) async {
    await client.deleteSongs([id]);
    await loadSongs(force: true);
  }
}
