import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:untitled/player_provider.dart';

import 'api/entity.dart';
import 'screens/player/player.dart';

class PlayBar extends StatefulWidget {
  const PlayBar({super.key});

  @override
  State<PlayBar> createState() => _PlayBarState();
}

class _PlayBarState extends State<PlayBar> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(builder: (context, playerProvider, child) {
      showBottomModelOfPlaylist() {
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        "Playlist",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: Builder(
                            builder: (context) {
                              final SequenceState? seqState = playerProvider.sequenceState;
                              if (seqState == null) {
                                return Container();
                              }
                              final List<IndexedAudioSource> audios =
                                  seqState.sequence;

                              return ListView.builder(
                                itemCount: audios.length,
                                itemBuilder: (context, index) {
                                  IndexedAudioSource song = audios[index];
                                  final meta = song.tag as SongMeta?;
                                  final currentIndex = seqState.currentIndex;
                                  return ListTile(
                                    onTap: () {
                                      playerProvider.player.seek(Duration.zero,
                                          index: index);
                                      Navigator.pop(context);
                                    },
                                      contentPadding: const EdgeInsets.only(
                                          bottom: 8, top: 8),
                                      leading: Builder(builder: (context) {

                                        final imageUrl = meta?.imageUrl;
                                        if (imageUrl == null ||
                                            imageUrl.isEmpty) {
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Container(
                                              width: 48,
                                              height: 48,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondaryFixedDim,
                                            ),
                                          );
                                        }
                                        return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            child: Image.network(
                                              imageUrl,
                                              width: 48,
                                              height: 48,
                                            ));
                                      }),
                                      title: Text(
                                        meta?.title ?? "",
                                      ),
                                    selected: currentIndex == index,
                                  );
                                },
                              );
                            }),
                      ),
                    )
                  ],
                ),
              );
            });
      }

      return Container(
          height: 64,
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: playerProvider.currentSong == null
              ? Container()
              : Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // go to player
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PlayerScreen()),
                        );
                      },
                      child: Builder(builder: (context) {
                        final imageUrl = playerProvider.currentSong?.imageUrl;
                        if (imageUrl == null || imageUrl.isEmpty) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryFixedDim,
                            ),
                          );
                        }
                        return ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              imageUrl,
                              width: 48,
                              height: 48,
                            ));
                      }),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              playerProvider.currentSong?.title ?? "",
                            ),
                          ],
                        ),
                      ),
                    ),
                    StreamBuilder<PlayerState>(
                        stream: playerProvider.player.playerStateStream,
                        builder: (
                          context,
                          snapshot,
                        ) {
                          final playerState = snapshot.data;
                          if (playerState == null) {
                            return Container();
                          }
                          return IconButton(
                              onPressed: () {
                                if (playerState.playing) {
                                  playerProvider.player.pause();
                                } else {
                                  playerProvider.player.play();
                                }
                              },
                              icon: Icon(playerState.playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded));
                        }),
                    IconButton(onPressed: (){
                      playerProvider.player.seekToNext();
                    }, icon: const Icon(Icons.skip_next_rounded)),
                    IconButton(
                        onPressed: () {
                          showBottomModelOfPlaylist();
                        },
                        icon: const Icon(Icons.queue_music_rounded)),
                  ],
                ));
    });
  }
}
