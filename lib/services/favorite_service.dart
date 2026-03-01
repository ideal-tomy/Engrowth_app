import 'package:supabase_flutter/supabase_flutter.dart';

/// お気に入り対象の型
enum FavoriteTargetType {
  word,
  sentence,
  conversation,
  story,
  pattern,
}

extension FavoriteTargetTypeX on FavoriteTargetType {
  String get value => name;
}

FavoriteTargetType? favoriteTargetTypeFromString(String s) {
  for (final v in FavoriteTargetType.values) {
    if (v.name == s) return v;
  }
  return null;
}

/// お気に入り1件のモデル
class UserFavorite {
  final String id;
  final String userId;
  final String targetType;
  final String targetId;
  final DateTime createdAt;

  UserFavorite({
    required this.id,
    required this.userId,
    required this.targetType,
    required this.targetId,
    required this.createdAt,
  });

  factory UserFavorite.fromJson(Map<String, dynamic> json) {
    return UserFavorite(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      targetType: json['target_type'] as String,
      targetId: json['target_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  FavoriteTargetType? get typeEnum => favoriteTargetTypeFromString(targetType);
}

/// お気に入りサービス
class FavoriteService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'user_favorites';

  /// お気に入りに追加
  Future<void> add({
    required String userId,
    required String targetType,
    required String targetId,
  }) async {
    await _client.from(_table).upsert({
      'user_id': userId,
      'target_type': targetType,
      'target_id': targetId,
    }, onConflict: 'user_id,target_type,target_id');
  }

  /// お気に入りから削除
  Future<void> remove({
    required String userId,
    required String targetType,
    required String targetId,
  }) async {
    await _client
        .from(_table)
        .delete()
        .eq('user_id', userId)
        .eq('target_type', targetType)
        .eq('target_id', targetId);
  }

  /// お気に入りかどうか
  Future<bool> isFavorite({
    required String userId,
    required String targetType,
    required String targetId,
  }) async {
    final res = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('target_type', targetType)
        .eq('target_id', targetId)
        .maybeSingle();
    return res != null;
  }

  /// ユーザーのお気に入り一覧（追加日時の新しい順）
  Future<List<UserFavorite>> getFavorites({
    required String userId,
    String? targetType,
    int? limit,
  }) async {
    var query = _client.from(_table).select().eq('user_id', userId);
    if (targetType != null && targetType.isNotEmpty) {
      query = query.eq('target_type', targetType);
    }
    final ordered = query.order('created_at', ascending: false);
    final res = limit != null
        ? await ordered.limit(limit)
        : await ordered;
    return (res as List)
        .map((e) => UserFavorite.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
