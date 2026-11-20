class StreamOffer {
  const StreamOffer({
    required this.offerId,
    required this.share,
    required this.state,
  });

  factory StreamOffer.fromJson(Map<String, dynamic> json) {
    return StreamOffer(
      offerId: _int(json['offer_id']),
      share: _int(json['share']),
      state: json['state']?.toString() ?? 'active',
    );
  }

  final int offerId;
  final int share;
  final String state;

  StreamOffer copyWith({int? share, String? state}) {
    return StreamOffer(
      offerId: offerId,
      share: share ?? this.share,
      state: state ?? this.state,
    );
  }

  Map<String, dynamic> toJson() => {
    'offer_id': offerId,
    'share': share,
    'state': state,
  };
}

class StreamFilter {
  const StreamFilter({
    required this.name,
    required this.mode,
    required this.payload,
  });

  factory StreamFilter.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    return StreamFilter(
      name: json['name']?.toString() ?? '',
      mode: json['mode']?.toString() ?? 'accept',
      payload: payload is List
          ? payload.map((item) => item.toString()).toList()
          : const [],
    );
  }

  final String name;
  final String mode;
  final List<String> payload;

  Map<String, dynamic> toJson() => {
    'name': name,
    'mode': mode,
    'payload': payload,
  };
}

class CampaignStream {
  const CampaignStream({
    required this.id,
    required this.name,
    required this.type,
    required this.schema,
    required this.actionType,
    required this.actionPayload,
    required this.filters,
    required this.offers,
    required this.state,
  });

  factory CampaignStream.fromJson(Map<String, dynamic> json) {
    final filters = json['filters'];
    final offers = json['offers'];
    return CampaignStream(
      id: _int(json['id']),
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      schema: json['schema']?.toString() ?? '',
      actionType: json['action_type']?.toString() ?? '',
      actionPayload: json['action_payload']?.toString(),
      filters: filters is List
          ? filters.whereType<Map>().map((item) {
              return StreamFilter.fromJson(Map<String, dynamic>.from(item));
            }).toList()
          : const [],
      offers: offers is List
          ? offers.whereType<Map>().map((item) {
              return StreamOffer.fromJson(Map<String, dynamic>.from(item));
            }).toList()
          : const [],
      state: json['state']?.toString() ?? '',
    );
  }

  final int id;
  final String name;
  final String type;
  final String schema;
  final String actionType;
  final String? actionPayload;
  final List<StreamFilter> filters;
  final List<StreamOffer> offers;
  final String state;

  CampaignStream copyWith({List<StreamOffer>? offers}) {
    return CampaignStream(
      id: id,
      name: name,
      type: type,
      schema: schema,
      actionType: actionType,
      actionPayload: actionPayload,
      filters: filters,
      offers: offers ?? this.offers,
      state: state,
    );
  }
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
