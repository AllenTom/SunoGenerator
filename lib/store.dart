import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class User {
  String id;
  String? firstName;
  String? lastName;
  String? avatar;
  String sid;
  String token;

  User(
      {this.firstName,
      this.lastName,
      this.avatar,
      required this.sid,
      required this.token,
      required this.id});

  static fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      sid: json['sid'],
      token: json['token'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstName'] = firstName;
    data['lastName'] = lastName;
    data['avatar'] = avatar;
    data['sid'] = sid;
    data['token'] = token;
    data['id'] = id;
    return data;
  }
}

class AppConfig {
  List<User> users = [];

  static fromJson(Map<String, dynamic> json) {
    AppConfig config = AppConfig();
    List<dynamic> users = json['users'];
    for (var user in users) {
      config.users.add(User.fromJson(user));
    }
    return config;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['users'] = users.map((user) => user.toJson()).toList();
    return data;
  }
  void addUser(User user) {
    users = users.where((u) => u.id != user.id).toList();
    users.insert(0, user);
  }
}

class AppDataStore {
  static const String CONFIG_STORE_KEY = 'app_config';
  late AppConfig config;
  static final AppDataStore _instance = AppDataStore._internal();

  factory AppDataStore() {
    return _instance;
  }

  AppDataStore._internal();

  refresh() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(CONFIG_STORE_KEY)) {
      config = AppConfig();
      return;
    }
    final String configString = prefs.getString(CONFIG_STORE_KEY)!;
    final raw = jsonDecode(configString);
    config = AppConfig.fromJson(raw);
  }

  save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String configString = jsonEncode(config.toJson());
    prefs.setString(CONFIG_STORE_KEY, configString);
  }

  addUserData(User user) async{
    config.addUser(user);
    await save();
  }
  User? getLastLoginUser() {
    if (config.users.isEmpty) {
      return null;
    }
    return config.users[0];
  }
}
