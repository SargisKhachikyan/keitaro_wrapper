import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/offers_bloc.dart';
import '../bloc/offers_event.dart';
import '../bloc/offers_state.dart';

import 'package:frontend/offers/widgets/offers_header.dart';

import '../repository/offers_repository.dart';
import '../widgets/offers_table.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';

class OffersPage extends StatelessWidget {
  const OffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          OffersBloc(context.read<OffersRepository>())
            ..add(const OffersLoadRequested()),
      child: const _OffersView(),
    );
  }
}

class _OffersView extends StatelessWidget {
  const _OffersView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OffersBloc, OffersState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OffersHeader(
                isLoading: state.status == OffersStatus.loading,
                onRefresh: () =>
                    context.read<OffersBloc>().add(const OffersLoadRequested()),
              ),
              const SizedBox(height: 24),
              if (state.status == OffersStatus.loading)
                const Expanded(child: LoadingView())
              else if (state.status == OffersStatus.failure)
                Expanded(
                  child: ErrorView(
                    message: state.message ?? 'Could not load offers.',
                  ),
                )
              else
                Expanded(child: OffersTable(offers: state.offers)),
            ],
          ),
        );
      },
    );
  }
}
