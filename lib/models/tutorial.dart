/// チュートリアル専用モデル（事前生成音声で低遅延体験）

class Tutorial {
  final String id;
  final String title;
  final String? descriptionJa;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Tutorial({
    required this.id,
    required this.title,
    this.descriptionJa,
    this.displayOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Tutorial.fromJson(Map<String, dynamic> json) {
    return Tutorial(
      id: json['id'] as String,
      title: json['title'] as String,
      descriptionJa: json['description_ja'] as String?,
      displayOrder: json['display_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class TutorialStep {
  final String id;
  final String tutorialId;
  final int stepOrder;
  final String promptTextEn;
  final String? promptTextJa;
  final String? promptAudioUrl;
  final DateTime createdAt;

  const TutorialStep({
    required this.id,
    required this.tutorialId,
    required this.stepOrder,
    required this.promptTextEn,
    this.promptTextJa,
    this.promptAudioUrl,
    required this.createdAt,
  });

  factory TutorialStep.fromJson(Map<String, dynamic> json) {
    return TutorialStep(
      id: json['id'] as String,
      tutorialId: json['tutorial_id'] as String,
      stepOrder: json['step_order'] as int? ?? 0,
      promptTextEn: json['prompt_text_en'] as String,
      promptTextJa: json['prompt_text_ja'] as String?,
      promptAudioUrl: json['prompt_audio_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class TutorialStepResponse {
  final String id;
  final String tutorialStepId;
  final String intentBucket;
  final String responseTextEn;
  final String? responseTextJa;
  final String? responseAudioUrl;
  final String? nextStepId;
  final DateTime createdAt;

  const TutorialStepResponse({
    required this.id,
    required this.tutorialStepId,
    required this.intentBucket,
    required this.responseTextEn,
    this.responseTextJa,
    this.responseAudioUrl,
    this.nextStepId,
    required this.createdAt,
  });

  factory TutorialStepResponse.fromJson(Map<String, dynamic> json) {
    return TutorialStepResponse(
      id: json['id'] as String,
      tutorialStepId: json['tutorial_step_id'] as String,
      intentBucket: json['intent_bucket'] as String,
      responseTextEn: json['response_text_en'] as String,
      responseTextJa: json['response_text_ja'] as String?,
      responseAudioUrl: json['response_audio_url'] as String?,
      nextStepId: json['next_step_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// 1セッション分のチュートリアル（ステップと返答を紐付けて保持）
class TutorialSession {
  final Tutorial tutorial;
  final List<TutorialStep> steps;
  final Map<String, List<TutorialStepResponse>> responsesByStepId;

  const TutorialSession({
    required this.tutorial,
    required this.steps,
    required this.responsesByStepId,
  });

  TutorialStep? getStepById(String id) {
    for (final s in steps) {
      if (s.id == id) return s;
    }
    return null;
  }

  List<TutorialStepResponse> getResponsesForStep(String stepId) =>
      responsesByStepId[stepId] ?? [];

  TutorialStepResponse? getResponseForIntent(String stepId, String intent) {
    for (final r in getResponsesForStep(stepId)) {
      if (r.intentBucket == intent) return r;
    }
    return null;
  }
}
