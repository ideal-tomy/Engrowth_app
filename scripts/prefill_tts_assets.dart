/// 会話データから TTS 音声を一括生成し、Storage キャッシュへ事前投入するバッチ
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/prefill_tts_assets.dart
///   dart run scripts/prefill_tts_assets.dart --dry-run     # 件数確認のみ
///   dart run scripts/prefill_tts_assets.dart --limit 50    # 先頭50件のみ
///
/// 前提: .env に SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY（または ANON_KEY）
///       tts_synthesize Edge Function がデプロイ済み、database_tts_assets_migration 実行済み
///
/// 冪等: 既にキャッシュ済みの場合はスキップ（Edge Function がキャッシュヒットを返す）

import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

const _voiceRoleA = 'alloy';
const _voiceRoleB = 'nova';
const _voiceJapanese = 'alloy';
const _speedDefault = 1.0;
const _speedSlow = 0.6;

void main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final url = env['SUPABASE_URL'];
  final serviceKey = env['SUPABASE_SERVICE_ROLE_KEY'];
  final anonKey = env['SUPABASE_ANON_KEY'];

  if (url == null || url.isEmpty) {
    print('❌ .env に SUPABASE_URL を設定してください');
    exit(1);
  }
  final key = (serviceKey ?? anonKey) ?? '';
  if (key.isEmpty) {
    print('❌ .env に SUPABASE_SERVICE_ROLE_KEY または SUPABASE_ANON_KEY を設定してください');
    exit(1);
  }

  final dryRun = args.contains('--dry-run');
  final limitIdx = args.indexOf('--limit');
  final limit = limitIdx >= 0 && limitIdx + 1 < args.length
      ? int.tryParse(args[limitIdx + 1]) ?? 0
      : 0;

  final client = SupabaseClient(url, key);

  final utterances = await client
      .from('conversation_utterances')
      .select('english_text, japanese_text, speaker_role');

  if (utterances is! List || utterances.isEmpty) {
    print('📭 発話データがありません');
    exit(0);
  }

  // ユニーク (text, language, voice, speed) を構築
  final Set<String> keys = {};
  final List<Map<String, dynamic>> tasks = [];

  for (final row in utterances) {
    if (row is! Map) continue;
    final en = (row['english_text'] as String?)?.trim() ?? '';
    final jp = (row['japanese_text'] as String?)?.trim() ?? '';
    final role = (row['speaker_role'] as String?)?.toUpperCase() ?? '';

    if (en.isNotEmpty) {
      final voice = _voiceForRole(role);
      final k = '$en|en-US|$voice|$_speedDefault';
      if (!keys.contains(k)) {
        keys.add(k);
        tasks.add({
          'text': en,
          'language': 'en-US',
          'voice': voice,
          'speakingRate': _speedDefault,
        });
      }
    }
    if (jp.isNotEmpty) {
      final voice = _voiceForRole(role);
      final k = '$jp|ja-JP|$voice|$_speedDefault';
      if (!keys.contains(k)) {
        keys.add(k);
        tasks.add({
          'text': jp,
          'language': 'ja-JP',
          'voice': voice,
          'speakingRate': _speedDefault,
        });
      }
    }
  }

  final toProcess = limit > 0 ? tasks.take(limit).toList() : tasks;
  final total = toProcess.length;
  print('📋 発話ユニーク件数: ${tasks.length} → 処理件数: $total');

  if (dryRun) {
    print('✅ --dry-run のため実行せず終了');
    exit(0);
  }

  var done = 0;
  var hits = 0;
  var errors = 0;

  const maxRetries = 2;
  for (var i = 0; i < total; i++) {
    final t = toProcess[i];
    var succeeded = false;
    for (var attempt = 0; attempt <= maxRetries && !succeeded; attempt++) {
      try {
        final res = await client.functions.invoke(
          'tts_synthesize',
          body: t,
        );
        done++;
        succeeded = true;
        final data = res.data;
        if (data is Map && (data['cache_hit'] == true)) {
          hits++;
        }
        if ((i + 1) % 10 == 0 || i == total - 1) {
          print('   進捗: ${i + 1}/$total (hit: $hits, err: $errors)');
        }
      } catch (e) {
        lastError = e;
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        } else {
          errors++;
          final txt = t['text']?.toString() ?? '';
          final preview = txt.length > 30 ? '${txt.substring(0, 30)}...' : txt;
          final details = e is FunctionException
              ? ' (status: ${e.status}, details: ${e.details})'
              : '';
          print('   ⚠ エラー [$preview]: $e$details');
        }
      }
    }
  }

  print('✅ 完了: $done 件処理, キャッシュヒット $hits, エラー $errors');
}

String _voiceForRole(String role) {
  if (role == 'A') return _voiceRoleA;
  if (role == 'B') return _voiceRoleB;
  return _voiceRoleB;
}
