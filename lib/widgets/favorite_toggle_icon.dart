import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/favorite_provider.dart';

/// お気に入りトグル用アイコンボタン
/// ログイン済みユーザーのみ表示。未ログイン時は何も表示しない。
class FavoriteToggleIcon extends ConsumerWidget {
  final String targetType;
  final String targetId;
  final double size;
  final Color? color;

  const FavoriteToggleIcon({
    super.key,
    required this.targetType,
    required this.targetId,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    if (userId == null) return const SizedBox.shrink();

    final isFavAsync = ref.watch(
      isFavoriteProvider((type: targetType, id: targetId)),
    );

    return isFavAsync.when(
      data: (isFav) => IconButton(
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          size: size,
          color: isFav
              ? (color ?? Theme.of(context).colorScheme.error)
              : (color ?? Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        onPressed: () {
          HapticFeedback.selectionClick();
          ref.read(favoriteToggleProvider.notifier).toggle(
                targetType: targetType,
                targetId: targetId,
              );
        },
        tooltip: isFav ? 'お気に入りから削除' : 'お気に入りに追加',
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(minWidth: size + 8, minHeight: size + 8),
        style: IconButton.styleFrom(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      loading: () => SizedBox(
        width: size + 8,
        height: size + 8,
        child: Center(
          child: SizedBox(
            width: size * 0.6,
            height: size * 0.6,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
