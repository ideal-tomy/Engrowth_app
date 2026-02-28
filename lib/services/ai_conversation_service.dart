import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AI会話応答生成サービス
/// Edge Function conversation_reply を呼び出し、会話コンテキストを管理
class AiConversationService {
  static const String _functionName = 'conversation_reply';

  /// ユーザー発話からAIの英語返答を生成
  Future<String?> generateReply({
    required String userTranscript,
    String? conversationTitle,
    String? theme,
    List<String>? sampleUtterances,
  }) async {
    if (userTranscript.trim().isEmpty) return null;

    try {
      final body = <String, dynamic>{
        'transcript': userTranscript.trim(),
      };
      if (conversationTitle != null ||
          theme != null ||
          (sampleUtterances != null && sampleUtterances.isNotEmpty)) {
        body['context'] = <String, dynamic>{};
        if (conversationTitle != null) body['context']['title'] = conversationTitle;
        if (theme != null) body['context']['theme'] = theme;
        if (sampleUtterances != null && sampleUtterances.isNotEmpty) {
          body['context']['sampleUtterances'] =
              sampleUtterances.take(6).toList();
        }
      }

      final response = await Supabase.instance.client.functions.invoke(
        _functionName,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.status != 200) {
        if (kDebugMode) {
          debugPrint(
            'AiConversationService error: status=${response.status} data=${response.data}',
          );
        }
        return null;
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) return null;

      final reply = data['reply'] as String?;
      return reply?.trim().isNotEmpty == true ? reply!.trim() : null;
    } catch (e) {
      if (kDebugMode) debugPrint('AiConversationService.generateReply error: $e');
      return null;
    }
  }
}
