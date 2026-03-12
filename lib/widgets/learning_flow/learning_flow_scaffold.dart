import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/learning_flow_controller.dart';
import '../../models/learning_step.dart';

/// 単一の Scaffold 上で学習ステップを進行させるための共通ラッパー。
class LearningFlowScaffold extends ConsumerStatefulWidget {
  const LearningFlowScaffold({
    super.key,
    required this.steps,
    required this.stepBuilder,
    required this.onCompleted,
    this.appBarTitle,
  });

  final List<LearningStep> steps;
  final Widget Function(
    BuildContext context,
    LearningStep step,
    LearningFlowController controller,
  ) stepBuilder;
  final VoidCallback onCompleted;
  final String? appBarTitle;

  @override
  ConsumerState<LearningFlowScaffold> createState() =>
      _LearningFlowScaffoldState();
}

class _LearningFlowScaffoldState extends ConsumerState<LearningFlowScaffold> {
  late final LearningFlowController _controller;
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _controller = LearningFlowController(widget.steps);
    _subscription = _controller.events.listen((event) async {
      if (!mounted) return;
      if (event is LearningFlowShowBridge) {
        await showBridgePopupIfNeeded(context, _controller, event);
      } else if (event is LearningFlowCompleted) {
        widget.onCompleted();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _controller.currentStep;
    final total = widget.steps.length;
    final index = _controller.state;

    return Scaffold(
      appBar: AppBar(
        title: widget.appBarTitle != null ? Text(widget.appBarTitle!) : null,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: LinearProgressIndicator(
              value: (index + 1) / total,
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: KeyedSubtree(
                key: ValueKey(index),
                child: widget.stepBuilder(context, current, _controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

