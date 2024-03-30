import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:untitled/api/client.dart';

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

  generateRandom() async {
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a new song'),
      content: SingleChildScrollView(
        child: Wrap(
          children: <Widget>[
            Container(
                child: SwitchListTile(
              title: const Text('Custom Mode'),
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
                              InputDecoration(labelText: 'Enter lyrics'),
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
                            onPressed: () {
                              generateRandom();
                            },
                            child: const Text('Generate random'),
                          )),
                      Container(
                        padding: const EdgeInsets.only(left: 16, right: 16),
                        margin: const EdgeInsets.only(top: 16),
                        child: TextField(
                          decoration:
                              InputDecoration(labelText: 'Style of Music'),
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
                          decoration: InputDecoration(labelText: 'Title'),
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
                      decoration: InputDecoration(labelText: 'Enter a prompt'),
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
                  title: const Text('make instrumental'),
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
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onGenerate(prompt, lyrics, isInstrumental, style, title);
          },
          child: const Text('Generate'),
        )
      ],
    );
  }
}
