import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/campaign_editor_bloc.dart';
import '../bloc/campaign_editor_event.dart';
import '../bloc/campaign_editor_state.dart';
import '../navigation/campaign_editor_route_guard.dart';
import '../repository/campaigns_repository.dart';
import '../widgets/editor_header.dart';
import '../widgets/stream_list.dart';

class CampaignEditorPage extends StatelessWidget {
  const CampaignEditorPage({super.key, required this.campaignId});

  final int campaignId;

  @override
  Widget build(BuildContext context) {
    if (campaignId <= 0) {
      return const Center(
        child: Text(
          'Invalid campaign ID.',
          style: TextStyle(color: Colors.redAccent),
        ),
      );
    }
    return BlocProvider(
      create: (context) {
        final bloc = CampaignEditorBloc(
          context.read<CampaignsRepository>(),
          campaignId,
        );
        campaignEditorRouteGuard.register(bloc);
        bloc.add(CampaignEditorLoadRequested(campaignId));
        return bloc;
      },
      child: const _CampaignEditorView(),
    );
  }
}

class _CampaignEditorView extends StatelessWidget {
  const _CampaignEditorView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CampaignEditorBloc, CampaignEditorState>(
      listener: (context, state) {
        if (state.status == CampaignEditorStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message ?? 'Changes saved.')),
          );
        }
        if (state.status == CampaignEditorStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Could not load campaign.'),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 8),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == CampaignEditorStatus.loading ||
            state.status == CampaignEditorStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.status == CampaignEditorStatus.failure &&
            state.streams.isEmpty) {
          return Center(
            child: Text(
              state.message ?? 'Could not load campaign.',
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        final campaign = state.campaign;
        return Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EditorHeader(
                campaign: campaign,
                onBack: () => context.go('/campaigns'),
                onRefresh: () => _refresh(context, state),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: StreamList(
                  streams: state.streams,
                  offers: state.options?.offers ?? const [],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refresh(BuildContext context, CampaignEditorState state) async {
    if (!await campaignEditorRouteGuard.confirmDiscard(
      context,
      state.hasUnsavedChanges,
    )) {
      return;
    }
    if (!context.mounted) return;
    context.read<CampaignEditorBloc>().add(
      CampaignEditorLoadRequested(
        state.campaign?.id ?? context.read<CampaignEditorBloc>().campaignId,
      ),
    );
  }
}
