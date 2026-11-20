import 'package:equatable/equatable.dart';

abstract class CampaignsEvent extends Equatable {
  const CampaignsEvent();

  @override
  List<Object?> get props => [];
}

class CampaignsLoadRequested extends CampaignsEvent {
  const CampaignsLoadRequested();
}

class CampaignCreationRequested extends CampaignsEvent {
  const CampaignCreationRequested({
    required this.name,
    required this.geo,
    required this.domainId,
    required this.groupId,
    required this.trafficSourceId,
    required this.offerId,
  });

  final String name;
  final String geo;
  final int domainId;
  final int groupId;
  final int trafficSourceId;
  final int offerId;

  @override
  List<Object?> get props => [
    name,
    geo,
    domainId,
    groupId,
    trafficSourceId,
    offerId,
  ];
}
