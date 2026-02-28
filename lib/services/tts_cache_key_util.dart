/// TTS キャッシュキー生成ユーティリティ
/// Edge Function および prefill と完全同一の正規化・ハッシュロジックを提供
import 'dart:convert';

import 'package:crypto/crypto.dart';

const String kTtsModel = 'tts-1-hd';

/// キャッシュキー用: 前後trim + 連続空白・改行を単一スペースに（Edge と完全一致）
String normalizeTextForCache(String text) {
  return text.trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Edge と完全同一の key 文字列を生成
/// speed は JS の ${n} と一致（1.0 -> "1", 0.6 -> "0.6"）
String buildTtsCacheKey({
  required String text,
  String language = 'en-US',
  required String voice,
  double speed = 1.0,
  String model = kTtsModel,
}) {
  final clamped = speed.clamp(0.25, 4.0);
  final rounded = (clamped * 100).round() / 100;
  final speedStr = (rounded == rounded.roundToDouble())
      ? rounded.toInt().toString()
      : rounded.toString();
  return '$text|$language|$voice|$speedStr|$model';
}

/// SHA-256 ハッシュを16進文字列で返す
String sha256Hex(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
