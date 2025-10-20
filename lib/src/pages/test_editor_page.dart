import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intellitest_app/src/pages/question_model.dart';
import 'package:intellitest_app/src/pages/test_model.dart';
import 'package:intellitest_app/src/pages/test_provider.dart';

class TestEditorPage extends StatefulWidget {
  final String testId;
  const TestEditorPage({super.key, required this.testId});

  @override
  State<TestEditorPage> createState() => _TestEditorPageState();
}

class _TestEditorPageState extends State<TestEditorPage> {
  late TestModel test;
  bool isLoading = true;
  bool singleEditMode = false;
  int? selectedIndex;

  final TextEditingController questionCtrl = TextEditingController();
  final TextEditingController optionsCtrl = TextEditingController();
  final TextEditingController correctCtrl = TextEditingController();
  final TextEditingController marksCtrl = TextEditingController();

  String difficulty = 'Medium';
  String questionType = 'MCQ';

  @override
  void initState() {
    super.initState();
    _loadTest();
  }

  void _loadTest() {
    final provider = Provider.of<TestProvider>(context, listen: false);

    // Try to find the test in provider
    final found = provider.byId(widget.testId);

    if (found != null) {
      setState(() {
        test = found;
        isLoading = false;
      });
    } else {
      // If not found, create a new test with the provided ID
      setState(() {
        test = TestModel(
          id: widget.testId,
          title: "Untitled Test",
          type: "Manual",
          status: "Draft",
          questions: [],
          createdAt: DateTime.now(),
        );
        isLoading = false;
      });

      // Add this test to provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        provider.addTest(test);
      });
    }
  }

  void _autosave() {
    final provider = Provider.of<TestProvider>(context, listen: false);
    provider.updateTest(test);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Auto-saved'),
        duration: Duration(milliseconds: 600),
      ),
    );
  }

  void _addQuestion() {
    setState(() {
      test.questions.add(
        QuestionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'MCQ',
          questionText: 'New Question ${test.questions.length + 1}',
          options: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
          correctOptionIndex: 0,
          marks: 1.0,
          difficulty: 'Medium',
        ),
      );
    });
    _autosave();
  }

  void _deleteQuestion(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => test.questions.removeAt(index));
              _autosave();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Question deleted')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _duplicateQuestion(int index) {
    final original = test.questions[index];
    setState(() {
      final copy = QuestionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: original.type,
        questionText: '${original.questionText} (Copy)',
        options: List.from(original.options),
        correctOptionIndex: original.correctOptionIndex,
        marks: original.marks,
        difficulty: original.difficulty,
      );
      test.questions.insert(index + 1, copy);
    });
    _autosave();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question duplicated')),
    );
  }

  void _reorderQuestions(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final q = test.questions.removeAt(oldIndex);
      test.questions.insert(newIndex, q);
    });
    _autosave();
  }

  void _editQuestion(int index) {
    setState(() {
      selectedIndex = index;
      singleEditMode = true;
      final q = test.questions[index];
      questionCtrl.text = q.questionText;
      optionsCtrl.text = q.options.join(', ');
      correctCtrl.text =
          q.correctOptionIndex != null ? q.options[q.correctOptionIndex!] : '';
      marksCtrl.text = q.marks.toString();
      difficulty = q.difficulty;
      questionType = q.type;
    });
  }

  void _saveQuestion() {
    if (selectedIndex == null) return;

    final opts = optionsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final correctIndex = opts.indexWhere(
        (o) => o.toLowerCase() == correctCtrl.text.trim().toLowerCase());

    setState(() {
      test.questions[selectedIndex!] = QuestionModel(
        id: test.questions[selectedIndex!].id,
        type: questionType,
        questionText: questionCtrl.text.trim(),
        options: opts,
        correctOptionIndex: correctIndex >= 0 ? correctIndex : null,
        difficulty: difficulty,
        marks: double.tryParse(marksCtrl.text) ?? 1.0,
      );
      singleEditMode = false;
      selectedIndex = null;

      // Clear controllers
      questionCtrl.clear();
      optionsCtrl.clear();
      correctCtrl.clear();
      marksCtrl.clear();
    });

    _autosave();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question saved successfully')),
    );
  }

  void _cancelEdit() {
    setState(() {
      singleEditMode = false;
      selectedIndex = null;
      questionCtrl.clear();
      optionsCtrl.clear();
      correctCtrl.clear();
      marksCtrl.clear();
    });
  }

  Widget _buildSummarySidebar() {
    final totalQuestions = test.questions.length;
    final totalMarks = test.questions.fold(0.0, (sum, q) => sum + q.marks);
    final difficultyBreakdown = _calculateDifficultyBreakdown();

    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: const Border(left: BorderSide(color: Colors.black12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: TestEditorColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics, color: TestEditorColors.primary),
              ),
              const SizedBox(width: 12),
              const Text('Test Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 20),

          // Test Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(test.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Type: ${test.type}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text('Status: ${test.status}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Stats Cards
          _buildStatCard('Total Questions', '$totalQuestions', Icons.quiz),
          const SizedBox(height: 12),
          _buildStatCard(
              'Total Marks', '${totalMarks.toStringAsFixed(1)}', Icons.grade),
          const SizedBox(height: 12),
          _buildStatCard('Question Types', '${_getQuestionTypes().length}',
              Icons.category),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Difficulty Breakdown
          const Text('Difficulty Breakdown',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...difficultyBreakdown.entries
              .map((entry) =>
                  _buildDifficultyRow(entry.key, entry.value, totalQuestions))
              .toList(),

          const Spacer(),

          // Action Buttons
          Column(
            children: [
              ElevatedButton.icon(
                onPressed: _autosave,
                icon: const Icon(Icons.save, size: 18),
                label: const Text('Save All Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TestEditorColors.primary,
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  // Navigate back to test bank
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Back to Tests'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: TestEditorColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: TestEditorColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyRow(String difficulty, int count, int total) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    Color getColor(String diff) {
      switch (diff) {
        case 'Easy':
          return TestEditorColors.success;
        case 'Medium':
          return TestEditorColors.warning;
        case 'Hard':
          return TestEditorColors.error;
        default:
          return TestEditorColors.primary;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: getColor(difficulty),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(difficulty, style: const TextStyle(fontSize: 14)),
          ),
          Text('$count ($percentage%)',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Map<String, int> _calculateDifficultyBreakdown() {
    final breakdown = <String, int>{'Easy': 0, 'Medium': 0, 'Hard': 0};
    for (final q in test.questions) {
      breakdown.update(q.difficulty, (value) => value + 1, ifAbsent: () => 1);
    }
    return breakdown;
  }

  Set _getQuestionTypes() {
    return test.questions.map((q) => q.type).toSet();
  }

  Widget _buildQuestionList() {
    if (test.questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No Questions Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first question to get started',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add First Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: TestEditorColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                'Questions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TestEditorColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${test.questions.length}',
                  style: TextStyle(
                    color: TestEditorColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TestEditorColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Questions List
        Expanded(
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: true),
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: test.questions.length,
              onReorder: _reorderQuestions,
              buildDefaultDragHandles: true,
              itemBuilder: (context, index) {
                final q = test.questions[index];
                return _buildQuestionCard(q, index);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionModel question, int index) {
    return Card(
      key: ValueKey(question.id),
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: selectedIndex == index
                ? TestEditorColors.primary
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: TestEditorColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: TestEditorColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          title: Text(
            question.questionText.isNotEmpty
                ? question.questionText
                : 'Untitled Question',
            style: const TextStyle(fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getTypeColor(question.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      question.type,
                      style: TextStyle(
                        color: _getTypeColor(question.type),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(question.difficulty)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      question.difficulty,
                      style: TextStyle(
                        color: _getDifficultyColor(question.difficulty),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${question.marks} marks',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              if (question.correctOptionIndex != null &&
                  question.correctOptionIndex! < question.options.length)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Answer: ${question.options[question.correctOptionIndex!]}',
                    style: const TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // EDIT BUTTON - Made more prominent
              Container(
                decoration: BoxDecoration(
                  color: TestEditorColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.edit,
                      color: TestEditorColors.primary, size: 20),
                  tooltip: 'Edit Question',
                  onPressed: () => _editQuestion(index),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                tooltip: 'Duplicate',
                onPressed: () => _duplicateQuestion(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.red),
                tooltip: 'Delete',
                onPressed: () => _deleteQuestion(index),
              ),
            ],
          ),
          onTap: () => _editQuestion(index), // Added tap to edit
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'MCQ':
        return TestEditorColors.secondary;
      case 'True/False':
        return TestEditorColors.accent;
      case 'Short Answer':
        return TestEditorColors.warning;
      case 'Essay':
        return TestEditorColors.info;
      default:
        return TestEditorColors.primary;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return TestEditorColors.success;
      case 'Medium':
        return TestEditorColors.warning;
      case 'Hard':
        return TestEditorColors.error;
      default:
        return TestEditorColors.primary;
    }
  }

  Widget _buildQuestionEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _cancelEdit,
                tooltip: 'Back to Questions',
              ),
              const SizedBox(width: 8),
              const Text(
                'Edit Question',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: TestEditorColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Question ${selectedIndex! + 1} of ${test.questions.length}',
                  style: TextStyle(
                    color: TestEditorColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Form
          Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Question Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 20),

                  // Question Type
                  DropdownButtonFormField<String>(
                    value: questionType,
                    decoration: const InputDecoration(
                      labelText: 'Question Type',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: ['MCQ', 'True/False', 'Short Answer', 'Essay']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => questionType = val!),
                  ),
                  const SizedBox(height: 16),

                  // Question Text
                  TextField(
                    controller: questionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Question Text *',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Options (only for MCQ)
                  if (questionType == 'MCQ' ||
                      questionType == 'True/False') ...[
                    TextField(
                      controller: optionsCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Options (comma separated) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.list),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: correctCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.check_circle),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Marks
                  TextField(
                    controller: marksCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Marks',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.grade),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Difficulty
                  DropdownButtonFormField<String>(
                    value: difficulty,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.speed),
                    ),
                    items: ['Easy', 'Medium', 'Hard']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (val) => setState(() => difficulty = val!),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _cancelEdit,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 48),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _saveQuestion,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TestEditorColors.primary,
                  minimumSize: const Size(160, 48),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading Test Editor...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Editing: ${test.title}'),
        backgroundColor: TestEditorColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Question',
            onPressed: _addQuestion,
          ),
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save All',
            onPressed: _autosave,
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: singleEditMode
                  ? _buildQuestionEditor()
                  : _buildQuestionList(),
            ),
            _buildSummarySidebar(),
          ],
        ),
      ),
    );
  }
}

class TestEditorColors {
  static const primary = Color(0xFF7E57C2);
  static const secondary = Color(0xFF26A69A);
  static const accent = Color(0xFFFFA726);
  static const success = Color(0xFF66BB6A);
  static const warning = Color(0xFFFFB74D);
  static const error = Color(0xFFEF5350);
  static const info = Color(0xFF42A5F5);
}
