import 'package:shared_preferences/shared_preferences.dart';

const _key = 'playback_speed';

/// 音声再生速度をローカル保存
class PlaybackSpeedService {
  static Future<double> getSpeed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_key) ?? 1.0;
  }

  static Future<void> setSpeed(double speed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_key, speed);
  }
}
