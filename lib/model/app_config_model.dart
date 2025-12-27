class TagModel {
  String? tags;
  String? sId;

  TagModel({this.tags, this.sId});

  TagModel.fromJson(Map<String, dynamic> json) {
    tags = json['tags'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tags'] = tags;
    data['_id'] = sId;
    return data;
  }
}

class ViewPagerModel {
  String? image;
  String? sId;

  ViewPagerModel({this.image, this.sId});

  ViewPagerModel.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['_id'] = sId;
    return data;
  }
}

class AppConfigData {
  String? sId;
  String? adText;
  List<TagModel>? tag;
  List<ViewPagerModel>? viewPager;
  String? createdAt;
  String? updatedAt;
  int? iV;

  AppConfigData(
      {this.sId,
      this.adText,
      this.tag,
      this.viewPager,
      this.createdAt,
      this.updatedAt,
      this.iV});

  AppConfigData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    adText = json['ad_text'];
    if (json['tag'] != null) {
      tag = <TagModel>[];
      json['tag'].forEach((v) {
        tag!.add(TagModel.fromJson(v));
      });
    }
    if (json['view_pager'] != null) {
      viewPager = <ViewPagerModel>[];
      json['view_pager'].forEach((v) {
        viewPager!.add(ViewPagerModel.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['ad_text'] = adText;
    if (tag != null) {
      data['tag'] = tag!.map((v) => v.toJson()).toList();
    }
    if (viewPager != null) {
      data['view_pager'] = viewPager!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = iV;
    return data;
  }
}

class AppConfigModel {
  bool? success;
  AppConfigData? data;

  AppConfigModel({this.success, this.data});

  AppConfigModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? AppConfigData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}
