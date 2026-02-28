import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 今日の会話ターン数プロバイダ
/// analytics_events の conversation_turn_completed を集計
final todayConversationTurnsProvider = FutureProvider<int>((ref) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return 0;

  try {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final response = await Supabase.instance.client
        .from('analytics_events')
        .select('id')
        .eq('user_id', userId)
        .eq('event_type', 'conversation_turn_completed')
        .gte('created_at', startOfDay.toIso8601String())
        .lte('created_at', now.toIso8601String());

    return (response as List).length;
  } catch (_) {
    return 0;
  }
});

/// 会話の日次目標（ターン数）
const int dailyConversationGoalTurns = 6;
