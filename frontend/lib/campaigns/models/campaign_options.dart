class OptionItem {
  const OptionItem({required this.id, required this.name, this.state});

  factory OptionItem.fromJson(Map<String, dynamic> json) {
    return OptionItem(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      state: json['state']?.toString(),
    );
  }

  final int id;
  final String name;
  final String? state;
}

class CampaignOptions {
  const CampaignOptions({
    required this.groups,
    required this.domains,
    required this.trafficSources,
    required this.offers,
  });

  factory CampaignOptions.fromJson(Map<String, dynamic> json) {
    return CampaignOptions(
      groups: _items(json['groups']),
      domains: _items(json['domains']),
      trafficSources: _items(json['traffic_sources']),
      offers: _items(json['offers']),
    );
  }

  final List<OptionItem> groups;
  final List<OptionItem> domains;
  final List<OptionItem> trafficSources;
  final List<OptionItem> offers;
}

List<OptionItem> _items(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map((item) {
    return OptionItem.fromJson(Map<String, dynamic>.from(item));
  }).toList();
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
