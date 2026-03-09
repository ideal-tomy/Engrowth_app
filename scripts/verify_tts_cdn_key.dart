/// 指定発話の cache_key が CDN audio_index.json に存在するか検証する
///
/// 再生できない発話について、アプリと同一規則でキーを計算し index に存在するか確認。
/// 不一致時は speed / voice / 正規化 のどれが原因か分類する。
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/verify_tts_cdn_key.dart --text "Hello world" --role B
///   dart run scripts/verify_tts_cdn_key.dart --text "Hello" --role A --speed 0.6
///   dart run scripts/verify_tts_cdn_key.dart --conversation-id <UUID> --utterance-index 2
///
/// 前提: .env に TTS_AUDIO_INDEX_URL（および --conversation-id 時は SUPABASE_*）

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';

const _model = 'tts-1';
const _timeout = Duration(seconds: 15);

String normalizeTextForCache(String text) {
  return text
      .trim()
      .replaceAll(RegExp(r'\r\n|\r'), '\n')
      .toLowerCase();
}

String buildTtsCacheKey({
  required String text,
  String language = 'en-US',
  required String voice,
  double speed = 1.0,
}) {
  final clamped = speed.clamp(0.25, 4.0);
  final rounded = (clamped * 100).round() / 100;
  final speedStr = rounded == rounded.truncateToDouble()
      ? rounded.toInt().toString()
      : rounded.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  return '$text|$language|$voice|$speedStr|$_model';
}

String sha256Hex(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

String voiceForRole(String? role) {
  if (role == null) return 'nova';
  final r = role.toUpperCase();
  if (r == 'A') return 'alloy';
  if (r == 'B') return 'nova';
  return 'nova';
}

void main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final indexUrl = env['TTS_AUDIO_INDEX_URL']?.trim();
  if (indexUrl == null || indexUrl.isEmpty) {
    print('❌ .env に TTS_AUDIO_INDEX_URL を設定してください');
    exit(1);
  }

  String? text;
  String? role;
  double speed = 1.0;
  String? conversationId;
  int? utteranceIndex;

  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--text' && i + 1 < args.length) {
      text = args[i + 1];
      i++;
    } else if (args[i] == '--role' && i + 1 < args.length) {
      role = args[i + 1];
      i++;
    } else if (args[i] == '--speed' && i + 1 < args.length) {
      speed = double.tryParse(args[i + 1]) ?? 1.0;
      i++;
    } else if (args[i].startsWith('--conversation-id=')) {
      conversationId = args[i].split('=').sublist(1).join('=').trim();
      if (conversationId!.isEmpty) conversationId = null;
    } else if (args[i] == '--utterance-index' && i + 1 < args.length) {
      utteranceIndex = int.tryParse(args[i + 1]);
      i++;
    }
  }

  if (conversationId != null && utteranceIndex != null) {
    final url = env['SUPABASE_URL'];
    final key = env['SUPABASE_SERVICE_ROLE_KEY'] ?? env['SUPABASE_ANON_KEY'] ?? '';
    if (url == null || key.isEmpty) {
      print('❌ --conversation-id 利用時は .env に SUPABASE_URL とキーが必要です');
      exit(1);
    }
    final client = SupabaseClient(url, key);
    final rows = await client
        .from('conversation_utterances')
        .select('english_text, speaker_role')
        .eq('conversation_id', conversationId!)
        .order('utterance_order', ascending: true)
        .range(utteranceIndex!, utteranceIndex!);
    if (rows is! List || rows.isEmpty) {
      print('❌ 発話が見つかりません conversation_id=$conversationId index=$utteranceIndex');
      exit(1);
    }
    final row = (rows as List).first as Map;
    text = row['english_text'] as String? ?? '';
    role = row['speaker_role'] as String?;
  }

  if (text == null || text.trim().isEmpty) {
    print('❌ --text "..." または --conversation-id + --utterance-index で発話を指定してください');
    exit(1);
  }

  final voice = voiceForRole(role);
  final normalized = normalizeTextForCache(text);
  if (normalized.isEmpty) {
    print('❌ 正規化後のテキストが空です');
    exit(1);
  }

  print('--- CDN index 照合 ---');
  print('テキスト(正規化後): ${normalized.length > 60 ? "${normalized.substring(0, 60)}..." : normalized}');
  print('role: $role → voice: $voice, speed: $speed');

  Map<String, dynamic>? indexData;
  try {
    final res = await http.get(Uri.parse(indexUrl)).timeout(_timeout);
    if (res.statusCode != 200) {
      print('❌ index 取得失敗 HTTP ${res.statusCode}');
      exit(1);
    }
    indexData = jsonDecode(res.body) as Map<String, dynamic>?;
  } catch (e) {
    print('❌ index 取得エラー: $e');
    exit(1);
  }
  final entries = indexData!['entries'];
  if (entries is! Map) {
    print('❌ index に entries がありません');
    exit(1);
  }
  final indexEntries = Map<String, String>.from(entries.map((k, v) => MapEntry(k as String, v as String)));

  final keyStr = buildTtsCacheKey(text: normalized, voice: voice, speed: speed);
  final keyHash = sha256Hex(keyStr);
  print('cache_key(hash): $keyHash');

  final inIndex = indexEntries.containsKey(keyHash);
  if (inIndex) {
    print('✅ CDN index に存在します → 再生されるはずです（Web側で 404/CORS 等が無ければ）');
    exit(0);
  }

  print('❌ CDN index に存在しません');
  print('');
  print('--- 原因分類のヒント ---');

  final atSpeed10 = buildTtsCacheKey(text: normalized, voice: voice, speed: 1.0);
  final hash10 = sha256Hex(atSpeed10);
  final atSpeed06 = buildTtsCacheKey(text: normalized, voice: voice, speed: 0.6);
  final hash06 = sha256Hex(atSpeed06);

  if (speed != 1.0 && indexEntries.containsKey(hash10)) {
    print('- speed ${speed} で検索しましたが、index には speed 1.0 のキーのみあります。');
    print('  → アプリの再生速度を 1.0 にすると再生される可能性があります。');
  } else if (speed == 1.0 && indexEntries.containsKey(hash06)) {
    print('- speed 1.0 で検索しましたが、index には speed 0.6 のキーのみあります。');
    print('  → 再生速度 0.6 用の音声が index に含まれている可能性があります。');
  } else {
    print('- このテキスト・voice・speed の組み合わせでは index にエントリがありません。');
    print('  → build_audio_index の元（tts_assets）に該当 cache_key が入っているか確認してください。');
    print('  → 正規化・voice・speed・model がアプリと一致しているか verify_tts_cache_hash も併用してください。');
  }
  exit(1);
}
