class TestModel {
  String? id;
  String title;
  String type; // e.g., ML, Manual, Mixed
  String status; // e.g., Draft, Published
  DateTime createdAt;
  DateTime? publishedAt;

  // --- ML or content metadata fields ---
  String? book;
  String? chapter;
  String? topic;
  List<String> files;

  // --- Question settings ---
  List<String> questionTypes;
  int? duration; // in minutes
  int? totalQuestions;
  Map<String, int>? questionBreakdown;
  List<dynamic> questions; // or List<QuestionModel> if imported

  // --- Additional info ---
  Map<String, dynamic>? metadata;

  TestModel({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.createdAt,
    this.publishedAt,
    this.book,
    this.chapter,
    this.topic,
    this.files = const [],
    this.questionTypes = const [],
    this.duration,
    this.totalQuestions,
    this.questionBreakdown,
    this.questions = const [],
    this.metadata,
  });

  // ✅ copyWith (for immutability)
  TestModel copyWith({
    String? id,
    String? title,
    String? type,
    String? status,
    DateTime? createdAt,
    DateTime? publishedAt,
    String? book,
    String? chapter,
    String? topic,
    List<String>? files,
    List<String>? questionTypes,
    int? duration,
    int? totalQuestions,
    Map<String, int>? questionBreakdown,
    List<dynamic>? questions,
    Map<String, dynamic>? metadata,
  }) {
    return TestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      book: book ?? this.book,
      chapter: chapter ?? this.chapter,
      topic: topic ?? this.topic,
      files: files ?? this.files,
      questionTypes: questionTypes ?? this.questionTypes,
      duration: duration ?? this.duration,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      questionBreakdown: questionBreakdown ?? this.questionBreakdown,
      questions: questions ?? this.questions,
      metadata: metadata ?? this.metadata,
    );
  }

  // ✅ Serialization
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'publishedAt': publishedAt?.toIso8601String(),
      'book': book,
      'chapter': chapter,
      'topic': topic,
      'files': files,
      'questionTypes': questionTypes,
      'duration': duration,
      'totalQuestions': totalQuestions,
      'questionBreakdown': questionBreakdown,
      'questions': questions,
      'metadata': metadata,
    };
  }

  factory TestModel.fromMap(Map<String, dynamic> map) {
    return TestModel(
      id: map['id'],
      title: map['title'] ?? '',
      type: map['type'] ?? 'Manual',
      status: map['status'] ?? 'Draft',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      publishedAt: map['publishedAt'] != null
          ? DateTime.tryParse(map['publishedAt'])
          : null,
      book: map['book'],
      chapter: map['chapter'],
      topic: map['topic'],
      files: List<String>.from(map['files'] ?? []),
      questionTypes: List<String>.from(map['questionTypes'] ?? []),
      duration: map['duration'],
      totalQuestions: map['totalQuestions'],
      questionBreakdown:
          (map['questionBreakdown'] as Map?)?.cast<String, int>(),
      questions: List.from(map['questions'] ?? []),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}
