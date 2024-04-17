import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/components/song_item.dart';
import 'package:untitled/play_bar.dart';
import 'package:untitled/player_provider.dart';
import 'package:untitled/screens/explore/provider.dart';

import '../../api/entity.dart';
import '../../generated/l10n.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ExploreProvider, PlayerProvider>(
        builder: (context, exploreProvider, playerProvider, child) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0),
          scrolledUnderElevation: 0,
          centerTitle: false,
          title: Text(S.of(context).TabExplore),
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
                              label: Text(S.of(context).Trending),
                              selected: exploreProvider.category == "Trending",
                              onSelected: (selected) {
                                exploreProvider.switchCategory("Trending");
                              },
                              showCheckmark: false,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              child: ChoiceChip(
                                label: Text(S.of(context).New),
                                selected: exploreProvider.category == "New",
                                onSelected: (selected) {
                                  exploreProvider.switchCategory("New");
                                },
                                showCheckmark: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Builder(builder: (context) {
                          if (exploreProvider.category == "Trending") {
                            exploreProvider.loadTrending();
                          }
                          if (exploreProvider.category == "New") {
                            exploreProvider.loadNew();
                          }
                          SunoPlaylist? playlist;
                          if (exploreProvider.category == "Trending") {
                            playlist = exploreProvider.trending;
                          }
                          if (exploreProvider.category == "New") {
                            playlist = exploreProvider.newPlaylist;
                          }
                          if (playlist == null) {
                            return Container();
                          }
                          return RefreshIndicator(
                            onRefresh: () async {
                              if (exploreProvider.category == "Trending") {
                                await exploreProvider.loadTrending(force: true);
                              }
                              if (exploreProvider.category == "New") {
                                await exploreProvider.loadNew(force: true);
                              }
                            },
                            child: ListView.builder(
                              physics: AlwaysScrollableScrollPhysics(),
                              itemCount: playlist.playlistClips!.length,
                              itemBuilder: (context, index) {
                                final song = playlist!.playlistClips![index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: SongItem(
                                    meta: song.clip!,
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
