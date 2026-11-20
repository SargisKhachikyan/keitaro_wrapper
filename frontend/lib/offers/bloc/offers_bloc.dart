import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/offers_repository.dart';
import 'offers_event.dart';
import 'offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  OffersBloc(this._repository) : super(const OffersState()) {
    on<OffersLoadRequested>(_onLoadRequested);
  }

  final OffersRepository _repository;

  Future<void> _onLoadRequested(
    OffersLoadRequested event,
    Emitter<OffersState> emit,
  ) async {
    emit(state.copyWith(status: OffersStatus.loading));
    try {
      final offers = await _repository.getOffers();
      emit(state.copyWith(offers: offers, status: OffersStatus.loaded));
    } catch (error) {
      emit(
        state.copyWith(status: OffersStatus.failure, message: error.toString()),
      );
    }
  }
}
