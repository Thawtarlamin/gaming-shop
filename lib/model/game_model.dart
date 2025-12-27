class GameModel {
  Game? game;
  String? sId;
  List<Catalogues>? catalogues;
  String? tag;
  String? status;
  String? createdAt;
  String? updatedAt;
  int? iV;

  GameModel(
      {this.game,
      this.sId,
      this.catalogues,
      this.tag,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.iV});

  GameModel.fromJson(Map<String, dynamic> json) {
    game = json['game'] != null ? new Game.fromJson(json['game']) : null;
    sId = json['_id'];
    if (json['catalogues'] != null) {
      catalogues = <Catalogues>[];
      json['catalogues'].forEach((v) {
        catalogues!.add(new Catalogues.fromJson(v));
      });
    }
    tag = json['tag'];
    status = json['status'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.game != null) {
      data['game'] = this.game!.toJson();
    }
    data['_id'] = this.sId;
    if (this.catalogues != null) {
      data['catalogues'] = this.catalogues!.map((v) => v.toJson()).toList();
    }
    data['tag'] = this.tag;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Game {
  String? code;
  String? name;
  String? imageUrl;

  Game({this.code, this.name, this.imageUrl});

  Game.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    imageUrl = json['image_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['image_url'] = this.imageUrl;
    return data;
  }

  void operator [](int other) {}
}

class Catalogues {
  int? id;
  String? name;
  int? amount;
  String? sId;

  Catalogues({this.id, this.name, this.amount, this.sId});

  Catalogues.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    amount = json['amount'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['amount'] = this.amount;
    data['_id'] = this.sId;
    return data;
  }
}