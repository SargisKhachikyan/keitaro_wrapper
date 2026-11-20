import 'package:equatable/equatable.dart';

import '../models/campaign.dart';
import '../models/campaign_options.dart';
import '../models/stream.dart';

class CampaignEditorState extends Equatable {
  const CampaignEditorState({
    this.campaign,
    this.options,
    this.streams = const [],
    this.status = CampaignEditorStatus.initial,
    this.message,
    this.hasUnsavedChanges = false,
  });

  final Campaign? campaign;
  final CampaignOptions? options;
  final List<CampaignStream> streams;
  final CampaignEditorStatus status;
  final String? message;
  final bool hasUnsavedChanges;

  CampaignEditorState copyWith({
    Campaign? campaign,
    CampaignOptions? options,
    List<CampaignStream>? streams,
    CampaignEditorStatus? status,
    String? message,
    bool? hasUnsavedChanges,
  }) {
    return CampaignEditorState(
      campaign: campaign ?? this.campaign,
      options: options ?? this.options,
      streams: streams ?? this.streams,
      status: status ?? this.status,
      message: message,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  List<Object?> get props => [
    campaign,
    options,
    streams,
    status,
    message,
    hasUnsavedChanges,
  ];
}

enum CampaignEditorStatus { initial, loading, loaded, saving, success, failure }
