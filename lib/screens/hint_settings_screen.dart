import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/hint_settings_provider.dart';

class HintSettingsScreen extends ConsumerWidget {
  const HintSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(hintSettingsProvider);
    final notifier = ref.read(hintSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ヒント設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ヒントタイミング設定
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ヒントタイミング',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 初期ヒントまでの時間
                  _buildSliderSetting(
                    label: '初期ヒントまでの時間',
                    value: settings.initialHintDelaySeconds.toDouble(),
                    min: 1,
                    max: 10,
                    unit: '秒',
                    onChanged: (value) {
                      notifier.updateDelaySeconds(initial: value.toInt());
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 拡張ヒントまでの時間
                  _buildSliderSetting(
                    label: '拡張ヒントまでの時間',
                    value: settings.extendedHintDelaySeconds.toDouble(),
                    min: 3,
                    max: 15,
                    unit: '秒',
                    onChanged: (value) {
                      notifier.updateDelaySeconds(extended: value.toInt());
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // 重要単語ヒントまでの時間
                  _buildSliderSetting(
                    label: '重要単語ヒントまでの時間',
                    value: settings.keywordsHintDelaySeconds.toDouble(),
                    min: 5,
                    max: 20,
                    unit: '秒',
                    onChanged: (value) {
                      notifier.updateDelaySeconds(keywords: value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // ヒント表示設定
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ヒント表示',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 透明度設定
                  _buildSliderSetting(
                    label: 'ヒントの透明度',
                    value: settings.hintOpacity,
                    min: 0.1,
                    max: 1.0,
                    unit: '',
                    onChanged: (value) {
                      notifier.updateOpacity(value);
                    },
                    formatValue: (value) => '${(value * 100).toInt()}%',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // フィードバック設定
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'フィードバック',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // バイブレーション
                  SwitchListTile(
                    title: const Text('バイブレーション'),
                    subtitle: const Text('ヒント表示時にバイブレーション'),
                    value: settings.hapticFeedbackEnabled,
                    onChanged: (_) {
                      notifier.toggleHapticFeedback();
                    },
                  ),
                  
                  // 視覚的フィードバック
                  SwitchListTile(
                    title: const Text('視覚的フィードバック'),
                    subtitle: const Text('ヒント表示時に画面が光る'),
                    value: settings.visualFeedbackEnabled,
                    onChanged: (_) {
                      notifier.toggleVisualFeedback();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
    String Function(double)? formatValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              formatValue != null
                  ? formatValue(value)
                  : '${value.toInt()}$unit',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: formatValue != null
              ? formatValue(value)
              : '${value.toInt()}$unit',
          onChanged: onChanged,
        ),
      ],
    );
  }
}
