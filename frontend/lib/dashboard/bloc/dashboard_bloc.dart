import 'package:flutter_bloc/flutter_bloc.dart';

import '../../campaigns/repository/campaigns_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<DashboardLoadRequested>(_onLoadRequested);
  }

  final CampaignsRepository _repository;

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(status: DashboardStatus.loading));
    try {
      final campaigns = await _repository.getCampaigns();
      final options = await _repository.getOptions();
      emit(
        state.copyWith(
          campaigns: campaigns,
          options: options,
          status: DashboardStatus.loaded,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: DashboardStatus.failure,
          message: error.toString(),
        ),
      );
    }
  }
}
