import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/components/playlist_item.dart';
import 'package:untitled/player_provider.dart';
import 'package:untitled/screens/library/provider.dart';
import 'package:untitled/utils.dart';

import '../../api/entity.dart';
import '../../components/song_item.dart';
import '../../play_bar.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<LibraryProvider, PlayerProvider>(
        builder: (context, libraryProvider, playerProvider, child) {
      libraryProvider.init();
      var loadMoreController = createLoadMoreController(() {
        libraryProvider.loadMoreFeed();
      });
      var playlistLoadMoreController = createLoadMoreController(() {
        libraryProvider.loadMorePlaylist();
      });
      return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0),
          scrolledUnderElevation: 0,
          title: Text("Library"),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(top: 16, bottom: 16),
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text("Songs"),
                              selected: libraryProvider.category == "Songs",
                              onSelected: (selected) {
                                libraryProvider.switchCategory("Songs");
                              },
                              showCheckmark: false,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              child: ChoiceChip(
                                label: Text("Playlists"),
                                selected:
                                    libraryProvider.category == "Playlists",
                                onSelected: (selected) {
                                  libraryProvider.switchCategory("Playlists");
                                },
                                showCheckmark: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          if (libraryProvider.category == "Songs") {
                            final playlist = libraryProvider.feed;
                            return RefreshIndicator(
                              onRefresh: () async {
                                await libraryProvider.reloadFeed();
                              },
                              child: ListView.builder(
                                controller: loadMoreController,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: playlist.length,
                                itemBuilder: (context, index) {
                                  final song = playlist[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: SongItem(
                                      meta: song,
                                      onPlaySong: (SongMeta meta) {
                                        playerProvider.playSongs([meta]);
                                      },
                                      onAddToQueue: (SongMeta meta) {
                                        playerProvider.addToQueue(meta);
                                      },
                                    ),
                                  );
                                },
                              ),
                            );
                          }
                          if (libraryProvider.category == "Playlists") {
                            return RefreshIndicator(
                              onRefresh: () async {
                                await libraryProvider.reloadPlaylist();
                              },
                              child: ListView.builder(
                                controller: playlistLoadMoreController,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemCount: libraryProvider.playlists.length,
                                itemBuilder: (context, index) {
                                  final playlist =
                                      libraryProvider.playlists[index];
                                  return PlaylistItem(
                                    sunoPlaylist: playlist,
                                    onPlay: (SunoPlaylist playlist) {
                                      playerProvider.playSongs(
                                          playlist.getSongMetaList());
                                    },
                                    onAddToQueue: (SunoPlaylist playlist) {
                                      playerProvider.addListToQueue(
                                          playlist.getSongMetaList());
                                    },
                                    onRename: (SunoPlaylist playlist) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Rename playlist"),
                                              content: TextField(
                                                controller:
                                                    TextEditingController(
                                                        text: playlist.name),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Cancel"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Save"),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                    onUpdated: (updatedPlaylist) {
                                      libraryProvider.updatePlaylist(
                                          updatedPlaylist);
                                    },
                                  );
                                },
                              ),
                            );
                          }
                          return Container();
                        }),
                      )
                    ],
                  ),
                ),
              ),
              PlayBar()
            ],
          ),
        ),
      );
    });
  }
}
