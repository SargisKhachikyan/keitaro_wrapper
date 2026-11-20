import 'package:equatable/equatable.dart';

import '../models/stream.dart';

abstract class CampaignEditorEvent extends Equatable {
  const CampaignEditorEvent();

  @override
  List<Object?> get props => [];
}

class CampaignEditorLoadRequested extends CampaignEditorEvent {
  const CampaignEditorLoadRequested(this.campaignId);

  final int campaignId;

  @override
  List<Object?> get props => [campaignId];
}

class CampaignEditorShareChanged extends CampaignEditorEvent {
  const CampaignEditorShareChanged({
    required this.streamId,
    required this.offerId,
    required this.share,
  });

  final int streamId;
  final int offerId;
  final int share;

  @override
  List<Object?> get props => [streamId, offerId, share];
}

class CampaignEditorOfferRemoved extends CampaignEditorEvent {
  const CampaignEditorOfferRemoved({
    required this.streamId,
    required this.offerId,
  });

  final int streamId;
  final int offerId;

  @override
  List<Object?> get props => [streamId, offerId];
}

class CampaignEditorOfferAdded extends CampaignEditorEvent {
  const CampaignEditorOfferAdded({required this.streamId, required this.offer});

  final int streamId;
  final StreamOffer offer;

  @override
  List<Object?> get props => [streamId, offer];
}

class CampaignEditorSaveRequested extends CampaignEditorEvent {
  const CampaignEditorSaveRequested(this.streamId);

  final int streamId;

  @override
  List<Object?> get props => [streamId];
}
