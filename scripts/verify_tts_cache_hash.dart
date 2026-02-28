/// Edge と prefill のキャッシュキー・ハッシュが一致するか検証する診断スクリプト
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/verify_tts_cache_hash.dart
///
/// 1. DB から1件取得 → Edge と同じルールで cache_key を計算
/// 2. tts_assets にその cache_key が存在するか確認
/// 3. 同じ body で Edge を1回呼び、cache_hit を表示
/// これで「ハッシュのすれ違い」か「デプロイ未反映」かを切り分けできる

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

const _model = 'tts-1-hd';

String normalizeTextForCache(String text) {
  return text.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Edge と完全同一の key 文字列を生成（speed は JS の ${n} と一致させる）
String buildCacheKey(String text, String language, String voice, double speed) {
  final s = (speed * 100).round() / 100;
  final speedStr = (s == s.roundToDouble()) ? s.toInt().toString() : s.toString();
  return '$text|$language|$voice|$speedStr|$_model';
}

String sha256Hex(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

void main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final url = env['SUPABASE_URL'];
  final key = env['SUPABASE_SERVICE_ROLE_KEY'] ?? env['SUPABASE_ANON_KEY'] ?? '';

  if (url == null || url.isEmpty || key.isEmpty) {
    print('❌ .env に SUPABASE_URL とキーを設定してください');
    exit(1);
  }

  final client = SupabaseClient(url, key);

  // 1. 会話1件取得
  final list = await client.from('conversation_utterances').select('english_text, speaker_role').limit(1);
  if (list is! List || list.isEmpty) {
    print('❌ conversation_utterances にデータがありません');
    exit(1);
  }

  final row = list.first as Map;
  final rawEn = (row['english_text'] as String?) ?? '';
  final en = normalizeTextForCache(rawEn);
  final role = ((row['speaker_role'] as String?) ?? '').toUpperCase();
  final voice = role == 'A' ? 'alloy' : (role == 'B' ? 'nova' : 'nova');
  const language = 'en-US';
  const speed = 1.0;

  if (en.isEmpty) {
    print('❌ 英語テキストが空です');
    exit(1);
  }

  final keyStr = buildCacheKey(en, language, voice, speed);
  final keyHash = sha256Hex(keyStr);

  print('--- 検証 ---');
  print('テキスト(正規化後): ${en.length > 50 ? "${en.substring(0, 50)}..." : en}');
  print('key(先頭80文字): ${keyStr.length > 80 ? keyStr.substring(0, 80) + "..." : keyStr}');
  print('cache_key(hash): $keyHash');

  // 2. tts_assets に存在するか
  final result = await client.from('tts_assets').select('id, storage_path').eq('cache_key', keyHash);
  final found = result is List && result.isNotEmpty && result.first is Map;
  if (found) {
    print('✅ DB にこの cache_key が存在します → Edge が正しくデプロイされていればヒットするはず');
  } else {
    print('❌ DB にこの cache_key がありません → prefill でこの発話が未投入か、key 計算が Edge と違う');
  }

  // 3. Edge を1回呼ぶ
  final body = {'text': en, 'language': language, 'voice': voice, 'speakingRate': speed};
  try {
    final res = await client.functions.invoke('tts_synthesize', body: body);
    final data = res.data;
    final hit = data is Map && (data['cache_hit'] == true);
    print('');
    print('Edge 呼び出し結果: cache_hit = $hit');
    if (data is Map && data['url'] != null) {
      print('url(先頭60文字): ${(data['url'] as String).substring(0, 60)}...');
    }
    if (found && !hit) {
      print('');
      print('⚠  DB にはあるが Edge がヒットしていません。');
      print('   → 本番にデプロイされている Edge が古い可能性が高いです。');
      print('   → supabase functions deploy tts_synthesize を実行してください。');
    } else if (!found && hit) {
      print('');
      print('   (この1回で合成され DB に挿入されたため、次回からヒットします)');
    }
  } catch (e) {
    print('');
    print('❌ Edge 呼び出しエラー: $e');
  }
}
