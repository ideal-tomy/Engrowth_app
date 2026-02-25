class Word {
  final String id;
  final int wordNumber;
  final String word;
  final String meaning;
  final String? partOfSpeech;
  final String? wordGroup;
  final DateTime createdAt;

  Word({
    required this.id,
    required this.wordNumber,
    required this.word,
    required this.meaning,
    this.partOfSpeech,
    this.wordGroup,
    required this.createdAt,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    // word_number が JSON で number として来る場合に備える
    final rawNumber = json['word_number'];
    final wordNumber = rawNumber is int
        ? rawNumber
        : (rawNumber is num ? rawNumber.toInt() : 0);
    final rawCreated = json['created_at'];
    final createdAt = rawCreated != null
        ? DateTime.tryParse(rawCreated.toString()) ?? DateTime.now()
        : DateTime.now();
    return Word(
      id: json['id'] as String,
      wordNumber: wordNumber,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      partOfSpeech: json['part_of_speech'] as String?,
      wordGroup: json['word_group'] as String?,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word_number': wordNumber,
      'word': word,
      'meaning': meaning,
      'part_of_speech': partOfSpeech,
      'word_group': wordGroup,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
