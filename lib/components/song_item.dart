import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled/api/client.dart';
import 'package:untitled/api/entity.dart';

import '../screens/detail/song_detail.dart';

class SongItem extends StatefulWidget {
  SongMeta meta;
  Function(SongMeta meta)? onPlaySong;
  Function(String id)? onDeleteSong;
  Function(String audioUrl, String audioTitle)? downloadAudioFile;
  Function(SongMeta meta)? onAddToQueue;

  SongItem({super.key,
    required this.meta,
    this.onPlaySong,
    this.onDeleteSong,
    this.downloadAudioFile,
    this.onAddToQueue});

  @override
  State<SongItem> createState() => _SongItemState();
}

class _SongItemState extends State<SongItem> {
  @override
  Widget build(BuildContext context) {
    void _showActionSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.download_rounded),
                  title: Text('Download'),
                  onTap: () {
                    final audioUrl = widget.meta.audioUrl;
                    final audioTitle = widget.meta.title;
                    if (audioUrl != null && audioTitle != null) {
                      widget.downloadAudioFile!(audioUrl, audioTitle);
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete_rounded),
                  title: Text('Delete'),
                  onTap: () {
                    if (widget.onDeleteSong != null) {
                      widget.onDeleteSong!(widget.meta.id!);
                    }
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.playlist_add),
                  title: Text('Add to queue'),
                  onTap: () {
                    if (widget.onAddToQueue != null) {
                      widget.onAddToQueue!(widget.meta);
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      );
    }
    return Container(
      child: Row(
        children: [
          Builder(builder: (context) {
            final image = widget.meta.imageUrl;
            goToDetail() {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SongDetail(meta: widget.meta)),
              );
            }

            if (image == null || image.isEmpty) {
              return GestureDetector(
                onTap: goToDetail,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: Theme
                        .of(context)
                        .colorScheme
                        .secondaryFixedDim,
                  ),
                ),
              );
            }
            return GestureDetector(
              onTap: () {
                goToDetail();
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  imageUrl: image,
                  width: 72,
                  height: 72,
                ),
              ),
            );
          }),
          Expanded(
            child: GestureDetector(
              onLongPress: () {
                _showActionSheet(context);
              },
              child: Container(
                height: 72,
                width: double.infinity,
                color: Theme
                    .of(context)
                    .colorScheme
                    .surface,
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.meta.title ?? "",maxLines: 1,),
                    Text(
                      widget.meta.metadata?.tags ?? "",
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onSurface
                              .withAlpha(150),
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
