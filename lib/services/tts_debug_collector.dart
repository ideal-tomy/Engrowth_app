/// TTS エラー時のデバッグ情報を収集し、AI が読み取れる形式で出力する
///
/// 使い方:
/// 1. アプリで音声再生を試す（cache miss が出る）
/// 2. 設定 → 「TTS デバッグ出力」をタップ
/// 3. 「コピー」をタップ
/// 4. プロジェクトルートに debug_tts_output.txt として貼り付けて保存
/// 5. AI に「@debug_tts_output.txt を確認して」と依頼

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../config/env_config.dart';

class TtsDebugEntry {
  TtsDebugEntry({
    required this.timestamp,
    required this.cacheKey,
    required this.textPreview,
    required this.supabaseUrl,
    required this.dbResult,
    required this.dbElapsedMs,
    this.errorMessage,
    this.edgeCalled,
    this.recipeRaw,
  });

  final DateTime timestamp;
  final String cacheKey;
  final String textPreview;
  final String supabaseUrl;
  final String dbResult;
  final int dbElapsedMs;
  final String? errorMessage;
  final bool? edgeCalled;
  /// ハッシュ化する前のレシピ生文字列（犯人特定用）
  final String? recipeRaw;

  String toExportString() {
    final buf = StringBuffer();
    buf.writeln('=== TTS Debug Entry ===');
    buf.writeln('timestamp: $timestamp');
    buf.writeln('cache_key: $cacheKey');
    if (recipeRaw != null) buf.writeln('recipe_raw: $recipeRaw');
    buf.writeln('text_preview: $textPreview');
    buf.writeln('supabase_url: $supabaseUrl');
    buf.writeln('db_result: $dbResult');
    buf.writeln('db_elapsed_ms: $dbElapsedMs');
    if (errorMessage != null) buf.writeln('error: $errorMessage');
    if (edgeCalled != null) buf.writeln('edge_called: $edgeCalled');
    buf.writeln();
    return buf.toString();
  }
}

class TtsDebugCollector {
  TtsDebugCollector._();

  static final List<TtsDebugEntry> _entries = [];
  static const int _maxEntries = 10;

  static void recordDbMiss({
    required String cacheKey,
    required String textPreview,
    required String dbResult,
    required int dbElapsedMs,
    bool edgeCalled = false,
    String? recipeRaw,
  }) {
    if (!kDebugMode) return;
    _add(TtsDebugEntry(
      timestamp: DateTime.now(),
      cacheKey: cacheKey,
      textPreview: textPreview,
      supabaseUrl: EnvConfig.supabaseUrl,
      dbResult: dbResult,
      dbElapsedMs: dbElapsedMs,
      edgeCalled: edgeCalled,
      recipeRaw: recipeRaw,
    ));
  }

  static void recordError({
    required String cacheKey,
    required String textPreview,
    required String dbResult,
    required int dbElapsedMs,
    required String errorMessage,
    bool edgeCalled = false,
  }) {
    if (!kDebugMode) return;
    _add(TtsDebugEntry(
      timestamp: DateTime.now(),
      cacheKey: cacheKey,
      textPreview: textPreview,
      supabaseUrl: EnvConfig.supabaseUrl,
      dbResult: dbResult,
      dbElapsedMs: dbElapsedMs,
      errorMessage: errorMessage,
      edgeCalled: edgeCalled,
    ));
  }

  static void _add(TtsDebugEntry e) {
    _entries.insert(0, e);
    if (_entries.length > _maxEntries) _entries.removeLast();
  }

  static List<TtsDebugEntry> get entries => List.unmodifiable(_entries);

  static String get exportText {
    final buf = StringBuffer();
    buf.writeln('TTS Debug Report');
    buf.writeln('Generated: ${DateTime.now()}');
    buf.writeln('Supabase URL: ${EnvConfig.supabaseUrl}');
    buf.writeln('');
    if (_entries.isEmpty) {
      buf.writeln('(No entries - 音声再生を試して cache miss を発生させてください)');
    } else {
      for (final e in _entries) {
        buf.write(e.toExportString());
      }
    }
    return buf.toString();
  }

  static Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: exportText));
  }
}
