import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'generated/l10n.dart';

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
          decoration: InputDecoration(hintText: S.of(context).InputCookieDialog_Title),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(S.of(context).Close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(S.of(context).OK),
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
