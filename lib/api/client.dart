import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:random_x/random_x.dart';
import 'package:untitled/api/entity.dart';

class SunoClient {
  var dio = Dio();
  final String get_session_url =
      "https://clerk.suno.ai/v1/client?_clerk_js_version=4.70.5";
  final String ua = RndX.getRandomUA();
  String token = "";
  String sid = "";
  String cookie = "";

  static final SunoClient _singleton = SunoClient._internal();

  factory SunoClient() {
    return _singleton;
  }

  SunoClient._internal() {}

  void applyCookie(String cookieString) {
    cookie = cookieString;
  }

  Future<LoginInfo?> getSession() async {
    var headers = {
      'Cookie': cookie,
      'User-Agent': ua,
      'Accept': 'application/json'
    };
    var response = await dio.request(
      'https://clerk.suno.ai/v1/client?_clerk_js_version=4.70.5',
      options: Options(
        method: 'GET',
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      token =
          response.data['response']['sessions'][0]['last_active_token']['jwt'];
      sid = response.data['response']['last_active_session_id'];
      LoginInfo info = LoginInfo();
      if (sid != '') {
        List sessions = response.data['response']["sessions"];
        for (var session in sessions) {
          if (session['id'] == sid) {
            info.firstName = session["public_user_data"]["first_name"];
            info.lastName = session["public_user_data"]["last_name"];
            info.avatar = session["public_user_data"]["image_url"];
            info.id = session["user"]["id"];
          }
        }
        return info;
      }
    } else {
      print(response.statusMessage);
      return null;
    }
    return null;
  }

  Future<String> renewToken() async {
    var headers = {
      'Cookie': cookie,
      'User-Agent': ua,
      'Accept': 'application/json'
    };
    var response = await dio.request(
      'https://clerk.suno.ai/v1/client/sessions/$sid/tokens?_clerk_js_version=4.70.5',
      options: Options(
        method: 'POST',
        headers: headers,
      ),
    );
    if (response.statusCode == 200) {
      token = response.data['jwt'];
      return token;
    } else {
      print(response.statusMessage);
      return '';
    }
  }

  Future getLimitLeft() async {
    var response =
        await dio.request('https://studio-api.suno.ai/api/billing/info/',
            options: Options(method: 'GET', headers: {
              'Cookie': cookie,
              'User-Agent': ua,
              'Accept': 'application/json',
              'Authorization': 'Bearer $token'
            }));
    return response.data['total_credits_left'];
  }

  Future<List<SongMeta>> getSongMetadata() async {
    await renewToken();
    var response = await dio.request('https://studio-api.suno.ai/api/feed',
        options: Options(method: 'GET', headers: {
          'Cookie': cookie,
          'User-Agent': ua,
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        }));
    List<SongMeta> songs = [];
    for (var song in response.data) {
      songs.add(SongMeta.fromJson(song));
    }
    return songs;
  }

  Future<void> generateSong(
      {required StreamController<List<GenerateItem>> updateStateController,
      String? prompt,
      String? lyrics,
      bool isInstrumental = false,
      String? style,
      String? title}) async {
    await renewToken();
    var requestData = {
      "gpt_description_prompt": prompt,
      "mv": "chirp-v3-0",
      "prompt": lyrics,
      "make_instrumental": isInstrumental,
      "style": style,
      "title": title
    };
    var response =
        await dio.request('https://studio-api.suno.ai/api/generate/v2/',
            data: requestData,
            options: Options(
              method: 'POST',
              headers: {
                'Cookie': cookie,
                'User-Agent': ua,
                'Accept': 'application/json',
                'Authorization': 'Bearer $token'
              },
            ));
    var data = response.data;
    var clips = data['clips'];
    var ids = [];
    for (var clip in clips) {
      String id = clip['id'];
      ids.add(id);
    }
    var idsQuery = ids.join(',');
    var completeId = [];
    while (completeId.length < clips.length) {
      print("query ids: $idsQuery");
      try {
        var feedResponse = await dio.request(
            'https://studio-api.suno.ai/api/feed?ids=$idsQuery',
            options: Options(method: 'GET', headers: {
              'Cookie': cookie,
              'User-Agent': ua,
              'Accept': 'application/json',
              'Authorization': 'Bearer $token'
            }));
        List<GenerateItem> generatingSongs = [];
        feedResponse.data.forEach((song) {
          SongMeta meta = SongMeta.fromJson(song);
          if (meta.videoUrl != '' || meta.hasMp3Url()) {
            completeId.add(meta.id);
            ids.remove(meta.id);
          } else {
            generatingSongs.add(GenerateItem(
                id: meta.id!, imageUrl: meta.imageUrl, title: meta.title));
          }
          updateStateController.add(generatingSongs);
        });
      } catch (exception) {
        if (exception is DioException) {
          if (exception.response?.statusCode == 401) {
            print('Token expired,auto renew');
            token = await renewToken();
          }
        }
      } finally {
        await Future.delayed(const Duration(seconds: 3));
      }
    }
    print("generate complete");
  }

  loginOut() async {
    sid = '';
    token = '';
  }

  Future<Uint8List> downloadFileWithUrl(String url) async {
    var response = await dio.get(url,
        options: Options(responseType: ResponseType.bytes, headers: {
          'Cookie': cookie,
          'User-Agent': ua,
        }));
    Uint8List data = response.data;
    return data;
  }

  Future<String?> generateLyrics(String prompt) async {
    var requestData = {
      "prompt": prompt,
    };
    var response =
        await dio.request('https://studio-api.suno.ai/api/generate/lyrics/',
            data: requestData,
            options: Options(
              method: 'POST',
              headers: {
                'Cookie': cookie,
                'User-Agent': ua,
                'Accept': 'application/json',
                'Authorization': 'Bearer $token'
              },
            ));
    if (response.statusCode == 200) {
      return response.data["id"];
    } else {
      print(response.statusMessage);
      return null;
    }
  }

  Future<GenerateLyricsResult?> getGenerateLyrics(String id) async {
    var response =
        await dio.request('https://studio-api.suno.ai/api/generate/lyrics/$id',
            options: Options(
              method: 'GET',
              headers: {
                'Cookie': cookie,
                'User-Agent': ua,
                'Accept': 'application/json',
                'Authorization': 'Bearer $token'
              },
            ));
    if (response.statusCode == 200) {
      return GenerateLyricsResult.fromJson(response.data);
    } else {
      print(response.statusMessage);
      return null;
    }
  }

  Future<GenerateLyricsResult?> generateRandomLyrics(
      {String prompt = ""}) async {
    String? id = await generateLyrics(prompt);
    if (id == null) {
      return null;
    }
    // wait for 5 seconds
    await Future.delayed(Duration(seconds: 5));
    var result = await getGenerateLyrics(id);
    return result;
  }

  Future deleteSongs(List<String> ids) async {
    await renewToken();
    var response =
        await dio.request('https://studio-api.suno.ai/api/gen/trash/',
            data: {"clip_ids": ids, "trash": true},
            options: Options(
              method: 'POST',
              headers: {
                'Cookie': cookie,
                'User-Agent': ua,
                'Accept': 'application/json',
                'Authorization': 'Bearer $token'
              },
            ));
    return response.data;
  }

  Future<SunoPlaylist> getPlaylist({required String id, int page = 1}) async {
    await renewToken();
    var response =
        await dio.request('https://studio-api.suno.ai/api/playlist/$id/',
            queryParameters: {"page": page},
            options: Options(method: 'GET', headers: {
              'Cookie': cookie,
              'User-Agent': ua,
              'Accept': 'application/json',
              'Authorization': 'Bearer $token'
            }));
    return SunoPlaylist.fromJson(response.data);
  }
}
