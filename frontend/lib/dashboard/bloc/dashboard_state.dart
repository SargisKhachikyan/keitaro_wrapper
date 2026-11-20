import 'package:equatable/equatable.dart';

import '../../campaigns/models/campaign.dart';
import '../../campaigns/models/campaign_options.dart';

class DashboardState extends Equatable {
  const DashboardState({
    this.campaigns = const [],
    this.options,
    this.status = DashboardStatus.initial,
    this.message,
  });

  final List<Campaign> campaigns;
  final CampaignOptions? options;
  final DashboardStatus status;
  final String? message;

  DashboardState copyWith({
    List<Campaign>? campaigns,
    CampaignOptions? options,
    DashboardStatus? status,
    String? message,
  }) {
    return DashboardState(
      campaigns: campaigns ?? this.campaigns,
      options: options ?? this.options,
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [campaigns, options, status, message];
}

enum DashboardStatus { initial, loading, loaded, failure }
