import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/env_config.dart';
import 'app.dart';
import 'services/auth_service.dart';
import 'services/playback_speed_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 環境変数の読み込み（.env または dart-define）
  await EnvConfig.load();

  // デプロイ時に Supabase の URL/キーが空だとデータ取得に失敗する
  final url = EnvConfig.supabaseUrl;
  final key = EnvConfig.supabaseAnonKey;
  if (url.isEmpty || key.isEmpty) {
    throw FlutterError(
      'Supabase の接続情報が設定されていません。\n\n'
      'デプロイ時は、ビルド時に --dart-define で渡してください:\n'
      '  .\\scripts\\build_for_deploy.ps1  （Windows）\n'
      '  ./scripts/build_for_deploy.sh    （Mac/Linux）\n\n'
      '詳細: docs/DEPLOY_ENV_SETUP.md',
    );
  }

  // Supabase初期化
  await Supabase.initialize(url: url, anonKey: key);

  // 匿名サインイン（未ログイン時のみ）
  try {
    await AuthService().ensureSignedIn();
  } catch (e) {
    // Supabase で匿名認証が無効な場合などは、そのまま未ログイン状態で起動
    debugPrint('Anonymous sign-in skipped: $e');
  }

  // 音声再生速度をローカルから読み込み
  final speed = await PlaybackSpeedService.getSpeed();
  TtsService.setDefaultSpeechRate(speed);

  runApp(
    const ProviderScope(
      child: EngrowthApp(),
    ),
  );
}
