import 'package:flutter/material.dart';

/// コンテンツロード中のSkeleton表示
/// レイアウト近似で先出しし、AnimatedSwitcherで本体へ差し替える
class ContentSkeleton extends StatelessWidget {
  const ContentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = colorScheme.surface;

    return ShimmerBox(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: _ShimmerPlaceholder(baseColor: baseColor),
    );
  }
}

/// Story一覧のセクション・カードレイアウトに近似したSkeleton
class StoryListSkeleton extends StatelessWidget {
  const StoryListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;
    final highlightColor = colorScheme.surface;

    return ListView(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      children: [
        // セクション1
        _SectionSkeleton(baseColor: baseColor, highlightColor: highlightColor),
        const SizedBox(height: 16),
        // セクション2
        _SectionSkeleton(baseColor: baseColor, highlightColor: highlightColor),
        const SizedBox(height: 16),
        // セクション3
        _SectionSkeleton(baseColor: baseColor, highlightColor: highlightColor),
      ],
    );
  }
}

class _SectionSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const _SectionSkeleton({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                height: 18,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 170,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 4,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _CardSkeleton(
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CardSkeleton extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;

  const _CardSkeleton({
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: baseColor),
      ),
    );
  }
}

/// Story詳細の冒頭コンテンツに近似したSkeleton
class StoryDetailSkeleton extends StatelessWidget {
  const StoryDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // セクションタイトル
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // メインカード
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 100,
                height: 16,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ],
      ),
    );
  }
}

/// シンプルなShimmer効果用ラッパー（アニメーションなしで即時表示）
class ShimmerBox extends StatelessWidget {
  final Color baseColor;
  final Color highlightColor;
  final Widget child;

  const ShimmerBox({
    super.key,
    required this.baseColor,
    required this.highlightColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  final Color baseColor;

  const _ShimmerPlaceholder({required this.baseColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 120,
            height: 12,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
