import 'package:flutter/material.dart';

class NewSongDialog extends StatefulWidget {
  Function(String prompt, bool isInstrumental) onGenerate;
  NewSongDialog({super.key, required this.onGenerate});

  @override
  State<NewSongDialog> createState() => _NewSongDialogState();
}

class _NewSongDialogState extends State<NewSongDialog> {
  bool isInstrumental = false;
  String prompt = '';
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create a new song'),
      content: Wrap(
        children: <Widget>[
          TextField(
            decoration: InputDecoration(labelText: 'Enter a prompt'),
            minLines: 3,
            maxLines: 100,
            onChanged: (value) {
              prompt = value;
            },
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
            )
          )
        ],
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
            widget.onGenerate(prompt, isInstrumental);
          },
          child: const Text('Generate'),
        )
      ],
    );
  }
}
