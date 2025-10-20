// ignore_for_file: depend_on_referenced_packages

import 'package:uuid/uuid.dart';

class QuestionModel {
  final String id;
  final String type; // e.g. "MCQ", "True/False", "Short Answer", "Essay"
  final String questionText;
  final List<String> options;
  final int? correctOptionIndex;
  final String difficulty;
  final double marks;
  final String? answer;
  final DateTime createdAt;
  final DateTime updatedAt;

  QuestionModel({
    String? id,
    required this.type,
    required this.questionText,
    required this.options,
    this.correctOptionIndex,
    this.answer,
    this.difficulty = 'Medium',
    this.marks = 1.0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// ✅ Safer copyWith with all optional fields
  QuestionModel copyWith({
    String? id,
    String? type,
    String? questionText,
    List<String>? options,
    int? correctOptionIndex,
    String? difficulty,
    double? marks,
    String? answer,
    DateTime? createdAt,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      questionText: questionText ?? this.questionText,
      options: options ?? List.from(this.options),
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      difficulty: difficulty ?? this.difficulty,
      marks: marks ?? this.marks,
      answer: answer ?? this.answer,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// ✅ Validation helper
  bool validate() {
    if (questionText.trim().isEmpty) return false;
    if (type == 'MCQ' && (options.length < 2 || correctOptionIndex == null)) {
      return false;
    }
    return true;
  }

  /// ✅ JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'questionText': questionText,
      'options': options,
      'correctOptionIndex': correctOptionIndex,
      'difficulty': difficulty,
      'marks': marks,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// ✅ JSON deserialization
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      type: json['type'],
      questionText: json['questionText'],
      options: List<String>.from(json['options'] ?? []),
      correctOptionIndex: json['correctOptionIndex'],
      difficulty: json['difficulty'] ?? 'Medium',
      marks: (json['marks'] ?? 1.0).toDouble(),
      answer: json['answer'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  static fromMap(q) {}
}
