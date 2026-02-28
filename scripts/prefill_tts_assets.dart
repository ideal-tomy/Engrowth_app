/// 会話データから TTS 音声を一括生成し、Storage キャッシュへ事前投入するバッチ
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/prefill_tts_assets.dart
///   dart run scripts/prefill_tts_assets.dart --dry-run     # 件数確認のみ
///   dart run scripts/prefill_tts_assets.dart --limit 50   # 先頭50件のみ
///   dart run scripts/prefill_tts_assets.dart --include-slow   # 0.6速も投入（Phase 4）
///   dart run scripts/prefill_tts_assets.dart --retries 4  # リトライ回数（デフォルト2）
///   dart run scripts/prefill_tts_assets.dart --report-errors-to errors.json  # 失敗を出力
///   dart run scripts/prefill_tts_assets.dart --retry-from errors.json        # 失敗の再実行
///
/// 前提: .env に SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY（または ANON_KEY）
///       tts_synthesize Edge Function がデプロイ済み、database_tts_assets_migration 実行済み
///
/// 冪等: 既にキャッシュ済みの場合はスキップ（Edge Function がキャッシュヒットを返す）
/// Phase 4: キーは Edge と一致（text|language|voice|speed|tts-1-hd）。速度0.6も --include-slow で投入可。

import 'dart:convert';
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
  final includeSlow = args.contains('--include-slow');
  final limitIdx = args.indexOf('--limit');
  final limit = limitIdx >= 0 && limitIdx + 1 < args.length
      ? int.tryParse(args[limitIdx + 1]) ?? 0
      : 0;
  final retriesIdx = args.indexOf('--retries');
  final maxRetries = retriesIdx >= 0 && retriesIdx + 1 < args.length
      ? (int.tryParse(args[retriesIdx + 1]) ?? 2).clamp(0, 10)
      : 2;
  final reportIdx = args.indexOf('--report-errors-to');
  final reportErrorsTo = reportIdx >= 0 && reportIdx + 1 < args.length
      ? args[reportIdx + 1]
      : null;
  final retryFromIdx = args.indexOf('--retry-from');
  final retryFromFile = retryFromIdx >= 0 && retryFromIdx + 1 < args.length
      ? args[retryFromIdx + 1]
      : null;

  final client = SupabaseClient(url, key);

  List<Map<String, dynamic>> tasks;
  if (retryFromFile != null) {
    final f = File(retryFromFile);
    if (!await f.exists()) {
      print('❌ 再実行ファイルが見つかりません: $retryFromFile');
      exit(1);
    }
    final lines = await f.readAsLines();
    tasks = lines
        .where((l) => l.trim().isNotEmpty)
        .map((l) => Map<String, dynamic>.from(jsonDecode(l) as Map))
        .map((m) => {
              'text': m['text'],
              'language': m['language'] ?? 'en-US',
              'voice': m['voice'] ?? 'nova',
              'speakingRate': (m['speakingRate'] as num?)?.toDouble() ?? 1.0,
            })
        .toList();
    print('📋 再実行: ${tasks.length} 件 ($retryFromFile から)');
  } else {
    tasks = await _buildTasks(client, includeSlow, limit);
  }

  if (tasks.isEmpty) {
    print('📭 処理対象がありません');
    exit(0);
  }

  final total = tasks.length;
  if (retryFromFile == null && dryRun) {
    print('✅ --dry-run のため実行せず終了');
    exit(0);
  }
  if (retryFromFile != null && dryRun) {
    print('✅ --dry-run は --retry-from と併用時は無視します');
  }

  await _runPrefill(
    client: client,
    tasks: tasks,
    maxRetries: maxRetries,
    reportErrorsTo: reportErrorsTo,
  );
}

Future<List<Map<String, dynamic>>> _buildTasks(
  SupabaseClient client,
  bool includeSlow,
  int limit,
) async {
  final utterances = await client
      .from('conversation_utterances')
      .select('english_text, japanese_text, speaker_role');

  if (utterances is! List || utterances.isEmpty) {
    return [];
  }

  // ユニーク (text, language, voice, speed) を構築
  // Edge cacheKey と完全一致させるため同じ正規化を使用
  final Set<String> keys = {};
  final List<Map<String, dynamic>> tasks = [];
  final speeds = [1.0, if (includeSlow) _speedSlow];

  for (final row in utterances) {
    if (row is! Map) continue;
    final en = _normalizeTextForCache((row['english_text'] as String?) ?? '');
    final jp = _normalizeTextForCache((row['japanese_text'] as String?) ?? '');
    final role = (row['speaker_role'] as String?)?.toUpperCase() ?? '';

    for (final speed in speeds) {
      if (en.isNotEmpty) {
        final voice = _voiceForRole(role);
        final k = '$en|en-US|$voice|$speed';
        if (!keys.contains(k)) {
          keys.add(k);
          tasks.add({
            'text': en,
            'language': 'en-US',
            'voice': voice,
            'speakingRate': speed,
          });
        }
      }
      if (jp.isNotEmpty) {
        final voice = _voiceForRole(role);
        final k = '$jp|ja-JP|$voice|$speed';
        if (!keys.contains(k)) {
          keys.add(k);
          tasks.add({
            'text': jp,
            'language': 'ja-JP',
            'voice': voice,
            'speakingRate': speed,
          });
        }
      }
    }
  }

  final result = limit > 0 ? tasks.take(limit).toList() : tasks;
  print('📋 発話ユニーク件数: ${tasks.length} → 処理件数: ${result.length}');
  return result;
}

Future<void> _runPrefill({
  required SupabaseClient client,
  required List<Map<String, dynamic>> tasks,
  required int maxRetries,
  String? reportErrorsTo,
}) async {
  final total = tasks.length;
  var done = 0;
  var hits = 0;
  var errors = 0;
  final failedItems = <Map<String, dynamic>>[];

  for (var i = 0; i < total; i++) {
    final t = tasks[i];
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
        final isHit = data is Map && (data['cache_hit'] == true);
        if (isHit) hits++;
        if (i == 0) {
          print('   1件目: cache_hit=$isHit （false なら Edge 未デプロイ or ハッシュ不一致の可能性）');
        }
        if ((i + 1) % 10 == 0 || i == total - 1) {
          print('   進捗: ${i + 1}/$total (hit: $hits, err: $errors)');
        }
      } catch (e) {
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        } else {
          errors++;
          failedItems.add({...t, 'error': e.toString()});
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
  if (reportErrorsTo != null && failedItems.isNotEmpty) {
    final f = File(reportErrorsTo);
    await f.writeAsString(
      failedItems.map((m) => jsonEncode(m)).join('\n'),
    );
    print('   📄 エラー詳細: $reportErrorsTo に保存');
    print('   🔄 再実行: dart run scripts/prefill_tts_assets.dart --retry-from $reportErrorsTo');
  }
}

String _voiceForRole(String role) {
  if (role == 'A') return _voiceRoleA;
  if (role == 'B') return _voiceRoleB;
  return _voiceRoleB;
}

/// Edge Function と同一の正規化（ハッシュ一致のため）
String _normalizeTextForCache(String text) {
  return text
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');  // 連続空白・改行を単一スペースに
}
