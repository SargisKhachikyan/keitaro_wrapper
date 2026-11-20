import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/campaigns_bloc.dart';
import '../bloc/campaigns_event.dart';
import '../bloc/campaigns_state.dart';

import 'package:frontend/campaigns/widgets/campaigns_header.dart';
import 'package:frontend/campaigns/widgets/campaign_create_dialog.dart';
import 'package:frontend/campaigns/widgets/campaign_table.dart';

import '../repository/campaigns_repository.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/error_view.dart';

class CampaignsPage extends StatelessWidget {
  const CampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CampaignsBloc(context.read<CampaignsRepository>())
            ..add(const CampaignsLoadRequested()),
      child: const _CampaignsView(),
    );
  }
}

class _CampaignsView extends StatelessWidget {
  const _CampaignsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CampaignsBloc, CampaignsState>(
      listener: (context, state) {
        if (state.status == CampaignsStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Campaign created.')),
          );
        }
        if (state.status == CampaignsStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'An error occurred.'),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 8),
            ),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CampaignsHeader(
                isLoading: state.status == CampaignsStatus.loading,
                onRefresh: () => context.read<CampaignsBloc>().add(
                  const CampaignsLoadRequested(),
                ),
                onCreate: state.options == null
                    ? null
                    : () => showDialog<void>(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: context.read<CampaignsBloc>(),
                          child: CampaignCreateDialog(options: state.options!),
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              if (state.status == CampaignsStatus.loading &&
                  state.campaigns.isEmpty)
                const Expanded(child: LoadingView())
              else if (state.status == CampaignsStatus.failure &&
                  state.campaigns.isEmpty)
                Expanded(
                  child: ErrorView(
                    message: state.message ?? 'Could not load campaigns.',
                  ),
                )
              else
                Expanded(child: CampaignTable(campaigns: state.campaigns)),
            ],
          ),
        );
      },
    );
  }
}
