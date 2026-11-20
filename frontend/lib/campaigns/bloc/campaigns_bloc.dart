import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/campaigns_repository.dart';
import 'campaigns_event.dart';
import 'campaigns_state.dart';

class CampaignsBloc extends Bloc<CampaignsEvent, CampaignsState> {
  CampaignsBloc(this._repository) : super(const CampaignsState()) {
    on<CampaignsLoadRequested>(_onLoadRequested);
    on<CampaignCreationRequested>(_onCreationRequested);
  }

  final CampaignsRepository _repository;

  Future<void> _onLoadRequested(
    CampaignsLoadRequested event,
    Emitter<CampaignsState> emit,
  ) async {
    emit(state.copyWith(status: CampaignsStatus.loading));
    try {
      final results = await Future.wait([
        _repository.getCampaigns(),
        _repository.getOptions(),
      ]);
      emit(
        state.copyWith(
          campaigns: results[0] as dynamic,
          options: results[1] as dynamic,
          status: CampaignsStatus.loaded,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CampaignsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _onCreationRequested(
    CampaignCreationRequested event,
    Emitter<CampaignsState> emit,
  ) async {
    emit(state.copyWith(status: CampaignsStatus.creating));
    try {
      final campaignId = await _repository.createCampaignWithStreams(
        name: event.name,
        geo: event.geo,
        domainId: event.domainId,
        groupId: event.groupId,
        trafficSourceId: event.trafficSourceId,
        offerId: event.offerId,
      );
      final campaigns = await _repository.getCampaigns();
      emit(
        state.copyWith(
          campaigns: campaigns,
          status: CampaignsStatus.success,
          message: 'Campaign created successfully (ID: $campaignId).',
        ),
      );
    } on CampaignCreationPartialFailure catch (error) {
      emit(
        state.copyWith(
          status: CampaignsStatus.failure,
          message: error.toString(),
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CampaignsStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
