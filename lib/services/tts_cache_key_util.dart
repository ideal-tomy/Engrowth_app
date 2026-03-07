/// TTS キャッシュキー生成ユーティリティ
/// Edge Function および prefill と完全同一の正規化・ハッシュロジックを提供
import 'dart:convert';

import 'package:crypto/crypto.dart';

const String kTtsModel = 'tts-1';

/// キャッシュキー用: trim + 改行を \n に統一 + 小文字化（Edge・prefill と完全一致）
String normalizeTextForCache(String text) {
  return text
      .trim()
      .replaceAll(RegExp(r'\r\n|\r'), '\n')
      .toLowerCase();
}

/// Edge と完全同一の key 文字列を生成
/// speed は JS の ${n} と一致（1.0 -> "1", 0.6 -> "0.6"）
/// Dart の浮動小数点 toString 問題（0.6→0.6000000000000001）を回避するため
/// toStringAsFixed(2) で丸め、末尾の 0 を削除
String buildTtsCacheKey({
  required String text,
  String language = 'en-US',
  required String voice,
  double speed = 1.0,
  String model = kTtsModel,
}) {
  final clamped = speed.clamp(0.25, 4.0);
  final rounded = (clamped * 100).round() / 100;
  final speedStr = rounded == rounded.truncateToDouble()
      ? rounded.toInt().toString()
      : rounded.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  return '$text|$language|$voice|$speedStr|$model';
}

/// SHA-256 ハッシュを16進文字列で返す
String sha256Hex(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
