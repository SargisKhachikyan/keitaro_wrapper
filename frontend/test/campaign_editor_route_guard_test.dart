import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/campaigns/bloc/campaign_editor_bloc.dart';
import 'package:frontend/campaigns/bloc/campaign_editor_event.dart';
import 'package:frontend/campaigns/models/campaign.dart';
import 'package:frontend/campaigns/models/campaign_options.dart';
import 'package:frontend/campaigns/models/stream.dart';
import 'package:frontend/campaigns/navigation/campaign_editor_route_guard.dart';
import 'package:frontend/campaigns/repository/campaigns_repository.dart';
import 'package:frontend/core/api/api_client.dart';
import 'package:frontend/core/layout/sidebar_menu_item.dart';

void main() {
  testWidgets('sidebar navigation can be cancelled or confirmed when dirty', (
    tester,
  ) async {
    final guard = CampaignEditorRouteGuard();
    final bloc = CampaignEditorBloc(_FakeCampaignsRepository(), 1);
    addTearDown(bloc.close);

    final loaded = bloc.stream.firstWhere((state) => state.streams.isNotEmpty);
    bloc.add(const CampaignEditorLoadRequested(1));
    await loaded;
    final dirty = bloc.stream.firstWhere((state) => state.hasUnsavedChanges);
    bloc.add(
      const CampaignEditorShareChanged(streamId: 10, offerId: 100, share: 50),
    );
    await dirty;
    guard.register(bloc);
    addTearDown(() => guard.unregister(bloc));

    final router = GoRouter(
      initialLocation: '/editor',
      routes: [
        GoRoute(
          path: '/editor',
          onExit: guard.onExit,
          builder: (context, state) => BlocProvider.value(
            value: bloc,
            child: const Scaffold(
              body: SidebarMenuItem(
                icon: Icons.campaign_outlined,
                title: 'Leave editor',
                route: '/target',
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/target',
          builder: (context, state) =>
              const Scaffold(body: Text('Target page')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leave editor'));
    await tester.pumpAndSettle();
    expect(find.text('Discard unsaved changes'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Leave editor'), findsOneWidget);
    expect(bloc.state.hasUnsavedChanges, isTrue);

    await tester.tap(find.text('Leave editor'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('Target page'), findsOneWidget);
  });
}

class _FakeCampaignsRepository extends CampaignsRepository {
  _FakeCampaignsRepository() : super(ApiClient());

  @override
  Future<List<Campaign>> getCampaigns() async => const [];

  @override
  Future<CampaignOptions> getOptions() async => const CampaignOptions(
    groups: [],
    domains: [],
    trafficSources: [],
    offers: [],
  );

  @override
  Future<List<CampaignStream>> getStreams(int campaignId) async => [
    CampaignStream(
      id: 10,
      name: 'Stream',
      type: 'regular',
      schema: 'landings',
      actionType: 'http',
      actionPayload: null,
      filters: const [],
      offers: const [StreamOffer(offerId: 100, share: 100, state: 'active')],
      state: 'active',
    ),
  ];
}
