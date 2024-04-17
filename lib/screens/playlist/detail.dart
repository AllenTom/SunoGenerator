import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:untitled/api/client.dart';
import 'package:untitled/api/entity.dart';
import 'package:untitled/components/song_item.dart';
import 'package:untitled/play_bar.dart';
import 'package:untitled/player_provider.dart';

import '../../generated/l10n.dart';

class PlaylistDetail extends StatefulWidget {
  SunoPlaylist playlist;
  Function(SunoPlaylist playlist)? onUpdateMeta;

  PlaylistDetail({super.key,required this.playlist, this.onUpdateMeta});

  @override
  State<PlaylistDetail> createState() => _PlaylistDetailState();
}

class _PlaylistDetailState extends State<PlaylistDetail> {
  SunoClient client = SunoClient();
  SunoPlaylist? playlist;
  @override
  void initState() {
    super.initState();
    playlist = widget.playlist;
  }
  onUpdateMeta(String id,
      String name,
      String description) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).Updating),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(),
            ],
          ),
        );
      },
    );
    await client.editPlaylist(id: id, name: name, description: description);
    SunoPlaylist updatedPlaylist = await client.getPlaylist(id: id);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    setState(() {
      playlist = updatedPlaylist;
    });
    if (widget.onUpdateMeta != null) {
      widget.onUpdateMeta!(updatedPlaylist);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        final playlist = this.playlist;
        if (playlist == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text(S.of(context).Playlists),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Scaffold(
          extendBodyBehindAppBar: true,
          body:Container(
            child:Column(
              children: [
                Expanded(child:
                    Container(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 48),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Builder(builder: (context) {
                                    final image = playlist.imageUrl;
                                    if (image == null || image.isEmpty) {
                                      return ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Container(
                                          width: 96,
                                          height: 96,
                                          color: Theme.of(context).colorScheme.secondaryFixedDim,
                                        ),
                                      );
                                    }
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.network(
                                        image,
                                        width: 96,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(playlist.name ?? "", style: Theme.of(context).textTheme.headline6),
                                    Text("${playlist.getSongMetaList().length} songs", style: Theme.of(context).textTheme.subtitle1),
                                  ],
                                ),
                                Expanded(child: Container()),
                                IconButton(onPressed: (){
                                  playerProvider.playSongs(playlist.getSongMetaList());
                                }, icon: const Icon(Icons.play_arrow_rounded)),
                                // drop down menu
                                Builder(builder: (context) {
                                  return PopupMenuButton(
                                    icon: const Icon(Icons.more_vert_rounded),
                                    itemBuilder: (context) {
                                      List<PopupMenuItem> items = [PopupMenuItem(
                                        value: "Add to queue",
                                        child: Text(S.of(context).AddToQueue),
                                      )];
                                      if (playlist.isOwned == true) {
                                        items.add(PopupMenuItem(
                                          value: "Edit",
                                          child: Text(S.of(context).Edit),
                                        ));
                                      }
                                      return items;
                                    },
                                    onSelected: (value) {
                                      if (value == "Add to queue") {
                                        playerProvider.addListToQueue(playlist.getSongMetaList());
                                      }
                                      if (value == "Edit") {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            TextEditingController nameController = TextEditingController(text: playlist.name);
                                            TextEditingController descriptionController = TextEditingController(text: playlist.description);
                                            return AlertDialog(
                                              title: Text(S.of(context).EditPlaylist),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  TextField(
                                                    controller: nameController,
                                                    decoration: InputDecoration(
                                                      labelText:S.of(context).Name,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets.only(top: 16),
                                                    child: TextField(
                                                      minLines: 3,
                                                      maxLines: 100,
                                                      controller: descriptionController,
                                                      decoration: InputDecoration(
                                                        labelText: S.of(context).Description,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(S.of(context).Cancel),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    onUpdateMeta(playlist.id!, nameController.text, descriptionController.text);
                                                  },
                                                  child: Text(S.of(context).Save),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      }
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              child: ListView.builder(
                                itemCount: playlist.getSongMetaList().length,
                                itemBuilder: (context, index) {
                                  var song = playlist.getSongMetaList()[index];
                                  return Container(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: SongItem(
                                        meta: song,
                                      onPlaySong: (meta) {
                                        playerProvider.playSongs([meta]);
                                      },
                                      onAddToQueue: (meta) {
                                        playerProvider.addToQueue(meta);
                                      },
                                    ),
                                  );
                                }
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                ),
                const PlayBar()
              ],
            )
          )
        );
      }
    );
  }
}
