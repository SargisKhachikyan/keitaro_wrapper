import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/api/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'campaigns/repository/campaigns_repository.dart';
import 'offers/repository/offers_repository.dart';
import 'core/auth/auth_gate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ApiClient _apiClient;
  late final CampaignsRepository _campaignsRepository;
  late final OffersRepository _offersRepository;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient();
    _campaignsRepository = CampaignsRepository(_apiClient);
    _offersRepository = OffersRepository(_campaignsRepository);
  }

  @override
  void dispose() {
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _apiClient),
        RepositoryProvider.value(value: _campaignsRepository),
        RepositoryProvider.value(value: _offersRepository),
      ],
      child: AuthGate(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Keitaro Wrapper',
          routerConfig: appRouter,
          theme: AppTheme.dark,
        ),
      ),
    );
  }
}
