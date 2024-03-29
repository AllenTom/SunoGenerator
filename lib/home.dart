import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:untitled/login.dart';
import 'package:untitled/new_song_dialog.dart';
import 'package:untitled/store.dart';

import 'api/client.dart';
import 'api/entity.dart';
import 'input_token_dialog.dart';
import 'dart:io' show Platform;

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
  SunoClient client = SunoClient();
  List<SongMeta> songs = [];
  List<GenerateItem> generatingSong = [];
  Song? currentSong;
  LoginInfo? loginInfo;
  bool isLogining = false;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (loginInfo == null && client.cookie.isNotEmpty) {
      onLogin(client.cookie);
    }
  }

  Future<void> refresh() async {
    var info = await client.getSession();
    var fetchSongs = await client.getSongMetadata();
    setState(() {
      songs = fetchSongs;
      loginInfo = info;
    });
    if (info != null) {
      await AppDataStore().addUserData(User(
          id: info.id,
          firstName: info.firstName,
          lastName: info.lastName,
          avatar: info.avatar,
          token: client.cookie,
          sid: client.sid));
    }
  }

  void playSong(SongMeta song) async {
    var duration = await player.setUrl(song.audioUrl!);
    setState(() {
      currentSong = Song(
          title: song.title!,
          imageUrl: song.imageUrl!,
          id: song.id!,
          duration: duration!);
    });
    player.play();
  }

  void generateSong(String prompt, bool isInstrumental) async {
    var updateStateController = StreamController<List<GenerateItem>>();
    updateStateController.stream.listen((event) {
      setState(() {
        generatingSong = event;
      });
    });
    await client.generateSong(
        prompt: prompt,
        updateStateController: updateStateController,
        instrumental: isInstrumental);
    setState(() {
      generatingSong = [];
    });
    await refresh();
  }

  void openNewSongDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return NewSongDialog(
            onGenerate: generateSong,
          );
        });
  }

  Future<void> onLogin(String cookieString) async {
    setState(() {
      isLogining = true;
    });
    client.applyCookie(cookieString);
    await refresh();
    if (isLogining) {
      Navigator.of(context).pop();
    }
    setState(() {
      isLogining = false;
    });
  }

  Future<void> onLoginOut() async {
    player.dispose();
    setState(() {
      loginInfo = null;
      songs = [];
      generatingSong = [];
      currentSong = null;
    });
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
                        backgroundImage: NetworkImage(loginInfo!.avatar!),
                      ),
                    ),
                    Text("${loginInfo!.firstName} ${loginInfo!.lastName}")
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onLoginOut();
                    },
                    child: Text("Login out")),
              ),
              Divider(),
              Container(
                  margin: const EdgeInsets.only(bottom: 16, top: 16),
                  child: Text("switch to")),
              ...AppDataStore().config.users.where((element) {
                return element.id != loginInfo!.id;
              }).map((user) {
                return GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    await onLogin(user.token!);
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
                            child: Text("${user.firstName} ${user.lastName}")),
                      ],
                    ),
                  ),
                );
              })
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

  downloadAudioFile(String fileUrl, String title) async {
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

  @override
  Widget build(BuildContext context) {
    if (isLogining) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login'),
              content: Text('Logging in...'),
            );
          },
        );
      });
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Suno'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          loginInfo == null
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
                        refresh();
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
                    loginInfo!.avatar?.isEmpty ?? true
                        ? Container(
                            width: 32,
                            height: 32,
                            color:
                                Theme.of(context).colorScheme.secondaryFixedDim,
                          )
                        : GestureDetector(
                            onTap: _showUserInfoDialog,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(loginInfo!.avatar!),
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
              ...generatingSong.map((e) {
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
                          : Image.network(e.imageUrl!, width: 72, height: 72,
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
              ...songs.map((e) {
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
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: currentSong == null
                  ? Container()
                  : Row(
                      children: [
                        Image.network(
                          currentSong!.imageUrl,
                          width: 48,
                          height: 48,
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 16),
                            child: Column(
                              children: [
                                Text(
                                  currentSong!.title,
                                ),
                                StreamBuilder(
                                    stream: player.positionStream,
                                    builder: (context, snapshot) {
                                      if (snapshot.data == null) {
                                        return Container(
                                          width: 64,
                                          child: const Text(
                                            "0:00",
                                            textAlign: TextAlign.right,
                                          ),
                                        );
                                      }
                                      return Row(
                                        children: [
                                          Text(
                                              "${snapshot.data!.inMinutes}:${(snapshot.data!.inSeconds % 60).toString().padLeft(2, '0')}"),
                                          SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              trackHeight: 6,
                                              // Adjust this value to make the slider track thinner
                                              thumbShape:
                                                  const RoundSliderThumbShape(
                                                      enabledThumbRadius:
                                                          6),
                                              trackShape: RoundedRectSliderTrackShape(),
                                            ),
                                            child: Flexible(
                                              flex: 1,
                                              child: Container(
                                                height: 24,
                                                child: Slider(
                                                  value: snapshot
                                                      .data!.inSeconds
                                                      .toDouble(),
                                                  onChanged: (value) {
                                                    player.seek(Duration(
                                                        seconds:
                                                            value.toInt()));
                                                  },
                                                  min: 0,
                                                  max: currentSong!
                                                      .duration.inSeconds
                                                      .toDouble(),
                                                  inactiveColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .secondaryFixedDim,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 64,
                                            child: Text(
                                              "${currentSong!.duration.inMinutes}:${(currentSong!.duration.inSeconds % 60).toString().padLeft(2, '0')}",
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ],
                                      );
                                    })
                              ],
                            ),
                          ),
                        ),
                        StreamBuilder<PlayerState>(
                            stream: player.playerStateStream,
                            builder: (
                              context,
                              snapshot,
                            ) {
                              return IconButton(
                                  onPressed: () {
                                    if (snapshot.data!.playing) {
                                      player.pause();
                                    } else {
                                      player.play();
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
  }
}
