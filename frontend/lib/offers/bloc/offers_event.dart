import 'package:equatable/equatable.dart';

abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object?> get props => [];
}

class OffersLoadRequested extends OffersEvent {
  const OffersLoadRequested();
}
