import 'package:flutter/material.dart';
import 'theme/engrowth_theme.dart';
import 'utils/router.dart';

class EngrowthApp extends StatelessWidget {
  const EngrowthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Engrowth - 英会話学習',
      theme: EngrowthTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
