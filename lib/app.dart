import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/theme_mode_provider.dart';
import 'theme/engrowth_theme.dart';
import 'utils/router.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Engrowth - 英会話学習',
      theme: EngrowthTheme.lightTheme,
      darkTheme: EngrowthTheme.darkTheme,
      themeMode: themeMode ?? ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
