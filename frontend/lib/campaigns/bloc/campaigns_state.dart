import 'package:equatable/equatable.dart';

import '../models/campaign.dart';
import '../models/campaign_options.dart';

class CampaignsState extends Equatable {
  const CampaignsState({
    this.campaigns = const [],
    this.options,
    this.status = CampaignsStatus.initial,
    this.message,
  });

  final List<Campaign> campaigns;
  final CampaignOptions? options;
  final CampaignsStatus status;
  final String? message;

  CampaignsState copyWith({
    List<Campaign>? campaigns,
    CampaignOptions? options,
    CampaignsStatus? status,
    String? message,
  }) {
    return CampaignsState(
      campaigns: campaigns ?? this.campaigns,
      options: options ?? this.options,
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [campaigns, options, status, message];
}

enum CampaignsStatus { initial, loading, loaded, creating, success, failure }
