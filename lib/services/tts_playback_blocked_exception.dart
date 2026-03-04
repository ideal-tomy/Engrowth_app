/// Web で autoplay 制約により再生がブロックされた場合にスロー
/// tts_service は Web では flutter_tts にフォールバックせず、この例外を再スローする
class TtsPlaybackBlockedException implements Exception {
  final String errorType;

  TtsPlaybackBlockedException(this.errorType);

  @override
  String toString() => 'TtsPlaybackBlockedException: $errorType';
}
