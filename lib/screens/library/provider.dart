import 'package:flutter/foundation.dart';

import '../../api/client.dart';
import '../../api/entity.dart';

class LibraryProvider extends ChangeNotifier {
  SunoClient client = SunoClient();
  int feedPage = 0;
  int feedPageSize = 20;
  bool isFeedLoading = false;
  List<SongMeta> feed = [];
  bool hasMoreFeed = true;
  String category = "Songs";
  bool firstLoad = true;


  int playlistPage = 1;
  int playlistPageSize = 20;
  bool isPlaylistLoading = false;
  List<SunoPlaylist> playlists = [];
  bool hasMorePlaylist = true;



  init() {
    if (firstLoad) {
      loadFeed();
      loadPlaylist();
      firstLoad = false;
    }
  }

  loadFeed() async {
    if (isFeedLoading) {
      return;
    }
    isFeedLoading = true;
    List<SongMeta> songs = await client.getSongMetadata(
      page: feedPage,
    );
    feed.addAll(songs);
    if (songs.length < feedPageSize) {
      hasMoreFeed = false;
    }
    feedPage++;
    isFeedLoading = false;
    notifyListeners();
  }

  loadMoreFeed() {
    if (hasMoreFeed) {
      loadFeed();
    }
  }

  reloadFeed() async {
    feedPage = 0;
    feed = [];
    hasMoreFeed = true;
    await loadFeed();
  }

  loadPlaylist() async {
    if (isPlaylistLoading) {
      return;
    }
    isPlaylistLoading = true;
    var result = await client.getUserPlaylist(
      page: playlistPage,
    );
    playlists.addAll(result.playlists);
    final currentResultLen = result.playlists.length;
    if (currentResultLen < playlistPageSize) {
      hasMorePlaylist = false;
    }
    playlistPage++;
    isPlaylistLoading = false;
    notifyListeners();
  }

  loadMorePlaylist() {
    if (hasMorePlaylist) {
      loadPlaylist();
    }
  }

  reloadPlaylist() async {
    playlistPage = 1;
    playlists = [];
    hasMorePlaylist = true;
    await loadPlaylist();
  }

  switchCategory(String category) {
    this.category = category;
    notifyListeners();
  }
  updatePlaylist(SunoPlaylist playlist) {
    final index = playlists.indexWhere((element) => element.id == playlist.id);
    if (index != -1) {
      playlists[index] = playlist;
      notifyListeners();
    }
  }
}