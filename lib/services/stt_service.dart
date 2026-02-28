import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 音声認識（STT）サービス
/// 録音ファイルをサーバー（OpenAI Whisper経由）でテキスト化
class SttService {
  static const String _functionName = 'stt_transcribe';

  /// 録音ファイルをテキストに変換
  /// 成功時はテキスト、失敗時は null
  Future<String?> transcribeFile(File audioFile) async {
    if (!await audioFile.exists()) return null;

    try {
      final bytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: {'audio_base64': base64Audio},
        headers: {'Content-Type': 'application/json'},
      );

      if (response.status != 200) {
        if (kDebugMode) {
          debugPrint('STT error: status=${response.status} data=${response.data}');
        }
        return null;
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      final text = data['text'] as String?;
      return text?.trim().isNotEmpty == true ? text!.trim() : null;
    } catch (e) {
      if (kDebugMode) debugPrint('SttService.transcribeFile error: $e');
      return null;
    }
  }
}
