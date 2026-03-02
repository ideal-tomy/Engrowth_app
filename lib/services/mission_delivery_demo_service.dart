import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/coach_mission.dart';

/// チャネル種別
enum DeliveryChannel { inApp, line, lineWorks }

/// 配信状態（デモ用）
enum DeliveryState { pending, sent, failed, skipped }

/// チャネル別配信状態（デモ用、メモリ上のみ）
class ChannelDeliveryStatus {
  final DeliveryChannel channel;
  final DeliveryState state;
  final String? mockMessageId;

  ChannelDeliveryStatus({
    required this.channel,
    this.state = DeliveryState.pending,
    this.mockMessageId,
  });

  String get channelLabel {
    switch (channel) {
      case DeliveryChannel.inApp:
        return 'in_app';
      case DeliveryChannel.line:
        return 'LINE';
      case DeliveryChannel.lineWorks:
        return 'LINE WORKS';
    }
  }

  String get stateLabel {
    switch (state) {
      case DeliveryState.pending:
        return '待機中';
      case DeliveryState.sent:
        return '送信済';
      case DeliveryState.failed:
        return '失敗';
      case DeliveryState.skipped:
        return 'スキップ';
    }
  }
}

/// 課題＋配信状態（デモ用）
class MissionDeliveryDemo {
  final CoachMission mission;
  final List<ChannelDeliveryStatus> channelStatuses;

  MissionDeliveryDemo({
    required this.mission,
    required this.channelStatuses,
  });
}

/// 課題配信デモサービス
/// LINE / LINE WORKS 連携時の動きを擬似表示（実API接続なし）
class MissionDeliveryDemoService {
  final SupabaseClient _client = Supabase.instance.client;

  /// 直近の課題一覧を取得し、デモ用チャネル状態を付与
  Future<List<MissionDeliveryDemo>> getRecentMissionsWithDemoStatus({int limit = 10}) async {
    try {
      final res = await _client
          .from('coach_missions')
          .select()
          .order('created_at', ascending: false)
          .limit(limit);

      final missions = (res as List)
          .map((e) => CoachMission.fromJson(e as Map<String, dynamic>))
          .toList();

      return missions.map((m) {
        return MissionDeliveryDemo(
          mission: m,
          channelStatuses: [
            ChannelDeliveryStatus(channel: DeliveryChannel.inApp, state: DeliveryState.sent),
            ChannelDeliveryStatus(channel: DeliveryChannel.line, state: DeliveryState.pending),
            ChannelDeliveryStatus(channel: DeliveryChannel.lineWorks, state: DeliveryState.pending),
          ],
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// デモ: 指定チャネルを sent に遷移（擬似）
  static ChannelDeliveryStatus simulateSend(ChannelDeliveryStatus current) {
    if (current.state == DeliveryState.pending) {
      return ChannelDeliveryStatus(
        channel: current.channel,
        state: DeliveryState.sent,
        mockMessageId: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
    return current;
  }
}
