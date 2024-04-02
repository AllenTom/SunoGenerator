import 'dart:async';
import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/components/song_item.dart';
import 'package:untitled/login.dart';
import 'package:untitled/components/new_song_dialog.dart';
import 'package:untitled/play_bar.dart';
import 'package:untitled/player_provider.dart';
import 'package:untitled/screens/home/provider.dart';
import 'package:untitled/store.dart';

import '../../api/client.dart';
import '../../api/entity.dart';
import '../../generated/l10n.dart';
import '../../input_token_dialog.dart';
import '../../user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Song {
  String title;
  String imageUrl;
  String id;
  Duration duration;

  Song(
      {required this.title,
      required this.imageUrl,
      required this.id,
      required this.duration});
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    downloadAudioFile(String fileUrl, String title) async {
      SunoClient client = SunoClient();
      Uint8List raw = await client.downloadFileWithUrl(fileUrl);
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: S.of(context).InputCookieDialog_Title,
        fileName: '$title.mp3',
        type: FileType.audio,
        bytes: raw,
      );

      if (outputFile == null) {
        // User canceled the picker
      }
    }

    return Consumer3<UserProvider, HomeProvider, PlayerProvider>(
        builder: (context, userProvider, homeProvider, playerProvider, _) {
      initData({bool force = false}) async {
        SunoClient client = SunoClient();
        if (homeProvider.isFirst || force) {
          final providerUser = Provider.of<UserProvider>(context);
          // if (providerUser.loginInfo == null && client.cookie.isNotEmpty) {
          //   await providerUser.loginUser(client.cookie);
          // }
          homeProvider.init();
        }
      }

      initData();

      void generateSong(String? prompt, String? lyrics, bool isInstrumental,
          String? style, String? title) async {
        homeProvider.generateSong(prompt, lyrics, isInstrumental, style, title);
      }

      Future<void> refresh({bool force = false}) async {
        await homeProvider.loadSongs(force: force);
      }

      void openNewSongDialog() {
        showDialog(
            context: context,
            builder: (context) {
              return NewSongDialog(
                onGenerate: (prompt, lyrics, isInstrumental, style, title) {
                  generateSong(prompt, lyrics, isInstrumental, style, title);
                },
              );
            });
      }

      Future<void> onLogin(String cookieString) async {
        SunoClient client = SunoClient();
        client.applyCookie(cookieString);
        initData(force: true);
        await refresh();
      }

      Future<void> onLoginOut(BuildContext context) async {
        await playerProvider.disposePlayer();
        userProvider.loginOut();
        homeProvider.toInit();
      }

      Future onDeleteSong(String id) async {
        await homeProvider.deleteSong(id);
      }

      void _showUserInfoDialog() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(S.of(context).UserInfo),
              content: Wrap(
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          width: 64,
                          height: 64,
                          child: Builder(builder: (context) {
                            final avatar = userProvider.loginInfo?.avatar;
                            if (avatar == null || avatar.isEmpty) {
                              return Container(
                                width: 64,
                                height: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryFixedDim,
                              );
                            }
                            return CircleAvatar(
                              backgroundImage: NetworkImage(avatar),
                            );
                          }),
                        ),
                        Text(
                            "${userProvider.loginInfo?.firstName} ${userProvider.loginInfo?.lastName}")
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          userProvider.loginOut();
                          onLoginOut(context);
                        },
                        child: Text(S.of(context).LoginOut)),
                  ),
                  const Divider(),
                  AppDataStore().config.users.where((element) {
                    return element.id != userProvider.loginInfo?.id;
                  }).isNotEmpty
                      ? Column(
                          children: [
                            Container(
                                margin:
                                    const EdgeInsets.only(bottom: 16, top: 16),
                                child: Text(S.of(context).SwitchToAccount)),
                            ...AppDataStore().config.users.where((element) {
                              return element.id != userProvider.loginInfo?.id;
                            }).map((user) {
                              return GestureDetector(
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await onLogin(user.token);
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Builder(builder: (context) {
                                        final avatar = user.avatar;
                                        if (avatar == null) {
                                          return Container(
                                            width: 48,
                                            height: 48,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondaryFixedDim,
                                          );
                                        }
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(right: 16),
                                          width: 48,
                                          height: 48,
                                          child: CircleAvatar(
                                            backgroundImage:
                                                NetworkImage(avatar),
                                          ),
                                        );
                                      }),
                                      Expanded(
                                          child: Text(
                                              "${user.firstName} ${user.lastName}")),
                                    ],
                                  ),
                                ),
                              );
                            })
                          ],
                        )
                      : Container()
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).Close),
                ),
              ],
            );
          },
        );
      }

      void playSong(SongMeta song) async {
        await playerProvider.playSongs([song]);
        // await playerProvider.setUrlAndPlay(song);
      }

      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          centerTitle: false,
          title: const Text('Suno'),
          actions: [
            userProvider.loginInfo == null
                ? Row(children: [
                    (Platform.isAndroid || Platform.isIOS)
                        ? TextButton(
                            onPressed: () async {
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                              await onLogin(result);
                            },
                            child: Text(S.of(context).Login))
                        : Container(),
                    Container(
                      child: TextButton(
                          onPressed: () {
                            showCookieInputDialog(context,
                                title: S.of(context).InputCookieDialog_Title,
                                onOk: (cookieString) async {
                              await onLogin(cookieString);
                            });
                          },
                          child: Text(S.of(context).InputCookie)),
                    )
                  ])
                : Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.playlist_play_rounded),
                        onPressed: () async {
                          await playerProvider.playSongs(homeProvider.songs);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: () {
                          openNewSongDialog();
                        },
                      ),
                      Container(
                        width: 16,
                      ),
                      userProvider.loginInfo?.avatar?.isEmpty ?? true
                          ? Container(
                              width: 32,
                              height: 32,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondaryFixedDim,
                            )
                          : GestureDetector(
                              onTap: _showUserInfoDialog,
                              child: Builder(builder: (context) {
                                if (userProvider.loginInfo == null) {
                                  return Container();
                                }
                                final avatar = userProvider.loginInfo?.avatar;
                                if (avatar == null || avatar.isEmpty) {
                                  return Container(
                                    width: 32,
                                    height: 32,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryFixedDim,
                                  );
                                }
                                return Container(
                                  width: 32,
                                  height: 32,
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(avatar),
                                  ),
                                );
                              }),
                            ),
                    ],
                  ),
            Container(
              width: 16,
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
                child: RefreshIndicator(
              onRefresh: () async {
                await refresh(force: true);
              },
              child: ListView(
                children: [
                  ...homeProvider.generatingSong.map((e) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          Builder(builder: (context) {
                            final image = e.imageUrl;
                            if (image == null || image.isEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryFixedDim,
                                ),
                              );
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                image,
                                width: 72,
                                height: 72,
                              ),
                            );
                          }),
                          Expanded(
                            child: Container(
                              height: 72,
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.title!),
                                  const LinearProgressIndicator()
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  ...homeProvider.songs.map((e) {
                    return SongItem(
                      meta: e,
                      onPlaySong: playSong,
                      onDeleteSong: onDeleteSong,
                      downloadAudioFile: downloadAudioFile,
                    );
                  })
                ],
              ),
            )),
            PlayBar(),
            Platform.isAndroid
                ? Container(
                    height: 16,
                    color: Theme.of(context).colorScheme.secondaryContainer,
                  )
                : Container()
          ],
        ),
      );
    });
  }
}
