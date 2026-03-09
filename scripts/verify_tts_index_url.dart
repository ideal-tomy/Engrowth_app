/// 公開中の TTS audio_index.json のエントリ件数を検証する
///
/// 使い方（プロジェクトルートで）:
///   dart run scripts/verify_tts_index_url.dart
///   dart run scripts/verify_tts_index_url.dart --expected 14548
///
/// .env の TTS_AUDIO_INDEX_URL を GET し、entries の件数を表示。
/// --expected を指定した場合、一致すれば exit 0、不一致なら exit 1。

import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;

const _timeout = Duration(seconds: 15);

void main(List<String> args) async {
  final env = DotEnv(includePlatformEnvironment: true)..load(['.env']);
  final indexUrl = env['TTS_AUDIO_INDEX_URL']?.trim();

  if (indexUrl == null || indexUrl.isEmpty) {
    print('❌ .env に TTS_AUDIO_INDEX_URL を設定してください');
    exit(1);
  }

  int? expectedCount;
  final idx = args.indexOf('--expected');
  if (idx >= 0 && idx + 1 < args.length) {
    expectedCount = int.tryParse(args[idx + 1]);
    if (expectedCount == null || expectedCount < 0) {
      print('❌ --expected には 0 以上の整数を指定してください');
      exit(1);
    }
  }

  print('📥 取得中: $indexUrl');
  try {
    final res = await http.get(Uri.parse(indexUrl)).timeout(_timeout);
    if (res.statusCode != 200) {
      print('❌ HTTP ${res.statusCode}');
      exit(1);
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>?;
    if (data == null) {
      print('❌ JSON のパースに失敗しました');
      exit(1);
    }
    final entries = data['entries'];
    if (entries is! Map) {
      print('❌ entries がオブジェクトではありません');
      exit(1);
    }
    final count = entries.length;
    final baseUrl = data['baseUrl'] as String? ?? '(なし)';
    print('   件数: $count');
    print('   baseUrl: $baseUrl');

    if (expectedCount != null) {
      if (count == expectedCount) {
        print('✅ 期待件数（$expectedCount）と一致しました');
        exit(0);
      } else {
        print('❌ 期待件数: $expectedCount、実際: $count（不一致）');
        print('   → audio_index.json を再生成・再アップロードしてから再度検証してください。');
        exit(1);
      }
    }
    exit(0);
  } catch (e) {
    print('❌ エラー: $e');
    exit(1);
  }
}
