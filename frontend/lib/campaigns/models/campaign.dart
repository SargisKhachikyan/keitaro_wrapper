class Campaign {
  const Campaign({
    required this.id,
    required this.name,
    required this.alias,
    required this.state,
    required this.groupId,
    required this.domainId,
    required this.trafficSourceId,
    required this.updatedAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: _int(json['id']),
      name: json['name']?.toString() ?? '',
      alias: json['alias']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      groupId: _int(json['group_id']),
      domainId: _int(json['domain_id']),
      trafficSourceId: _int(json['traffic_source_id']),
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  final int id;
  final String name;
  final String alias;
  final String state;
  final int groupId;
  final int domainId;
  final int trafficSourceId;
  final String updatedAt;
}

int _int(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
