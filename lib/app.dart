import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_mode_provider.dart';
import 'services/tts_service.dart';
import 'theme/engrowth_theme.dart';
import 'utils/router.dart';

final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class EngrowthApp extends ConsumerStatefulWidget {
  const EngrowthApp({super.key});

  @override
  ConsumerState<EngrowthApp> createState() => _EngrowthAppState();
}

class _EngrowthAppState extends ConsumerState<EngrowthApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeModeProvider.notifier).load();
    });
    TtsService.onWebPlaybackBlocked = (retry) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: const Text('再生を開始するにはタップしてください'),
          action: SnackBarAction(
            label: '再生',
            onPressed: () => retry(),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Engrowth - 英会話学習',
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: EngrowthTheme.lightTheme,
      darkTheme: EngrowthTheme.darkTheme,
      themeMode: themeMode ?? ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
