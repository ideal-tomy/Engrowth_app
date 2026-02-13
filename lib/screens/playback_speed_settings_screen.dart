import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/engrowth_theme.dart';
import '../providers/playback_speed_provider.dart';

/// 音声再生速度設定
class PlaybackSpeedSettingsScreen extends ConsumerWidget {
  const PlaybackSpeedSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speed = ref.watch(playbackSpeedProvider);

    return Scaffold(
      backgroundColor: EngrowthColors.background,
      appBar: AppBar(
        title: const Text('音声再生速度'),
        backgroundColor: EngrowthColors.surface,
        foregroundColor: EngrowthColors.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${speed.toStringAsFixed(1)}x',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: EngrowthColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: speed,
              min: 0.5,
              max: 2.0,
              divisions: 6,
              activeColor: EngrowthColors.primary,
              label: '${speed.toStringAsFixed(1)}x',
              onChanged: (v) =>
                  ref.read(playbackSpeedProvider.notifier).setSpeed(v),
            ),
            const SizedBox(height: 16),
            Text(
              '0.5x〜2.0x の範囲で調整できます。TTS音声に反映されます。',
              style: TextStyle(
                fontSize: 14,
                color: EngrowthColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
