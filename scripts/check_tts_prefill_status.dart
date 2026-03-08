/// prefill の「完了／未完了」を発話単位で確認するスクリプト
///
/// アプリが参照する cache_key（発話テキスト正規化 + en-US + voice + speed 1.0 + tts-1）
/// が tts_assets に存在するかを照合し、証拠用の一覧を出力する。
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/check_tts_prefill_status.dart
///   dart run scripts/check_tts_prefill_status.dart --conversation-id=<UUID>
///   dart run scripts/check_tts_prefill_status.dart --limit 100
///   dart run scripts/check_tts_prefill_status.dart --output=report.csv
///
/// 出力:
///   - 発話ごとに in_tts_assets: YES/NO を表示
///   - --output=FILE で CSV を出力（証拠提示用）
///   - 「prefill 完了（DB に存在）なのにアプリで再生されない」場合は、
///     当該発話の cache_key がアプリ側と一致しているか verify_tts_cache_hash で確認

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';
import 'package:supabase/supabase.dart';

const _model = 'tts-1';

String _normalizeTextForCache(String text) {
  return text
      .trim()
      .replaceAll(RegExp(r'\r\n|\r'), '\n')
      .toLowerCase();
}

String _buildCacheKey(String text, String language, String voice, double speed) {
  final s = (speed * 100).round() / 100;
  final speedStr = (s == s.roundToDouble()) ? s.toInt().toString() : s.toString();
  return '$text|$language|$voice|$speedStr|$_model';
}

String _sha256Hex(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

String _voiceForRole(String role) {
  final r = role.toUpperCase();
  if (r == 'A') return 'alloy';
  if (r == 'B') return 'nova';
  return 'nova';
}

void main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final url = env['SUPABASE_URL'];
  final key = env['SUPABASE_SERVICE_ROLE_KEY'] ?? env['SUPABASE_ANON_KEY'] ?? '';

  if (url == null || url.isEmpty || key.isEmpty) {
    print('❌ .env に SUPABASE_URL とキーを設定してください');
    exit(1);
  }

  String? conversationId;
  int limit = 0;
  String? outputPath;
  for (var i = 0; i < args.length; i++) {
    if (args[i].startsWith('--conversation-id=')) {
      conversationId = args[i].split('=').last.trim();
      if (conversationId.isEmpty) conversationId = null;
    } else if (args[i] == '--limit' && i + 1 < args.length) {
      limit = int.tryParse(args[i + 1]) ?? 0;
    } else if (args[i].startsWith('--output=')) {
      outputPath = args[i].split('=').last.trim();
      if (outputPath.isEmpty) outputPath = null;
    }
  }

  final client = SupabaseClient(url, key);

  // conversation_utterances を取得（会話単位で order、アプリと同じ条件）
  // Supabase はデフォルト 1000 件上限のため、全件取得時はページネーションする
  const pageSize = 1000;
  final List<dynamic> utterances = [];
  if (conversationId != null && conversationId.isNotEmpty) {
    // 1会話だけなら1クエリで十分
    dynamic query = client
        .from('conversation_utterances')
        .select('id, conversation_id, utterance_order, english_text, speaker_role')
        .eq('conversation_id', conversationId)
        .order('utterance_order', ascending: true);
    if (limit > 0) query = query.limit(limit);
    final rows = await query;
    if (rows is List && rows.isNotEmpty) utterances.addAll(rows);
  } else {
    // 全件: ページネーションで取得（prefill と同じ）
    var page = 0;
    while (true) {
      final from = page * pageSize;
      final to = from + pageSize - 1;
      final rows = await client
          .from('conversation_utterances')
          .select('id, conversation_id, utterance_order, english_text, speaker_role')
          .order('conversation_id', ascending: true)
          .order('utterance_order', ascending: true)
          .range(from, to);
      if (rows is! List || rows.isEmpty) break;
      utterances.addAll(rows as List);
      if ((rows as List).length < pageSize) break;
      page++;
    }
    if (limit > 0 && utterances.length > limit) {
      utterances.removeRange(limit, utterances.length);
    }
  }

  if (utterances.isEmpty) {
    print('発話がありません。conversation_id や limit を確認してください。');
    exit(0);
  }

  print('照合対象: conversation_utterances ${utterances.length} 件（Supabase 全件取得済み）');
  final List<Map<String, dynamic>> results = [];
  const speed = 1.0; // アプリのデフォルト再生速度で照合

  for (var i = 0; i < utterances.length; i++) {
    final row = utterances[i] as Map;
    final convId = row['conversation_id'] as String? ?? '';
    final order = row['utterance_order'] as int? ?? i;
    final rawEn = (row['english_text'] as String?) ?? '';
    final role = (row['speaker_role'] as String?) ?? '';
    if (rawEn.trim().isEmpty) {
      results.add({
        'conversation_id': convId,
        'utterance_order': order,
        'text_preview': '(empty)',
        'cache_key_hash': '',
        'in_tts_assets': false,
      });
      continue;
    }
    final norm = _normalizeTextForCache(rawEn);
    final voice = _voiceForRole(role);
    final keyStr = _buildCacheKey(norm, 'en-US', voice, speed);
    final hash = _sha256Hex(keyStr);
    results.add({
      'conversation_id': convId,
      'utterance_order': order,
      'text_preview': rawEn.length > 60 ? '${rawEn.substring(0, 60)}...' : rawEn,
      'cache_key_hash': hash,
      'in_tts_assets': null, // 後で一括照合
      '_hash': hash,
    });
  }

  // tts_assets に存在する cache_key を一括取得（バッチで照合）
  final hashes = results.where((r) => r['_hash'] != null).map((r) => r['_hash'] as String).toSet().toList();
  final Set<String> existingKeys = {};
  const batchSize = 300;
  for (var i = 0; i < hashes.length; i += batchSize) {
    final batch = hashes.skip(i).take(batchSize).toList();
    final res = await client.from('tts_assets').select('cache_key').inFilter('cache_key', batch);
    if (res is List) {
      for (final row in res) {
        if (row is Map && row['cache_key'] != null) {
          existingKeys.add(row['cache_key'] as String);
        }
      }
    }
  }

  for (final r in results) {
    final h = r['_hash'] as String?;
    r['in_tts_assets'] = h != null && h.isNotEmpty && existingKeys.contains(h);
    r.remove('_hash');
  }

  final inDb = results.where((r) => r['in_tts_assets'] == true).length;
  final missing = results.where((r) => r['in_tts_assets'] == false && (r['text_preview'] as String) != '(empty)').length;
  final empty = results.where((r) => (r['text_preview'] as String) == '(empty)').length;

  print('--- TTS prefill 照合結果 ---');
  print('発話数: ${results.length}（英語空: $empty）');
  print('tts_assets に存在: $inDb');
  print('tts_assets に不在（再生されない可能性）: $missing');
  print('');

  if (missing > 0) {
    print('--- 不在だった発話（先頭20件）---');
    var count = 0;
    for (final r in results) {
      if (r['in_tts_assets'] != true && (r['text_preview'] as String) != '(empty)') {
        print('  [${r['conversation_id']}] order=${r['utterance_order']} ${(r['text_preview'] as String).replaceAll('\n', ' ')}');
        if (++count >= 20) break;
      }
    }
    if (missing > 20) print('  ... 他 ${missing - 20} 件');
    print('');
  }

  if (outputPath != null && outputPath.isNotEmpty) {
    final sb = StringBuffer();
    sb.writeln('conversation_id,utterance_order,text_preview,cache_key_hash,in_tts_assets');
    for (final r in results) {
      final preview = (r['text_preview'] as String).replaceAll('"', '""').replaceAll('\n', ' ');
      final inAssets = (r['in_tts_assets'] == true) ? 'YES' : 'NO';
      sb.writeln('"${r['conversation_id']}",${r['utterance_order']},"$preview",${r['cache_key_hash']},$inAssets');
    }
    await File(outputPath).writeAsString(sb.toString(), flush: true);
    print('📄 CSV: $outputPath');
    print('');
    print('証拠提示: 同じ会話をアプリで再生し、in_tts_assets=YES なのに再生されない発話があればキー不一致の可能性あり。');
    print('ハッシュ確認（そのままコピペして発話テキストを入れる）:');
    print('  dart run scripts/verify_tts_cache_hash.dart --text "発話の英語テキスト"');
  }

  exit(0);
}
