// To parse this JSON data, do
//
//     final promoPopUpListModel = promoPopUpListModelFromJson(jsonString);

import 'dart:convert';

PromoPopUpListModel promoPopUpListModelFromJson(String str) =>
    PromoPopUpListModel.fromJson(json.decode(str));

String promoPopUpListModelToJson(PromoPopUpListModel data) =>
    json.encode(data.toJson());

class PromoPopUpListModel {
  List<PromoPopUpData> data;

  PromoPopUpListModel({
    required this.data,
  });

  factory PromoPopUpListModel.fromJson(Map<String, dynamic> json) =>
      PromoPopUpListModel(
        data: List<PromoPopUpData>.from(
            json["data"].map((x) => PromoPopUpData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class PromoPopUpData {
  String subject;
  String previewImage;
  DateTime from;
  DateTime to;
  int time;
  bool active;

  PromoPopUpData({
    required this.subject,
    required this.previewImage,
    required this.from,
    required this.to,
    required this.time,
    required this.active,
  });

  factory PromoPopUpData.fromJson(Map<String, dynamic> json) => PromoPopUpData(
        subject: json["subject"] ?? '',
        previewImage: json["preview_image"] ?? '',
        from: DateTime.parse(json["from"]),
        to: DateTime.parse(json["to"]),
        time: json["time"] ?? 0,
        active: json["active"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "subject": subject,
        "preview_image": previewImage,
        "from": from.toIso8601String(),
        "to": to.toIso8601String(),
        "time": time,
        "active": active,
      };
}
