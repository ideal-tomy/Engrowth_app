import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/conversation_provider.dart';
import 'tts_service.dart';

/// 一覧表示時の TTS 先読みウォームアップ
/// 可視カードの先頭数発話の URL を非同期取得（再生はしない）
class TtsWarmupService {
  static const _maxConversations = 3;
  static const _maxUtterancesPerConversation = 3;

  final TtsService _ttsService = TtsService();

  /// 会話IDリストの先頭分について、先頭3発話の音声URLを先読み
  /// ref が必要（conversationWithUtterancesProvider 利用のため）
  void warmupForConversationIds(
    WidgetRef ref,
    List<String> conversationIds, {
    int maxConvs = _maxConversations,
    int maxUtts = _maxUtterancesPerConversation,
  }) {
    if (conversationIds.isEmpty) return;
    for (var i = 0; i < maxConvs && i < conversationIds.length; i++) {
      _warmupOne(ref, conversationIds[i], maxUtts);
    }
  }

  void _warmupOne(WidgetRef ref, String conversationId, int maxUtts) {
    ref.read(conversationWithUtterancesProvider(conversationId).future).then((cwu) {
      final utterances = cwu.utterances
          .where((u) => u.englishText.trim().isNotEmpty)
          .take(maxUtts)
          .toList();
      for (final u in utterances) {
        _ttsService.fetchAudioUrlForEnglish(
          u.englishText,
          role: u.speakerRole,
        );
      }
    }).catchError((_) {});
  }
}
