import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'test_model.dart';
import 'test_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';

class EditTestPage extends StatefulWidget {
  final String testId;

  const EditTestPage({super.key, required this.testId});

  @override
  State<EditTestPage> createState() => _EditTestPageState();
}

class _EditTestPageState extends State<EditTestPage> {
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final provider = context.watch<TestProvider>();
    final test = provider.byId(widget.testId);

    if (test == null) {
      return const Scaffold(body: Center(child: Text('Test not found')));
    }

    return Scaffold(
      appBar: isWide
          ? null
          : const PreferredSize(
              preferredSize: Size.fromHeight(64), child: TopBar()),
      drawer: isWide ? null : const SideBar(),
      body: SafeArea(
        child: Row(
          children: [
            if (isWide) const SideBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Edit Test: ${test.title}',
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final q = await _showAddQuestionDialog(context);
                            if (q != null) {
                              provider.addQuestion(test.id, q);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Question'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            provider.updateTest(
                                test.copyWith(updatedAt: DateTime.now()));
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Saved')));
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save Changes'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ReorderableListView.builder(
                        itemCount: test.questions.length,
                        onReorder: (oldIndex, newIndex) => provider
                            .reorderQuestions(test.id, oldIndex, newIndex),
                        itemBuilder: (ctx, index) {
                          final q = test.questions[index];
                          return Card(
                            key: ValueKey(q.id),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: _QuestionEditor(
                                question: q,
                                onChanged: (updated) =>
                                    provider.updateQuestion(test.id, updated),
                                onDelete: () =>
                                    provider.deleteQuestion(test.id, q.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Question?> _showAddQuestionDialog(BuildContext context) async {
    QuestionType selected = QuestionType.multipleChoice;
    return showDialog<Question>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Question'),
          content: DropdownButton<QuestionType>(
            isExpanded: true,
            value: selected,
            items: QuestionType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.name)))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              selected = v;
              setState(() {});
              Navigator.of(ctx).pop(_newQuestion(selected));
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(_newQuestion(selected)),
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  Question _newQuestion(QuestionType t) {
    switch (t) {
      case QuestionType.multipleChoice:
        return Question(
          id: generateId('new_mc'),
          type: t,
          prompt: 'New multiple choice question',
          options: ['Option A', 'Option B', 'Option C', 'Option D'],
          correctOptionIndexes: {0},
          points: 1,
        );
      case QuestionType.trueFalse:
        return Question(
          id: generateId('new_tf'),
          type: t,
          prompt: 'New true or false question',
          correctBool: true,
          points: 1,
        );
      case QuestionType.shortAnswer:
        return Question(
          id: generateId('new_short'),
          type: t,
          prompt: 'New short answer question',
          acceptableAnswers: ['Expected answer'],
          points: 2,
        );
      case QuestionType.essay:
        return Question(
          id: generateId('new_essay'),
          type: t,
          prompt: 'New essay question',
          rubric:
              'Thesis (2), Evidence (3), Organization (2), Insight (2), Mechanics (1)',
          points: 10,
        );
    }
  }
}

/// Minimal inline question editor
class _QuestionEditor extends StatefulWidget {
  final Question question;
  final void Function(Question) onChanged;
  final VoidCallback onDelete;

  const _QuestionEditor(
      {required this.question,
      required this.onChanged,
      required this.onDelete});

  @override
  State<_QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<_QuestionEditor> {
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController(text: widget.question.prompt);
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _promptController,
          decoration: const InputDecoration(
              labelText: 'Question', border: OutlineInputBorder()),
          onChanged: (val) {
            final updated = widget.question.copyWith(prompt: val);
            widget.onChanged(updated);
          },
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: widget.onDelete,
          ),
        )
      ],
    );
  }
}
