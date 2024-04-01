import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:untitled/api/entity.dart';
import 'package:untitled/play_bar.dart';

import '../../api/client.dart';
import '../../generated/l10n.dart';
import '../../player_provider.dart';

class SongDetail extends StatelessWidget {
  SongMeta meta;

  SongDetail({super.key, required this.meta});

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
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            scrolledUnderElevation: 0,
            actions: [
              IconButton(onPressed: (){
                final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
                playerProvider.addToQueue(meta);
              }, icon: Icon(Icons.playlist_add)),
              PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert_rounded),
                itemBuilder: (context) => [
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
                ],
                onSelected: (value) {
                  if (value == 1) {
                    final audioUrl = meta.audioUrl;
                    final audioTitle = meta.title;
                    if (meta.hasMp3Url() ||
                        audioUrl == null ||
                        audioTitle == null) {
                      return;
                    }
                    downloadAudioFile(audioUrl, audioTitle);
                  }
                },
              ),
            ],
            leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded),
                onPressed: () {
                  Navigator.of(context).pop();
                })),
        body: Container(
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(left: 32, right: 32),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          Container(
                            height: 64,
                          ),
                          Builder(builder: (context) {
                            final imageUrl = meta.imageUrl;
                            if (imageUrl == null || imageUrl.isEmpty) {
                              Container(
                                width: 300,
                                height: 300,
                                child: Icon(
                                  Icons.image,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                ),
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              );
                            }
                            return Container(
                              width: 300,
                              height: 300,
                              child: Image.network(
                                meta.imageUrl ?? "",
                                width: 300,
                                height: 300,
                              ),
                            );
                          }),
                          Text(
                            meta.title ?? "",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            meta.metadata?.tags ?? "",
                            style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withAlpha(150)),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 16,bottom: 16),
                            width: double.infinity,
                            child:FilledButton(

                                onPressed: () {
                                  final playerProvider =
                                      Provider.of<PlayerProvider>(context,
                                          listen: false);
                                  playerProvider.playSongs([meta]);
                                },
                                child: Row (
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded),
                                    Text("Play")
                                  ],
                                )),
                          ),
                          Text(
                            meta.metadata?.prompt ?? "",
                            style: TextStyle(fontSize: 14),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),
                PlayBar()
              ],
            )));
  }
}
