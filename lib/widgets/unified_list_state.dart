import 'package:flutter/material.dart';
import '../theme/engrowth_theme.dart';

/// 単語/センテンス一覧の空・読込・エラー状態を統一
/// CTA（学習を始める、フィルタ解除）を明示
class UnifiedListState extends StatelessWidget {
  final UnifiedListStateType type;
  final String message;
  final String? subtitle;
  final Widget? cta;
  final VoidCallback? onRetry;

  const UnifiedListState({
    super.key,
    required this.type,
    required this.message,
    this.subtitle,
    this.cta,
    this.onRetry,
  });

  static Widget empty({
    required String message,
    String? subtitle,
    Widget? cta,
  }) =>
      UnifiedListState(
        type: UnifiedListStateType.empty,
        message: message,
        subtitle: subtitle,
        cta: cta,
      );

  static Widget loading() => const UnifiedListState(
        type: UnifiedListStateType.loading,
        message: '読み込み中...',
      );

  static Widget error({
    required String message,
    Object? error,
    VoidCallback? onRetry,
  }) =>
      UnifiedListState(
        type: UnifiedListStateType.error,
        message: message,
        subtitle: error != null ? error.toString() : null,
        onRetry: onRetry,
      );

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case UnifiedListStateType.loading:
        return _buildLoading();
      case UnifiedListStateType.error:
        return _buildError(context);
      case UnifiedListStateType.empty:
        return _buildEmpty(context);
    }
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: EngrowthColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: EngrowthColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: EngrowthColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 12),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (cta != null) ...[
              const SizedBox(height: 24),
              cta!,
            ],
          ],
        ),
      ),
    );
  }
}

enum UnifiedListStateType { empty, loading, error }
