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
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
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
            child: Container(
              height: 72,
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.meta.title ?? ""),
                  Text(
                    widget.meta.metadata?.tags ?? "",
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme
                            .of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(150)),
                  ),
                ],
              ),
            ),
          ),
          Builder(builder: (context) {
            if (widget.meta.audioUrl == null) {
              return Container();
            }
            if (widget.onPlaySong == null) {
              return Container();
            }
            return IconButton(
                onPressed: () {
                  widget.onPlaySong!(widget.meta);
                },
                icon: const Icon(Icons.play_arrow_rounded));
          }),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) {
              List<PopupMenuItem<int>> items = [];
              if (widget.meta.audioUrl != null &&
                  widget.downloadAudioFile != null) {
                items.add(
                  const PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.download_rounded),
                        SizedBox(width: 8),
                        Text('Download'),
                      ],
                    ),
                  ),
                );
              }
              if (widget.onDeleteSong != null) {
                items.add(const PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    )));
              }
              if (widget.onAddToQueue != null) {
                items.add(const PopupMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add),
                        SizedBox(width: 8),
                        Text('Add to queue'),
                      ],
                    )));
              }
              return items;
            },
            onSelected: (value) {
              if (value == 1) {
                final audioUrl = widget.meta.audioUrl;
                final audioTitle = widget.meta.title;
                if (audioUrl == null || audioTitle == null) {
                  return;
                }
                widget.downloadAudioFile!(audioUrl, audioTitle);
              }
              if (value == 2) {
                if (widget.onDeleteSong != null) {
                  widget.onDeleteSong!(widget.meta.id!);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
