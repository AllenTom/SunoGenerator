import 'dart:async';
import 'dart:io' show Platform;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:untitled/login.dart';
import 'package:untitled/new_song_dialog.dart';
import 'package:untitled/player_provider.dart';
import 'package:untitled/screens/home/provider.dart';
import 'package:untitled/store.dart';

import '../../api/client.dart';
import '../../api/entity.dart';
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
    Future<void> refresh(BuildContext context) async {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.loadSongs();
    }







    downloadAudioFile(String fileUrl, String title) async {
      SunoClient client = SunoClient();
      Uint8List raw = await client.downloadFileWithUrl(fileUrl);
      print(raw);
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: '$title.mp3',
        type: FileType.audio,
        bytes: raw,
      );

      if (outputFile == null) {
        // User canceled the picker
      }
    }

    return ChangeNotifierProvider(
        create: (_) => HomeProvider(),
        child: Consumer3<UserProvider, HomeProvider,PlayerProvider>(
            builder: (context, userProvider, homeProvider,playerProvider, _) {
          initData() async {
            SunoClient client = SunoClient();
            if (homeProvider.isFirst) {
              final providerUser = Provider.of<UserProvider>(context);
              if (providerUser.loginInfo == null && client.cookie.isNotEmpty) {
                await providerUser.loginUser(client.cookie);
              }
              homeProvider.init();
            }
          }

          initData();

          void generateSong(String prompt, bool isInstrumental) async {
            homeProvider.generateSong(prompt, isInstrumental);
          }

          void openNewSongDialog() {
            showDialog(
                context: context,
                builder: (context) {
                  return NewSongDialog(
                    onGenerate: (prompt, isInstrumental) {
                      generateSong(prompt, isInstrumental);
                    },
                  );
                });
          }

          Future<void> onLogin(String cookieString) async {
            SunoClient client = SunoClient();
            client.applyCookie(cookieString);
            initData();
            await refresh(context);
          }
          Future<void> onLoginOut(BuildContext context) async {
            await playerProvider.disposePlayer();
            userProvider.loginOut();
            homeProvider.toInit();
          }
          void _showUserInfoDialog() {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('User Info'),
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
                              child: CircleAvatar(
                                backgroundImage:
                                NetworkImage(userProvider.loginInfo!.avatar!),
                              ),
                            ),
                            Text(
                                "${userProvider.loginInfo!.firstName} ${userProvider.loginInfo!.lastName}")
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
                            child: Text("Login out")),
                      ),
                      Divider(),
                      AppDataStore().config.users.where((element) {
                        return element.id != userProvider.loginInfo!.id;
                      }).isNotEmpty?
                      Column(
                        children: [
                          Container(
                              margin: const EdgeInsets.only(bottom: 16, top: 16),
                              child: Text("switch to")),
                          ...AppDataStore().config.users.where((element) {
                            return element.id != userProvider.loginInfo!.id;
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
                                    Container(
                                      margin: const EdgeInsets.only(right: 16),
                                      width: 48,
                                      height: 48,
                                      child: CircleAvatar(
                                        backgroundImage: NetworkImage(user.avatar!),
                                      ),
                                    ),
                                    Expanded(
                                        child:
                                        Text("${user.firstName} ${user.lastName}")),
                                  ],
                                ),
                              ),
                            );
                          })
                        ],
                      ):Container()

                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                );
              },
            );
          }
          void playSong(SongMeta song) async {
            await playerProvider.setUrlAndPlay(song.audioUrl!);
            homeProvider.updateCurrentSong(Song(
                title: song.title!,
                imageUrl: song.imageUrl!,
                id: song.id!,
                duration: playerProvider.duration!));
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              title: const Text('Suno'),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                                child: Text("Login"))
                            : Container(),
                        Container(
                          child: TextButton(
                              onPressed: () {
                                showCookieInputDialog(context,
                                    title: "Input your cookie",
                                    onOk: (cookieString) async {
                                  await onLogin(cookieString);
                                });
                              },
                              child: Text("Input cookie")),
                        )
                      ])
                    : Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () {
                              refresh(context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
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
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        userProvider.loginInfo!.avatar!),
                                  ),
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
                    child: ListView(
                  children: [
                    ...homeProvider.generatingSong.map((e) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            (e.imageUrl == null || e.imageUrl!.isEmpty)
                                ? Container(
                                    width: 72,
                                    height: 72,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondaryFixedDim,
                                  )
                                : Image.network(e.imageUrl!,
                                    width: 72, height: 72,
                                    errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 72,
                                      height: 72,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondaryFixedDim,
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
                                    LinearProgressIndicator()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    ...homeProvider.songs.map((e) {
                      return Container(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Image.network(
                              e.imageUrl!,
                              width: 72,
                              height: 72,
                            ),
                            Expanded(
                              child: Container(
                                height: 72,
                                padding: const EdgeInsets.only(left: 16),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title!),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(right: 8),
                              child: IconButton(
                                  onPressed: () {
                                    downloadAudioFile(e.audioUrl!, e.title!);
                                  },
                                  icon: Icon(Icons.download)),
                            ),
                            IconButton(
                                onPressed: () {
                                  playSong(e);
                                },
                                icon: Icon(Icons.play_arrow))
                          ],
                        ),
                      );
                    })
                  ],
                )),
                Container(
                    height: 64,
                    padding: const EdgeInsets.only(
                        left: 16, right: 16, top: 8, bottom: 8),
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    child: homeProvider.currentSong == null
                        ? Container()
                        : Row(
                            children: [
                              Image.network(
                                homeProvider.currentSong!.imageUrl,
                                width: 48,
                                height: 48,
                              ),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 16),
                                  child: Column(
                                    children: [
                                      Text(
                                        homeProvider.currentSong!.title,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                              "${playerProvider.currentPosition!.inMinutes}:${(playerProvider.currentPosition!.inSeconds % 60).toString().padLeft(2, '0')}"),
                                          SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              trackHeight: 6,
                                              // Adjust this value to make the slider track thinner
                                              thumbShape:
                                              const RoundSliderThumbShape(
                                                  enabledThumbRadius:
                                                  6),
                                              trackShape:
                                              RoundedRectSliderTrackShape(),
                                            ),
                                            child: Flexible(
                                              flex: 1,
                                              child: Container(
                                                height: 24,
                                                child: Slider(
                                                  value: playerProvider.currentPosition!.inSeconds
                                                      .toDouble(),
                                                  onChanged: (value) {
                                                    playerProvider.player.seek(Duration(
                                                        seconds: value
                                                            .toInt()));
                                                  },
                                                  min: 0,
                                                  max: homeProvider.currentSong!
                                                      .duration.inSeconds
                                                      .toDouble(),
                                                  inactiveColor: Theme.of(
                                                      context)
                                                      .colorScheme
                                                      .secondaryFixedDim,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 64,
                                            child: Text(
                                              "${homeProvider.currentSong!.duration.inMinutes}:${(homeProvider.currentSong!.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
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
                                    return IconButton(
                                        onPressed: () {
                                          if (snapshot.data!.playing) {
                                            playerProvider.player.pause();
                                          } else {
                                            playerProvider.player.play();
                                          }
                                        },
                                        icon: Icon(snapshot.data!.playing
                                            ? Icons.pause
                                            : Icons.play_arrow));
                                  }),
                            ],
                          )),
                Container(
                  height: 16,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                )
              ],
            ),
          );
        }));
  }
}
