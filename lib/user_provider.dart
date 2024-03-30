import 'package:flutter/material.dart';
import 'package:untitled/api/client.dart';
import 'package:untitled/store.dart';

import 'api/entity.dart';

class UserProvider extends ChangeNotifier {
  SunoClient client = SunoClient();
  LoginInfo? loginInfo;

  void setLoginInfo(LoginInfo info) {
    loginInfo = info;
    notifyListeners();
  }

  void loginOut() {
    loginInfo = null;
    notifyListeners();
  }

  loginUser(String cookie) async {
    client.applyCookie(cookie);
    final loginInfo = await client.getSession();
    if (loginInfo != null) {
      await AppDataStore().addUserData(User(
          id: loginInfo.id,
          firstName: loginInfo.firstName,
          lastName: loginInfo.lastName,
          avatar: loginInfo.avatar,
          token: client.cookie,
          sid: client.sid));
      this.loginInfo = loginInfo;
    }
    notifyListeners();
  }
}
