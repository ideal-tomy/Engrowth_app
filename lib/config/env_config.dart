/// 環境変数の読み取り
/// - Vercel デプロイ時: --dart-define で渡された値を優先
/// - ローカル開発時: .env の値を使用
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static String? _supabaseUrl;
  static String? _supabaseAnonKey;
  static String? _enableGroupImageUrls;
  static String? _googleTtsApiKey;

  /// dotenv をロード（.env が無い場合はスキップ）
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // .env が存在しない場合（Vercel など）は dart-define に依存
    }
  }

  static String get supabaseUrl =>
      _supabaseUrl ??
      (const String.fromEnvironment('SUPABASE_URL', defaultValue: '').isNotEmpty
          ? const String.fromEnvironment('SUPABASE_URL')
          : dotenv.env['SUPABASE_URL'] ?? '');

  static String get supabaseAnonKey =>
      _supabaseAnonKey ??
      (const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '')
                  .isNotEmpty
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : dotenv.env['SUPABASE_ANON_KEY'] ?? '');

  /// Google Cloud Text-to-Speech API キー（未設定時はデバイスTTSを使用）
  static String? get googleTtsApiKey =>
      _googleTtsApiKey ??
      (const String.fromEnvironment('GOOGLE_TTS_API_KEY', defaultValue: '').isNotEmpty
          ? const String.fromEnvironment('GOOGLE_TTS_API_KEY')
          : (dotenv.env['GOOGLE_TTS_API_KEY']?.trim().isNotEmpty == true
              ? dotenv.env['GOOGLE_TTS_API_KEY']!.trim()
              : null));

  /// ENABLE_GROUP_IMAGE_URLS が true か
  static bool get enableGroupImageUrls {
    if (_enableGroupImageUrls != null) {
      return _enableGroupImageUrls!.toLowerCase() == 'true' ||
          _enableGroupImageUrls == '1';
    }
    final fromDefine =
        const String.fromEnvironment('ENABLE_GROUP_IMAGE_URLS', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine.toLowerCase() == 'true' || fromDefine == '1';
    }
    final fromEnv = dotenv.env['ENABLE_GROUP_IMAGE_URLS']?.toLowerCase();
    return fromEnv == 'true' || fromEnv == '1';
  }

  /// テスト用に上書き（未使用時は null）
  static void setForTest({
    String? supabaseUrl,
    String? supabaseAnonKey,
    String? enableGroupImageUrls,
    String? googleTtsApiKey,
  }) {
    _supabaseUrl = supabaseUrl;
    _supabaseAnonKey = supabaseAnonKey;
    _enableGroupImageUrls = enableGroupImageUrls;
    _googleTtsApiKey = googleTtsApiKey;
  }
}
