import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

/// 録音サービス
/// ユーザーの発話を録音・再生
class RecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentRecordingPath;
  bool _isRecording = false;
  bool _hasRecording = false;

  /// 録音開始
  Future<void> startRecording() async {
    if (_isRecording) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = '${directory.path}/$fileName';

      if (await _recorder.hasPermission()) {
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _currentRecordingPath!,
        );
        _isRecording = true;
        _hasRecording = false;
      } else {
        throw Exception('マイク権限がありません');
      }
    } catch (e) {
      print('録音開始エラー: $e');
      rethrow;
    }
  }

  /// 録音停止
  Future<String?> stopRecording() async {
    if (!_isRecording) return null;

    try {
      final path = await _recorder.stop();
      _isRecording = false;
      _hasRecording = path != null;
      return path;
    } catch (e) {
      print('録音停止エラー: $e');
      _isRecording = false;
      return null;
    }
  }

  /// 録音中かどうか
  bool get isRecording => _isRecording;

  /// 録音ファイルがあるかどうか
  bool get hasRecording => _hasRecording;

  /// 録音ファイルのパス
  String? get recordingPath => _currentRecordingPath;

  /// 録音ファイルを削除
  Future<void> deleteRecording() async {
    if (_currentRecordingPath != null) {
      try {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      } catch (e) {
        print('録音ファイル削除エラー: $e');
      }
      _currentRecordingPath = null;
      _hasRecording = false;
    }
  }

  /// 破棄
  Future<void> dispose() async {
    await _recorder.dispose();
    await deleteRecording();
  }
}
