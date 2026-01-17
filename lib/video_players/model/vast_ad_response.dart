class VastAdResponse {
  final bool? success;
  final List<VastAd>? data;

  VastAdResponse({
    this.success,
    this.data,
  });

  factory VastAdResponse.fromJson(Map<String, dynamic> json) => VastAdResponse(
        success: json["success"],
        data: json["data"] == null ? [] : List<VastAd>.from(json["data"]!.map((x) => VastAd.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class VastAd {
  final int? id;
  final String? name;
  final String? type;
  final String? url;
  final String? duration;
  final String? targetType;
  final String? targetSelection;
  final bool? enableSkip;
  final String? skipAfter;
  final int? frequency;
  final DateTime? startDate;
  final DateTime? endDate;

  VastAd({
    this.id,
    this.name,
    this.type,
    this.url,
    this.duration,
    this.targetType,
    this.targetSelection,
    this.enableSkip,
    this.skipAfter,
    this.frequency,
    this.startDate,
    this.endDate,
  });

  factory VastAd.fromJson(Map<String, dynamic> json) => VastAd(
        id: json["id"],
        name: json["name"],
        type: json["type"],
        url: json["url"],
        duration: json["duration"],
        targetType: json["target_type"],
        targetSelection: json["target_selection"],
        enableSkip: json["enable_skip"],
        skipAfter: json["skip_after"],
        frequency: json["frequency"],
        startDate: json["start_date"] == null ? null : DateTime.parse(json["start_date"]),
        endDate: json["end_date"] == null ? null : DateTime.parse(json["end_date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": type,
        "url": url,
        "duration": duration,
        "target_type": targetType,
        "target_selection": targetSelection,
        "enable_skip": enableSkip,
        "skip_after": skipAfter,
        "frequency": frequency,
        "start_date": startDate != null ? "${startDate!.year.toString().padLeft(4, '0')}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}" : null,
        "end_date": endDate != null ? "${endDate!.year.toString().padLeft(4, '0')}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}" : null,
      };
}
