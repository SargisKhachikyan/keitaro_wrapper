import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/campaigns_repository.dart';
import 'campaign_editor_event.dart';
import 'campaign_editor_state.dart';

class CampaignEditorBloc
    extends Bloc<CampaignEditorEvent, CampaignEditorState> {
  CampaignEditorBloc(this._repository, this.campaignId)
    : super(const CampaignEditorState()) {
    on<CampaignEditorLoadRequested>(_onLoad);
    on<CampaignEditorShareChanged>(_onShareChanged);
    on<CampaignEditorOfferRemoved>(_onOfferRemoved);
    on<CampaignEditorOfferAdded>(_onOfferAdded);
    on<CampaignEditorSaveRequested>(_onSave);
  }

  final CampaignsRepository _repository;
  final int campaignId;

  Future<void> _onLoad(
    CampaignEditorLoadRequested event,
    Emitter<CampaignEditorState> emit,
  ) async {
    emit(state.copyWith(status: CampaignEditorStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getCampaigns(),
        _repository.getOptions(),
        _repository.getStreams(event.campaignId),
      ]);
      final campaigns = results[0] as dynamic;
      final matching = (campaigns as List).where((item) {
        return item.id == event.campaignId;
      }).toList();
      emit(
        state.copyWith(
          campaign: matching.isEmpty ? null : matching.first,
          options: results[1] as dynamic,
          streams: results[2] as dynamic,
          status: CampaignEditorStatus.loaded,
          hasUnsavedChanges: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CampaignEditorStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  void _onShareChanged(
    CampaignEditorShareChanged event,
    Emitter<CampaignEditorState> emit,
  ) {
    final streams = state.streams.map((stream) {
      if (stream.id != event.streamId) return stream;
      final offers = stream.offers.map((offer) {
        if (offer.offerId != event.offerId) return offer;
        return offer.copyWith(share: event.share.clamp(0, 100).toInt());
      }).toList();
      return stream.copyWith(offers: offers);
    }).toList();
    emit(
      state.copyWith(
        streams: streams,
        status: CampaignEditorStatus.loaded,
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onOfferRemoved(
    CampaignEditorOfferRemoved event,
    Emitter<CampaignEditorState> emit,
  ) {
    final streams = state.streams.map((stream) {
      if (stream.id != event.streamId) return stream;
      return stream.copyWith(
        offers: stream.offers
            .where((offer) => offer.offerId != event.offerId)
            .toList(),
      );
    }).toList();
    emit(
      state.copyWith(
        streams: streams,
        status: CampaignEditorStatus.loaded,
        hasUnsavedChanges: true,
      ),
    );
  }

  void _onOfferAdded(
    CampaignEditorOfferAdded event,
    Emitter<CampaignEditorState> emit,
  ) {
    final streams = state.streams.map((stream) {
      if (stream.id != event.streamId) return stream;
      final alreadyExists = stream.offers.any(
        (offer) => offer.offerId == event.offer.offerId,
      );
      if (alreadyExists) return stream;
      return stream.copyWith(offers: [...stream.offers, event.offer]);
    }).toList();
    emit(
      state.copyWith(
        streams: streams,
        status: CampaignEditorStatus.loaded,
        hasUnsavedChanges: true,
      ),
    );
  }

  Future<void> _onSave(
    CampaignEditorSaveRequested event,
    Emitter<CampaignEditorState> emit,
  ) async {
    final stream = state.streams
        .where((item) => item.id == event.streamId)
        .firstOrNull;
    if (stream == null) return;
    emit(state.copyWith(status: CampaignEditorStatus.saving));
    try {
      await _repository.saveStreamOffers(event.streamId, stream.offers);
      emit(
        state.copyWith(
          status: CampaignEditorStatus.success,
          message: 'Stream ${stream.id} offers saved successfully.',
          hasUnsavedChanges: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CampaignEditorStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
