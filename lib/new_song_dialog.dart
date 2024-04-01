import 'package:flutter/material.dart';
import 'package:untitled/api/client.dart';

import 'generated/l10n.dart';

class NewSongDialog extends StatefulWidget {
  Function(String? prompt, String? lyrics, bool isInstrumental, String? style,
      String? title) onGenerate;

  NewSongDialog({super.key, required this.onGenerate});

  @override
  State<NewSongDialog> createState() => _NewSongDialogState();
}

class _NewSongDialogState extends State<NewSongDialog> {
  SunoClient client = SunoClient();
  bool isInstrumental = false;
  String? prompt = '';
  String? style;
  String? title;
  String? lyrics;
  bool isCustom = false;
  TextEditingController lyricsController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  bool isGenerationLyrics = false;

  generateRandom() async {
    if (isGenerationLyrics) {
      return;
    }
    setState(() {
      isGenerationLyrics = true;
    });
    try {
      final result = await client.generateRandomLyrics();
      if (result == null) {
        return;
      }
      setState(() {
        lyrics = result.text;
        title = result.title;
      });
      lyricsController.text = result.text ?? lyricsController.text;
      titleController.text = result.title ?? titleController.text;
    }catch(e){
      print(e);
    }finally{
      setState(() {
        isGenerationLyrics = false;
      });
    }


  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.of(context).NewSongDialogTitle),
      content: SingleChildScrollView(
        child: Wrap(
          children: <Widget>[
            Container(
                child: SwitchListTile(
              title: Text(S.of(context).NewSongDialogCustomMode),
              value: isCustom,
              onChanged: (bool value) {
                setState(() {
                  isCustom = value;
                });
              },
            )),
            isCustom
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        child: TextField(
                          decoration:
                              InputDecoration(labelText: S.of(context).NewSongDialogLyricsHint),
                          minLines: 3,
                          maxLines: 100,
                          controller: lyricsController,
                          onChanged: (value) {
                            lyrics = value;
                          },
                        ),
                      ),
                      Container(
                          width: double.infinity,
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          margin: const EdgeInsets.only(top: 16),
                          child: TextButton(
                            onPressed:  isGenerationLyrics ? null : generateRandom,
                            child: Text(S.of(context).NewSongDialogGenerateRandom),
                          )),
                      Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        margin: const EdgeInsets.only(top: 16),
                        child: TextField(
                          decoration:
                              InputDecoration(labelText:
                              S.of(context).NewSongDialogStyleOfMusic),
                          onChanged: (value) {
                            style = value;
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        margin: const EdgeInsets.only(top: 16),
                        child: TextField(
                          controller: titleController,
                          decoration: InputDecoration(labelText: S.of(context).NewSongDialogMusicTitle),
                          onChanged: (value) {
                            title = value;
                          },
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: TextField(
                      decoration: InputDecoration(labelText: S.of(context).NewSongDialogPromptHint),
                      minLines: 3,
                      maxLines: 100,
                      onChanged: (value) {
                        prompt = value;
                      },
                    ),
                  ),
            Container(
                margin: const EdgeInsets.only(top: 16),
                child: SwitchListTile(
                  title: Text(S.of(context).NewSongDialogMakeInstrumental),
                  value: isInstrumental,
                  onChanged: (bool value) {
                    setState(() {
                      isInstrumental = value;
                    });
                  },
                ))
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(S.of(context).Close),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onGenerate(prompt, lyrics, isInstrumental, style, title);
          },
          child: Text(S.of(context).Generate),
        )
      ],
    );
  }
}
