import 'dart:async';

import 'package:flutter/material.dart';

import '../../theme/engrowth_theme.dart';

/// チュートリアル用の1ステップ定義（登場→滞在→演出→余白→退場）
class TutorialSequenceStep {
  TutorialSequenceStep({
    this.onEnter,
    this.onStay,
    this.onPerform,
    this.onPause,
    this.onExit,
    this.enterDuration = const Duration(milliseconds: 1000),
    this.stayDuration = const Duration(milliseconds: 2000),
    this.performDuration = Duration.zero,
    this.pauseDuration = const Duration(milliseconds: 1000),
    this.exitDuration = const Duration(milliseconds: 1000),
  });

  final FutureOr<void> Function()? onEnter;
  final FutureOr<void> Function()? onStay;
  final FutureOr<void> Function()? onPerform;
  final FutureOr<void> Function()? onPause;
  final FutureOr<void> Function()? onExit;

  /// 登場フェーズの長さ（デフォルト1.0s）
  final Duration enterDuration;

  /// コンテンツ滞在時間（デフォルト2.0s）
  final Duration stayDuration;

  /// 任意の演出時間（必要な場合のみ使用）
  final Duration performDuration;

  /// 余白（余韻）の長さ（デフォルト1.0s）
  final Duration pauseDuration;

  /// 退場フェーズの長さ（デフォルト1.0s）
  final Duration exitDuration;
}

/// 複数ステップを「登場→滞在→演出→余白→退場」の順に進めるシーケンサー。
///
/// - ページ遷移の長さは `EngrowthRouteTokens.tutorialCrossfadeDuration` を基準とする。
/// - 画面内のふわっと表示は `EngrowthElementTokens.switchDuration` を基準とする。
/// - オンボーディング固有の 300ms / 600ms / 800ms などは、呼び出し側で Duration を渡して使用する。
class TutorialSequencer {
  TutorialSequencer({
    required TickerProvider vsync,
    required this.onProgress,
  }) : _controller = AnimationController(
          vsync: vsync,
          duration: EngrowthElementTokens.switchDuration,
        ) {
    _curve = CurvedAnimation(
      parent: _controller,
      curve: EngrowthElementTokens.switchCurveIn,
    );
  }

  final void Function(double value) onProgress;

  late final AnimationController _controller;
  late final Animation<double> _curve;

  bool _disposed = false;
  bool _running = false;

  Animation<double> get animation => _curve;

  void dispose() {
    _disposed = true;
    _controller.dispose();
  }

  /// 単一ステップを順番に実行する。
  ///
  /// 呼び出し側でキャンセルしたい場合は、別の `runStep` を呼ぶ（内部で前の実行は自然に終了する）。
  Future<void> runStep(TutorialSequenceStep step) async {
    if (_disposed) return;
    _running = true;

    // enter
    await _runPhase(
      duration: step.enterDuration,
      callback: step.onEnter,
    );

    // stay
    await _runPhase(
      duration: step.stayDuration,
      callback: step.onStay,
    );

    // perform（任意）
    if (step.performDuration > Duration.zero || step.onPerform != null) {
      await _runPhase(
        duration: step.performDuration,
        callback: step.onPerform,
      );
    }

    // pause（余韻）
    await _runPhase(
      duration: step.pauseDuration,
      callback: step.onPause,
    );

    // exit
    await _runPhase(
      duration: step.exitDuration,
      callback: step.onExit,
    );

    _running = false;
  }

  Future<void> _runPhase({
    required Duration duration,
    FutureOr<void> Function()? callback,
  }) async {
    if (_disposed) return;

    // コールバックは先に実行し、その後に時間経過でアニメーション値を進める。
    if (callback != null) {
      await callback();
      if (_disposed) return;
    }

    if (duration <= Duration.zero) return;

    // EngrowthElementTokens を基準にしつつ、phase duration に合わせてコントローラを進める。
    final factor = duration.inMilliseconds /
        EngrowthElementTokens.switchDuration.inMilliseconds;

    _controller.duration = EngrowthElementTokens.switchDuration * factor;
    _controller.reset();

    await _controller.forward();
    if (_disposed) return;

    onProgress(_curve.value);
  }

  bool get isRunning => _running;
}

