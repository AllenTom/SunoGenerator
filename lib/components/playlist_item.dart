import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled/api/entity.dart';
import 'package:untitled/screens/playlist/detail.dart';

import '../screens/detail/song_detail.dart';

class PlaylistItem extends StatefulWidget {
  SunoPlaylist sunoPlaylist;
  Function(SunoPlaylist playlist)? onPlay;
  Function(SunoPlaylist playlist)? onAddToQueue;
  Function(SunoPlaylist playlist)? onRename;
  Function(SunoPlaylist playlist)? onUpdated;

  PlaylistItem(
      {super.key,
      required this.sunoPlaylist,
      this.onPlay,
      this.onRename,
      this.onUpdated,
      this.onAddToQueue});

  @override
  State<PlaylistItem> createState() => _PlaylistItemState();
}

class _PlaylistItemState extends State<PlaylistItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Builder(builder: (context) {
            final image = widget.sunoPlaylist.imageUrl;
            goToDetail() {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PlaylistDetail(
                          playlist: widget.sunoPlaylist,
                          onUpdateMeta: (updatedData) {
                            if (widget.onUpdated != null) {
                              widget.onUpdated!(updatedData);
                            }
                          },
                        )),
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
                    color: Theme.of(context).colorScheme.secondaryFixedDim,
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
                  Text(widget.sunoPlaylist.name ?? ""),
                ],
              ),
            ),
          ),
          Builder(builder: (context) {
            if (widget.onPlay == null) {
              return Container();
            }
            return IconButton(
                onPressed: () {
                  widget.onPlay!(widget.sunoPlaylist);
                },
                icon: const Icon(Icons.play_arrow_rounded));
          }),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert_rounded),
            itemBuilder: (context) {
              List<PopupMenuItem<int>> items = [];
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
              if (widget.onRename != null) {
                items.add(const PopupMenuItem(
                    value: 4,
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('Rename'),
                      ],
                    )));
              }
              return items;
            },
            onSelected: (value) {
              if (value == 3) {
                if (widget.onAddToQueue != null) {
                  widget.onAddToQueue!(widget.sunoPlaylist);
                }
              }
              if (value == 4) {
                if (widget.onRename != null) {
                  widget.onRename!(widget.sunoPlaylist);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
