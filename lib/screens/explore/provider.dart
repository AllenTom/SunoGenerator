import 'package:flutter/cupertino.dart';
import 'package:untitled/api/client.dart';
import 'package:untitled/api/entity.dart';

class ExploreProvider extends ChangeNotifier {
  SunoClient client = SunoClient();
  SunoPlaylist? trending;
  SunoPlaylist? newPlaylist;
  String category = "Trending";
  bool isFirst = true;
  bool isTrendingLoaded = false;
  bool isNewLoaded = false;

  switchCategory(String category) {
    this.category = category;
    notifyListeners();
  }

  loadTrending({
    bool force = false,
  }) async {
    if (isTrendingLoaded && !force) {
      return;
    }
    isTrendingLoaded = true;
    trending =
        await client.getPlaylist(id: "1190bf92-10dc-4ce5-968a-7a377f37f984");
    notifyListeners();
  }

  loadNew({
    bool force = false,
  }) async {
    if (isNewLoaded && !force) {
      return;
    }
    isNewLoaded = true;
    newPlaylist =
        await client.getPlaylist(id: "cc14084a-2622-4c4b-8258-1f6b4b4f54b3");
    notifyListeners();
  }
}
