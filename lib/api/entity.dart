class SongMeta {
  String? id;
  String? videoUrl;
  String? audioUrl;
  String? imageUrl;
  String? imageLargeUrl;
  String? majorModelVersion;
  String? modelName;
  Metadata? metadata;
  bool? isLiked;
  String? userId;
  bool? isTrashed;
  String? createdAt;
  String? status;
  String? title;
  int? playCount;
  int? upvoteCount;
  bool? isPublic;

  SongMeta(
      {this.id,
      this.videoUrl,
      this.audioUrl,
      this.imageUrl,
      this.imageLargeUrl,
      this.majorModelVersion,
      this.modelName,
      this.metadata,
      this.isLiked,
      this.userId,
      this.isTrashed,
      this.createdAt,
      this.status,
      this.title,
      this.playCount,
      this.upvoteCount,
      this.isPublic});

  SongMeta.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoUrl = json['video_url'];
    audioUrl = json['audio_url'];
    imageUrl = json['image_url'];
    imageLargeUrl = json['image_large_url'];
    majorModelVersion = json['major_model_version'];
    modelName = json['model_name'];
    metadata =
        json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null;
    isLiked = json['is_liked'];
    userId = json['user_id'];
    isTrashed = json['is_trashed'];
    createdAt = json['created_at'];
    status = json['status'];
    title = json['title'];
    playCount = json['play_count'];
    upvoteCount = json['upvote_count'];
    isPublic = json['is_public'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['video_url'] = videoUrl;
    data['audio_url'] = audioUrl;
    data['image_url'] = imageUrl;
    data['image_large_url'] = imageLargeUrl;
    data['major_model_version'] = majorModelVersion;
    data['model_name'] = modelName;
    if (metadata != null) {
      data['metadata'] = metadata!.toJson();
    }
    data['is_liked'] = isLiked;
    data['user_id'] = userId;
    data['is_trashed'] = isTrashed;
    data['created_at'] = createdAt;
    data['status'] = status;
    data['title'] = title;
    data['play_count'] = playCount;
    data['upvote_count'] = upvoteCount;
    data['is_public'] = isPublic;
    return data;
  }
  bool hasMp3Url(){
    return audioUrl != null && audioUrl!.isNotEmpty && audioUrl!.endsWith('.mp3');
  }
}

class Metadata {
  String? tags;
  String? prompt;
  String? gptDescriptionPrompt;
  String? type;
  double? duration;
  bool? refundCredits;
  bool? stream;

  Metadata(
      {this.tags,
      this.prompt,
      this.gptDescriptionPrompt,
      this.type,
      this.duration,
      this.refundCredits,
      this.stream});

  Metadata.fromJson(Map<String, dynamic> json) {
    tags = json['tags'];
    prompt = json['prompt'];
    gptDescriptionPrompt = json['gpt_description_prompt'];
    type = json['type'];
    duration = json['duration'];
    refundCredits = json['refund_credits'];
    stream = json['stream'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tags'] = tags;
    data['prompt'] = prompt;
    data['gpt_description_prompt'] = gptDescriptionPrompt;
    data['type'] = type;
    data['duration'] = duration;
    data['refund_credits'] = refundCredits;
    data['stream'] = stream;
    return data;
  }
}

class GenerateItem {
  String? imageUrl;
  String? title;
  String id;

  GenerateItem({this.imageUrl, this.title, required this.id});
}

class LoginInfo {
  String? firstName;
  String? lastName;
  String? avatar;
  late String id;
  LoginInfo({this.firstName, this.lastName, this.avatar});
}

class GenerateLyricsResult {
  String? text;
  String? title;
  String? status;

  GenerateLyricsResult({this.text, this.title, this.status});

  GenerateLyricsResult.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    title = json['title'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = text;
    data['title'] = title;
    data['status'] = status;
    return data;
  }

}

class SunoPlaylist {
  String? id;
  List<PlaylistClips>? playlistClips;
  String? imageUrl;
  int? numTotalResults;
  int? currentPage;
  bool? isOwned;
  bool? isTrashed;
  String? name;
  String? description;
  bool? isPublic;

  SunoPlaylist(
      {this.id,
        this.playlistClips,
        this.imageUrl,
        this.numTotalResults,
        this.currentPage,
        this.isOwned,
        this.isTrashed,
        this.name,
        this.description,
        this.isPublic,
      });

  SunoPlaylist.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    if (json['playlist_clips'] != null) {
      playlistClips = <PlaylistClips>[];
      json['playlist_clips'].forEach((v) {
        playlistClips!.add(new PlaylistClips.fromJson(v));
      });
    }
    imageUrl = json['image_url'];
    numTotalResults = json['num_total_results'];
    currentPage = json['current_page'];
    isOwned = json['is_owned'];
    isTrashed = json['is_trashed'];
    name = json['name'];
    description = json['description'];
    isPublic = json['is_public'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    if (playlistClips != null) {
      data['playlist_clips'] =
          playlistClips!.map((v) => v.toJson()).toList();
    }
    data['image_url'] = imageUrl;
    data['num_total_results'] = numTotalResults;
    data['current_page'] = currentPage;
    data['is_owned'] = isOwned;
    data['is_trashed'] = isTrashed;
    data['name'] = name;
    data['description'] = description;
    data['is_public'] = isPublic;
    return data;
  }

  List<SongMeta> getSongMetaList(){
    List<SongMeta> songMetaList = [];
    if(playlistClips != null){
      for (var playlistClip in playlistClips!) {
        if(playlistClip.clip != null){
          songMetaList.add(playlistClip.clip!);
        }
      }
    }
    return songMetaList;
  }
}

class PlaylistClips {
  SongMeta? clip;
  double? relativeIndex;
  String? updatedAt;

  PlaylistClips({this.clip, this.relativeIndex, this.updatedAt});

  PlaylistClips.fromJson(Map<String, dynamic> json) {
    clip = json['clip'] != null ? new SongMeta.fromJson(json['clip']) : null;
    relativeIndex = json['relative_index'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (clip != null) {
      data['clip'] = clip!.toJson();
    }
    data['relative_index'] = relativeIndex;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class UserPlaylist {
  late int currentPage;
  late int numTotalResults;
  List<SunoPlaylist> playlists = [];
  static fromJson(Map<String, dynamic> json) {
    UserPlaylist userPlaylist = UserPlaylist();
    userPlaylist.currentPage = json['current_page'];
    userPlaylist.numTotalResults = json['num_total_results'];
    List<dynamic> playlists = json['playlists'];
    for (var playlist in playlists) {
      userPlaylist.playlists.add(SunoPlaylist.fromJson(playlist));
    }
    return userPlaylist;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['num_total_results'] = numTotalResults;
    data['playlists'] = playlists.map((playlist) => playlist.toJson()).toList();
    return data;
  }
}

