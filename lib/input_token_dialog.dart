import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showCookieInputDialog(
  BuildContext context, {
  required String title,
  required Function(String) onOk,
}) {
  final TextEditingController controller = TextEditingController();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "Your cookie in here"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              String inputValue = controller.text;
              onOk(inputValue);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
