import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/env_config.dart';
import 'app.dart';
import 'services/playback_speed_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 環境変数の読み込み（.env または dart-define）
  await EnvConfig.load();

  // Supabase初期化
  await Supabase.initialize(
    url: EnvConfig.supabaseUrl,
    anonKey: EnvConfig.supabaseAnonKey,
  );

  // 音声再生速度をローカルから読み込み
  final speed = await PlaybackSpeedService.getSpeed();
  TtsService.setDefaultSpeechRate(speed);

  runApp(
    const ProviderScope(
      child: EngrowthApp(),
    ),
  );
}
