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