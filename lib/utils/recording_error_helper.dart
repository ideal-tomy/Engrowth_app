/// 録音エラー時のユーザー向けメッセージを統一して返す
/// MissingPluginException（path_provider未実装）や権限エラーを判別
class RecordingErrorHelper {
  /// 例外からユーザー向けメッセージを取得
  static String getUserMessage(Object e) {
    final s = e.toString();
    if (s.contains('MissingPluginException') ||
        s.contains('getApplicationDocumentsDirectory') ||
        s.contains('path_provider')) {
      return 'この環境では録音未対応です。スマホ実機でお試しください';
    }
    if (s.contains('Permission') || s.contains('権限')) {
      return 'マイクの使用許可をください（設定アプリから）';
    }
    if (s.contains('not supported') ||
        s.contains('未対応') ||
        s.contains('web') ||
        s.contains('desktop')) {
      return 'この環境では録音未対応です。スマホ実機でお試しください';
    }
    return '録音エラー（マイク権限・実機実行をご確認ください）';
  }

  /// path_provider未実装かどうか（再試行が無意味な場合）
  static bool isUnsupportedEnvironment(Object e) {
    final s = e.toString();
    return s.contains('MissingPluginException') ||
        s.contains('getApplicationDocumentsDirectory') ||
        s.contains('path_provider') ||
        s.contains('not supported') ||
        s.contains('未対応');
  }
}
