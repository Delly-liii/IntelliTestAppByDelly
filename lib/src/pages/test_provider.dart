import 'package:flutter/foundation.dart';
import 'dart:math';
import 'test_model.dart';
import 'question_model.dart';

class TestProvider extends ChangeNotifier {
  final List<TestModel> _tests = [];

  List<TestModel> get tests => List.unmodifiable(_tests);

  /// ✅ Add a new test and generate a unique ID
  String addTest(TestModel test) {
    final newId =
        'T-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

    final newTest = test.copyWith(id: newId); // Properly pass new ID
    _tests.add(newTest);
    notifyListeners();
    return newId;
  }

  /// ✅ Get test by ID
  TestModel? getTestById(String id) {
    try {
      return _tests.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// ✅ Shortcut for compatibility with editor
  TestModel? byId(String testId) => getTestById(testId);

  /// ✅ Update an existing test safely
  void updateTest(TestModel updated) {
    final index = _tests.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tests[index] = updated.copyWith(createdAt: DateTime.now());
      notifyListeners();
    }
  }

  /// ✅ Add question to a test
  void addQuestion(String testId, QuestionModel question) {
    final test = getTestById(testId);
    if (test == null) return;
    test.questions.add(question);
    updateTest(test);
  }

  /// ✅ Update a specific question inside a test
  void updateQuestion(String testId, QuestionModel updatedQ) {
    final test = getTestById(testId);
    if (test == null) return;

    final i = test.questions.indexWhere((q) => q.id == updatedQ.id);
    if (i != -1) {
      test.questions[i] = updatedQ;
      updateTest(test);
    }
  }

  /// ✅ Delete a question from a test
  void deleteQuestion(String testId, String questionId) {
    final test = getTestById(testId);
    if (test == null) return;
    test.questions.removeWhere((q) => q.id == questionId);
    updateTest(test);
  }

  /// ✅ Publish a test
  void publishTest(String id) {
    final test = getTestById(id);
    if (test == null) return;

    final updated = test.copyWith(
      status: 'Published',
      //publishedAt: DateTime.now().toIso8601String(),
      createdAt: DateTime.now(),
    );

    updateTest(updated);
  }

  /// ✅ Reorder questions within a test
  void reorderQuestions(String id, int oldIndex, int newIndex) {
    final test = getTestById(id);
    if (test == null) return;

    if (newIndex > oldIndex) newIndex--;
    final q = test.questions.removeAt(oldIndex);
    test.questions.insert(newIndex, q);
    updateTest(test);
  }

  /// ✅ Remove test from list
  void removeTest(String id) {
    _tests.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  /// ✅ Clear all tests (for debugging / reset)
  void clearAll() {
    _tests.clear();
    notifyListeners();
  }
}
