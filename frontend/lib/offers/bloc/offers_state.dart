import 'package:equatable/equatable.dart';

import '../../campaigns/models/campaign_options.dart';

class OffersState extends Equatable {
  const OffersState({
    this.offers = const [],
    this.status = OffersStatus.initial,
    this.message,
  });

  final List<OptionItem> offers;
  final OffersStatus status;
  final String? message;

  OffersState copyWith({
    List<OptionItem>? offers,
    OffersStatus? status,
    String? message,
  }) {
    return OffersState(
      offers: offers ?? this.offers,
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [offers, status, message];
}

enum OffersStatus { initial, loading, loaded, failure }
