import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/learning_session_mode.dart';

/// 現在の学習セッションモード（Quick30 / Focus3 / Unlimited）
final sessionModeProvider = StateProvider<LearningSessionMode?>((ref) => null);
