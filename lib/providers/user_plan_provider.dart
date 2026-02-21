import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';

/// ユーザープラン: trial=お試し/検討期, standard=通常, coaching=伴走契約
enum UserPlan {
  trial,
  standard,
  coaching,
}

/// ユーザーの契約プラン
/// 匿名時は trial、ログイン後は DB や app_metadata で判定（将来実装）
final userPlanProvider = Provider<UserPlan>((ref) {
  final stage = ref.watch(authStageProvider);
  switch (stage) {
    case AuthStage.anonymous:
      return UserPlan.trial;
    case AuthStage.signedIn:
      return UserPlan.trial; // 現時点では全員 trial
    case AuthStage.coaching:
      return UserPlan.coaching;
  }
});
