import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';
import 'test_model.dart';
import 'test_provider.dart';
import 'test_editor_page.dart';

class CreateTestPage extends StatefulWidget {
  const CreateTestPage({super.key});

  @override
  State<CreateTestPage> createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  // Mode & UI
  bool useML = true;
  bool isGenerating = false;
  int _currentStep = 0;

  // Details
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController subjectCtrl = TextEditingController();
  final TextEditingController gradeCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController tagsCtrl = TextEditingController();
  double difficultyWeight = 0.5;

  // ML inputs
  final TextEditingController bookCtrl = TextEditingController();
  final TextEditingController chapterCtrl = TextEditingController();
  final TextEditingController topicCtrl = TextEditingController();
  List<PlatformFile> uploadedFiles = [];

  // Question types + manual inputs
  Map<String, bool> questionTypes = {
    'Multiple Choice': true,
    'True/False': true,
    'Short Answer': true,
    'Essay': false,
  };

  final TextEditingController durationCtrl = TextEditingController();
  final TextEditingController totalQuestionsCtrl = TextEditingController();
  final Map<String, TextEditingController> typeControllers = {
    'Multiple Choice': TextEditingController(),
    'True/False': TextEditingController(),
    'Short Answer': TextEditingController(),
    'Essay': TextEditingController(),
  };

  // Auto-save
  Timer? _debounce;
  static const _autosaveKey = 'create_test_autosave_v2';

  @override
  void initState() {
    super.initState();
    _loadAutosave();
    // attach listeners for autosave
    titleCtrl.addListener(_onFieldChanged);
    subjectCtrl.addListener(_onFieldChanged);
    gradeCtrl.addListener(_onFieldChanged);
    descriptionCtrl.addListener(_onFieldChanged);
    tagsCtrl.addListener(_onFieldChanged);

    bookCtrl.addListener(_onFieldChanged);
    chapterCtrl.addListener(_onFieldChanged);
    topicCtrl.addListener(_onFieldChanged);

    durationCtrl.addListener(_onFieldChanged);
    totalQuestionsCtrl.addListener(_onFieldChanged);
    for (var c in typeControllers.values) {
      c.addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    titleCtrl.dispose();
    subjectCtrl.dispose();
    gradeCtrl.dispose();
    descriptionCtrl.dispose();
    tagsCtrl.dispose();

    bookCtrl.dispose();
    chapterCtrl.dispose();
    topicCtrl.dispose();

    durationCtrl.dispose();
    totalQuestionsCtrl.dispose();
    for (var c in typeControllers.values) c.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    // Debounce autosave: save 1.5s after last change
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 1500), _saveAutosave);
    setState(() {}); // update live preview
  }

  Future<void> _saveAutosave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = {
        'title': titleCtrl.text,
        'subject': subjectCtrl.text,
        'grade': gradeCtrl.text,
        'description': descriptionCtrl.text,
        'tags': tagsCtrl.text,
        'difficultyWeight': difficultyWeight,
        'useML': useML,
        'book': bookCtrl.text,
        'chapter': chapterCtrl.text,
        'topic': topicCtrl.text,
        'uploadedFiles':
            uploadedFiles.map((f) => {'name': f.name, 'size': f.size}).toList(),
        'questionTypes': questionTypes,
        'duration': durationCtrl.text,
        'totalQuestions': totalQuestionsCtrl.text,
        'typeControllers': {
          for (var e in typeControllers.entries) e.key: e.value.text
        },
      };
      await prefs.setString(_autosaveKey, json.encode(payload));
    } catch (e) {
      // ignore autosave errors silently
    }
  }

  Future<void> _loadAutosave() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_autosaveKey);
      if (raw == null) return;
      final Map<String, dynamic> payload = json.decode(raw);
      titleCtrl.text = payload['title'] ?? '';
      subjectCtrl.text = payload['subject'] ?? '';
      gradeCtrl.text = payload['grade'] ?? '';
      descriptionCtrl.text = payload['description'] ?? '';
      tagsCtrl.text = payload['tags'] ?? '';
      difficultyWeight = (payload['difficultyWeight'] ?? 0.5).toDouble();
      useML = payload['useML'] ?? true;
      bookCtrl.text = payload['book'] ?? '';
      chapterCtrl.text = payload['chapter'] ?? '';
      topicCtrl.text = payload['topic'] ?? '';
      if (payload['uploadedFiles'] is List) {
        uploadedFiles = (payload['uploadedFiles'] as List).map((f) {
          return PlatformFile(
              name: f['name'] ?? 'file',
              size: f['size'] ?? 0,
              path: null,
              bytes: null);
        }).toList();
      }
      if (payload['questionTypes'] is Map) {
        questionTypes = Map<String, bool>.from(payload['questionTypes']);
      }
      durationCtrl.text = payload['duration'] ?? '';
      totalQuestionsCtrl.text = payload['totalQuestions'] ?? '';
      if (payload['typeControllers'] is Map) {
        final map = Map<String, dynamic>.from(payload['typeControllers']);
        for (var e in typeControllers.entries) {
          e.value.text = map[e.key]?.toString() ?? '';
        }
      }
      setState(() {});
    } catch (e) {
      // ignore load errors
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      allowedExtensions: ['pdf', 'doc', 'docx', 'csv', 'json'],
      type: FileType.custom,
    );
    if (result != null) {
      setState(() {
        uploadedFiles = result.files;
      });
      _onFieldChanged();
    }
  }

  Future<void> _mockMLPreview() async {
    if (bookCtrl.text.trim().isEmpty ||
        topicCtrl.text.trim().isEmpty ||
        uploadedFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Fill all ML fields & upload at least one file')),
      );
      return;
    }
    setState(() => isGenerating = true);
    // simulate ML call
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isGenerating = false);

    // open a preview modal with mock questions
    _showMLPreviewModal();
  }

  void _showMLPreviewModal() {
    showDialog(
      context: context,
      builder: (context) {
        final sample = List.generate(
          6,
          (i) => {
            'text': 'Sample question ${i + 1} about ${topicCtrl.text}',
            'type': (i % 3 == 0) ? 'Short Answer' : 'Multiple Choice',
            'difficulty': ['Easy', 'Medium', 'Hard'][i % 3],
          },
        );
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: CreateTestColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.smart_toy,
                          color: CreateTestColors.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('AI Preview',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[100],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: sample.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey[200]),
                    itemBuilder: (context, idx) {
                      final q = sample[idx];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color:
                                    CreateTestColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${idx + 1}',
                                  style: TextStyle(
                                    color: CreateTestColors.primary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    q['text']!,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getTypeColor(q['type']!)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          q['type']!,
                                          style: TextStyle(
                                            color: _getTypeColor(q['type']!),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: _getDifficultyColor(
                                                  q['difficulty']!)
                                              .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          q['difficulty']!,
                                          style: TextStyle(
                                            color: _getDifficultyColor(
                                                q['difficulty']!),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.edit_document),
                      label: const Text('Open in Editor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CreateTestColors.primary,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _createDraftAndOpenEditor(isML: true);
                      },
                    ),
                  ],
                )
              ]),
            ),
          ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Multiple Choice':
        return CreateTestColors.secondary;
      case 'True/False':
        return CreateTestColors.accent;
      case 'Short Answer':
        return CreateTestColors.warning;
      case 'Essay':
        return CreateTestColors.info;
      default:
        return CreateTestColors.primary;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return CreateTestColors.success;
      case 'Medium':
        return CreateTestColors.warning;
      case 'Hard':
        return CreateTestColors.error;
      default:
        return CreateTestColors.primary;
    }
  }

  void _createDraftAndOpenEditor({required bool isML}) {
    final provider = Provider.of<TestProvider>(context, listen: false);

    final metadata = {
      'subject': subjectCtrl.text,
      'grade': gradeCtrl.text,
      'tags': tagsCtrl.text,
      'description': descriptionCtrl.text,
      'difficulty': ['Easy', 'Medium', 'Hard'][(difficultyWeight * 2).round()],
    };

    final test = TestModel(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Generate unique ID
      title: (isML ? 'AI: ' : '') +
          (titleCtrl.text.trim().isEmpty
              ? 'Untitled Test'
              : titleCtrl.text.trim()),
      type: isML ? 'AI' : 'Manual',
      status: 'Draft',
      createdAt: DateTime.now(),
      publishedAt: null,
      book: isML ? bookCtrl.text.trim() : null,
      chapter: isML ? chapterCtrl.text.trim() : null,
      topic: isML ? topicCtrl.text.trim() : null,
      files: isML ? uploadedFiles.map((f) => f.name).toList() : const [],
      questionTypes: isML
          ? questionTypes.entries
              .where((e) => e.value)
              .map((e) => e.key)
              .toList()
          : typeControllers.entries
              .where((e) => (int.tryParse(e.value.text) ?? 0) > 0)
              .map((e) => e.key)
              .toList(),
      duration: isML ? null : (int.tryParse(durationCtrl.text.trim()) ?? 0),
      totalQuestions:
          isML ? null : (int.tryParse(totalQuestionsCtrl.text.trim()) ?? 0),
      questionBreakdown: isML
          ? null
          : {
              for (var e in typeControllers.entries)
                e.key: int.tryParse(e.value.text.trim()) ?? 0
            },
      questions: const [],
      metadata: metadata,
    );

    // Add to provider and get the actual test ID
    provider.addTest(test);

    // Get the actual test from provider (in case ID was modified)
    final addedTest = provider.tests.last;

    // Remove autosave since we moved into editor
    _removeAutosaveSilently();

    // Navigate to editor with the correct test ID
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => TestEditorPage(testId: addedTest.id!),
      ),
    );
  }

  Widget _buildModernCard(
      {required Widget child, String? title, IconData? icon, Color? color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color?.withOpacity(0.02) ??
                  CreateTestColors.primary.withOpacity(0.02),
              color?.withOpacity(0.05) ??
                  CreateTestColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (title != null)
              Row(
                children: [
                  if (icon != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color?.withOpacity(0.1) ??
                            CreateTestColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon,
                          size: 18, color: color ?? CreateTestColors.primary),
                    ),
                  if (icon != null) const SizedBox(width: 12),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                ],
              ),
            if (title != null) const SizedBox(height: 16),
            child,
          ]),
        ),
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        controller: titleCtrl,
        decoration: InputDecoration(
          labelText: 'Test Title *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.title),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: subjectCtrl,
        decoration: InputDecoration(
          labelText: 'Subject *',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.subject),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: gradeCtrl,
        decoration: InputDecoration(
          labelText: 'Target Grade',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.grade),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: descriptionCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          alignLabelWithHint: true,
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: tagsCtrl,
        decoration: InputDecoration(
          labelText: 'Tags (comma separated)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.tag),
        ),
      ),
      const SizedBox(height: 20),
      const Text('Creation Method',
          style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Row(children: [
        _buildMethodChip(
            'AI Assistant', Icons.smart_toy, useML, CreateTestColors.primary),
        const SizedBox(width: 12),
        _buildMethodChip('Manual Setup', Icons.edit_document, !useML,
            CreateTestColors.secondary),
      ]),
      const SizedBox(height: 24),
      const Text('Difficulty Level',
          style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Slider(
              value: difficultyWeight,
              onChanged: (v) => setState(() => difficultyWeight = v),
              divisions: 2,
              min: 0,
              max: 1,
              label: ['Easy', 'Medium', 'Hard'][(difficultyWeight * 2).round()],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['Easy', 'Medium', 'Hard'].map((level) {
                final index = ['Easy', 'Medium', 'Hard'].indexOf(level);
                final isActive = (difficultyWeight * 2).round() == index;
                return Column(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: isActive
                          ? CreateTestColors.primary
                          : Colors.grey[400],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level,
                      style: TextStyle(
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive
                            ? CreateTestColors.primary
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _buildMethodChip(
      String label, IconData icon, bool selected, Color color) {
    return Expanded(
      child: Card(
        elevation: selected ? 2 : 0,
        color: selected ? color.withOpacity(0.1) : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? color : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => useML = label == 'AI Assistant'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon,
                    size: 24, color: selected ? color : Colors.grey[600]),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? color : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMLSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Reference Materials',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      TextField(
        controller: bookCtrl,
        decoration: InputDecoration(
          labelText: 'Book/Textbook',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.menu_book),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: chapterCtrl,
        decoration: InputDecoration(
          labelText: 'Chapter/Section',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.bookmark),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: topicCtrl,
        decoration: InputDecoration(
          labelText: 'Topic/Concept',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.topic),
        ),
      ),
      const SizedBox(height: 20),
      const Text('Upload Files',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      ElevatedButton.icon(
        onPressed: _pickFiles,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Upload Reference Files'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: CreateTestColors.primary,
        ),
      ),
      const SizedBox(height: 16),
      if (uploadedFiles.isNotEmpty)
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: uploadedFiles.length,
            itemBuilder: (_, i) {
              final f = uploadedFiles[i];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CreateTestColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.insert_drive_file, size: 20),
                ),
                title: Text(f.name, overflow: TextOverflow.ellipsis),
                subtitle: Text('${(f.size / 1024).toStringAsFixed(1)} KB'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => uploadedFiles.removeAt(i)),
                ),
              );
            },
          ),
        ),
      const SizedBox(height: 24),
      const Text('Question Types',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: questionTypes.keys.map((t) {
          return FilterChip(
            label: Text(t),
            selected: questionTypes[t]!,
            onSelected: (v) => setState(() => questionTypes[t] = v),
            backgroundColor: questionTypes[t]!
                ? CreateTestColors.primary.withOpacity(0.1)
                : null,
            labelStyle: TextStyle(
              color: questionTypes[t]!
                  ? CreateTestColors.primary
                  : Colors.grey[700],
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: isGenerating ? null : _mockMLPreview,
        icon: isGenerating
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.auto_awesome),
        label: Text(
            isGenerating ? 'Generating Questions...' : 'Preview AI Generation'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: CreateTestColors.primary,
        ),
      ),
    ]);
  }

  Widget _buildManualSection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Test Configuration',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      TextField(
        controller: durationCtrl,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: 'Duration (minutes)',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.timer),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: totalQuestionsCtrl,
        keyboardType: TextInputType.number,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Total Questions',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.format_list_numbered),
        ),
      ),
      const SizedBox(height: 20),
      const Text('Question Breakdown',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      ...typeControllers.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextField(
            controller: entry.value,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '${entry.key} Questions',
              border: const OutlineInputBorder(),
              prefixIcon: Icon(_getQuestionTypeIcon(entry.key)),
            ),
            onChanged: (_) => setState(() {
              // update total automatically
              final total = typeControllers.values
                  .map((c) => int.tryParse(c.text) ?? 0)
                  .fold(0, (a, b) => a + b);
              totalQuestionsCtrl.text = total.toString();
            }),
          ),
        );
      }),
    ]);
  }

  IconData _getQuestionTypeIcon(String type) {
    switch (type) {
      case 'Multiple Choice':
        return Icons.radio_button_checked;
      case 'True/False':
        return Icons.toggle_on;
      case 'Short Answer':
        return Icons.short_text;
      case 'Essay':
        return Icons.subject;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildReviewCard() {
    final difficulty =
        ['Easy', 'Medium', 'Hard'][(difficultyWeight * 2).round()];
    final mode = useML ? 'AI Assistant' : 'Manual Setup';
    final selectedTypes = questionTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(', ');

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Test Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      _buildSummaryItem(
          'Title', titleCtrl.text.isEmpty ? 'Untitled Test' : titleCtrl.text),
      _buildSummaryItem('Subject',
          subjectCtrl.text.isEmpty ? 'Not specified' : subjectCtrl.text),
      _buildSummaryItem(
          'Grade', gradeCtrl.text.isEmpty ? 'Not specified' : gradeCtrl.text),
      _buildSummaryItem('Method', mode),
      _buildSummaryItem('Difficulty', difficulty),
      if (selectedTypes.isNotEmpty)
        _buildSummaryItem('Question Types', selectedTypes),
      const SizedBox(height: 16),
      if (descriptionCtrl.text.isNotEmpty) ...[
        const Text('Description:',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(
          descriptionCtrl.text,
          style:
              const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
      ],
      const Divider(),
      const SizedBox(height: 16),
      ElevatedButton.icon(
        onPressed: () => _createDraftAndOpenEditor(isML: useML),
        icon: const Icon(Icons.rocket_launch),
        label: const Text('Create & Open Editor'),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(50),
          backgroundColor: CreateTestColors.primary,
        ),
      ),
    ]);
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MediaQuery.of(context).size.width > 900
          ? null
          : const PreferredSize(
              preferredSize: Size.fromHeight(64), child: TopBar()),
      drawer: MediaQuery.of(context).size.width > 900 ? null : const SideBar(),
      body: SafeArea(
        child: Row(
          children: [
            if (MediaQuery.of(context).size.width > 900)
              const Expanded(flex: 2, child: SideBar()),
            Expanded(
              flex: 8,
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isWide = width > 1200;
                final twoColumn = width > 800 && width <= 1200;

                final detailsCard = _buildModernCard(
                  title: 'Test Details',
                  icon: Icons.assignment,
                  color: CreateTestColors.primary,
                  child: _buildDetailsSection(),
                );

                final inputsCard = _buildModernCard(
                  title: useML ? 'AI Configuration' : 'Manual Setup',
                  icon: useML ? Icons.smart_toy : Icons.settings,
                  color: useML
                      ? CreateTestColors.secondary
                      : CreateTestColors.accent,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: useML ? _buildMLSection() : _buildManualSection(),
                  ),
                );

                final reviewCard = _buildModernCard(
                  title: 'Review & Create',
                  icon: Icons.task_alt,
                  color: CreateTestColors.success,
                  child: _buildReviewCard(),
                );

                return Column(
                  children: [
                    // Modern Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            CreateTestColors.primary,
                            CreateTestColors.secondary
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: SafeArea(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.quiz,
                                      color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Text(
                                    'Create New Test',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Design your perfect assessment with AI assistance or manual setup',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Main Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(flex: 4, child: detailsCard),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 4, child: inputsCard),
                                  const SizedBox(width: 20),
                                  Expanded(flex: 3, child: reviewCard),
                                ],
                              )
                            : twoColumn
                                ? Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            detailsCard,
                                            const SizedBox(height: 20),
                                            reviewCard,
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(child: inputsCard),
                                    ],
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        detailsCard,
                                        const SizedBox(height: 20),
                                        inputsCard,
                                        const SizedBox(height: 20),
                                        reviewCard,
                                        const SizedBox(height: 40),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _removeAutosaveSilently() {}
}

class CreateTestColors {
  static const primary = Color(0xFF6366F1);
  static const secondary = Color(0xFF8B5CF6);
  static const accent = Color(0xFF06B6D4);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);
}
