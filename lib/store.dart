import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'api/entity.dart';

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

class UserPlayHistory {
  List<SongMeta> songs = [];
  int index;

  UserPlayHistory({required this.songs, this.index = 0});

  static fromJson(Map<String, dynamic> json) {
    List<SongMeta> songs = [];
    for (var song in json['songs']) {
      songs.add(SongMeta.fromJson(song));
    }
    return UserPlayHistory(songs: songs, index: json['index']);
  }

  Map toJson() {
    return {
      'songs': songs.map((song) => song.toJson()).toList(),
      'index': index
    };
  }
}

class PlaylistHistory {
  Map<String, UserPlayHistory> historyMap = {};

  static fromJson(Map<String, dynamic> json) {
    PlaylistHistory history = PlaylistHistory();
    json.forEach((key, value) {
      history.historyMap[key] = UserPlayHistory.fromJson(value);
    });
    return history;
  }

  Map toJson() {
    return historyMap.map((key, value) => MapEntry(key, value.toJson()));
  }

  UserPlayHistory getHistory(String userId) {
    if (!historyMap.containsKey(userId)) {
      historyMap[userId] = UserPlayHistory(songs: []);
    }
    return historyMap[userId]!;
  }

  setHistory(String userId, UserPlayHistory history) {
    historyMap[userId] = history;
  }
}

class AppDataStore {
  static const String CONFIG_STORE_KEY = 'app_config';
  static const String PLAYLIST_HISTORY_KEY = 'playlist_history_save_1';
  static const String LOGOUT_FLAG_KEY = 'logout_flag';
  late AppConfig config;
  late PlaylistHistory playlistHistory;
  bool logoutFlag = false;
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
    if (prefs.containsKey(LOGOUT_FLAG_KEY)) {
      logoutFlag = prefs.getBool(LOGOUT_FLAG_KEY)!;
    }
    if (prefs.containsKey(PLAYLIST_HISTORY_KEY)) {
      String raw = prefs.getString(PLAYLIST_HISTORY_KEY)!;
      try {
        var historyRaw = jsonDecode(raw);
        playlistHistory = PlaylistHistory.fromJson(historyRaw);
      } catch (e) {
        print(e);
      }
    } else {
      playlistHistory = PlaylistHistory();
    }

  }

  save() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String configString = jsonEncode(config.toJson());
    prefs.setString(CONFIG_STORE_KEY, configString);
  }

  addUserData(User user) async {
    config.addUser(user);
    await save();
  }

  User? getLastLoginUser() {
    if (config.users.isEmpty) {
      return null;
    }
    return config.users[0];
  }

  saveHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String historyString = jsonEncode(playlistHistory.toJson());
    prefs.setString(PLAYLIST_HISTORY_KEY, historyString);
  }

  setLogoutFlag(bool flag) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    logoutFlag = flag;
    prefs.setBool(LOGOUT_FLAG_KEY, flag);
  }
}
