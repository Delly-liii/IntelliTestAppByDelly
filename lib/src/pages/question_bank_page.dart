import 'package:flutter/material.dart';
import 'package:intellitest_app/src/services/api_service.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';
import '../utils/validators.dart';

class QuestionBankPage extends StatefulWidget {
  const QuestionBankPage({super.key});

  @override
  State<QuestionBankPage> createState() => _QuestionBankPageState();
}

class _QuestionBankPageState extends State<QuestionBankPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();

  String _type = 'MCQ';
  String _difficulty = 'Easy';
  String _selectedFilter = 'All';
  String _sortBy = 'Recent';
  bool _isLoading = true;
  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _filteredQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _searchController.addListener(_filterQuestions);
  }

  void _loadQuestions() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    setState(() {
      _questions = _getSampleQuestions();
      _filteredQuestions = _questions;
      _isLoading = false;
    });
  }

  void _filterQuestions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredQuestions = _questions.where((question) {
        final matchesSearch = question['text'].toLowerCase().contains(query);
        final matchesFilter =
            _selectedFilter == 'All' || question['type'] == _selectedFilter;
        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  List<Map<String, dynamic>> _getSampleQuestions() {
    return [
      {
        'id': '1',
        'text': 'What is the derivative of x² with respect to x?',
        'type': 'MCQ',
        'difficulty': 'Easy',
        'subject': 'Mathematics',
        'createdAt': DateTime.now().subtract(const Duration(days: 1)),
        'usageCount': 15,
      },
      {
        'id': '2',
        'text': 'Explain the process of photosynthesis in plants.',
        'type': 'Essay',
        'difficulty': 'Hard',
        'subject': 'Biology',
        'createdAt': DateTime.now().subtract(const Duration(days: 3)),
        'usageCount': 8,
      },
      {
        'id': '3',
        'text': 'The capital of France is Paris. (True/False)',
        'type': 'True/False',
        'difficulty': 'Easy',
        'subject': 'Geography',
        'createdAt': DateTime.now().subtract(const Duration(days: 5)),
        'usageCount': 23,
      },
      {
        'id': '4',
        'text': 'Solve the equation: 2x + 5 = 15',
        'type': 'Short Answer',
        'difficulty': 'Medium',
        'subject': 'Mathematics',
        'createdAt': DateTime.now().subtract(const Duration(days: 7)),
        'usageCount': 12,
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  void _showAddQuestionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.add_circle_outline,
                      color: QuestionBankColors.primary),
                  SizedBox(width: 8),
                  Text('Add New Question'),
                ],
              ),
              content: Form(
                key: _formKey,
                child: SizedBox(
                  width: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _questionController,
                        decoration: const InputDecoration(
                          labelText: 'Question Text',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: minLengthField(10),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _type,
                        decoration: const InputDecoration(
                          labelText: 'Question Type',
                          border: OutlineInputBorder(),
                        ),
                        items: ['MCQ', 'Short Answer', 'True/False', 'Essay']
                            .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Row(
                                    children: [
                                      _getTypeIcon(t),
                                      const SizedBox(width: 8),
                                      Text(t),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _type = v ?? 'MCQ'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _difficulty,
                        decoration: const InputDecoration(
                          labelText: 'Difficulty Level',
                          border: OutlineInputBorder(),
                        ),
                        items: ['Easy', 'Medium', 'Hard']
                            .map((d) => DropdownMenuItem(
                                  value: d,
                                  child: Row(
                                    children: [
                                      _getDifficultyIcon(d),
                                      const SizedBox(width: 8),
                                      Text(d),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _difficulty = v ?? 'Easy'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop(true);
                      final scaffold = ScaffoldMessenger.of(context);
                      scaffold.showSnackBar(
                        const SnackBar(content: Text('Saving question...')),
                      );

                      final ok = await ApiService.instance.addQuestion(
                        text: _questionController.text.trim(),
                        type: _type,
                        difficulty: _difficulty,
                      );

                      scaffold.hideCurrentSnackBar();
                      if (ok) {
                        scaffold.showSnackBar(
                          const SnackBar(
                              content: Text('Question added successfully')),
                        );
                        _questionController.clear();
                        _loadQuestions(); // Refresh the list
                      } else {
                        scaffold.showSnackBar(
                          const SnackBar(
                              content: Text('Failed to add question')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: QuestionBankColors.primary,
                  ),
                  child: const Text('Save Question',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filter Questions',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),

                  // Type Filter
                  _buildFilterSection(
                      'Question Type',
                      ['All', 'MCQ', 'Short Answer', 'True/False', 'Essay'],
                      _selectedFilter, (value) {
                    setState(() => _selectedFilter = value);
                  }),

                  const SizedBox(height: 16),

                  // Difficulty Filter
                  _buildDifficultyFilter(),

                  const SizedBox(height: 20),

                  // Sort Options
                  _buildSortOptions(),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'All';
                              _sortBy = 'Recent';
                            });
                            Navigator.pop(context);
                            _filterQuestions();
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _filterQuestions();
                          },
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(String title, List<String> options,
      String selected, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selected;
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (_) => onChanged(option),
              backgroundColor: isSelected
                  ? QuestionBankColors.primary.withOpacity(0.1)
                  : null,
              labelStyle: TextStyle(
                color:
                    isSelected ? QuestionBankColors.primary : Colors.grey[700],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildDifficultyChip('All'),
            _buildDifficultyChip('Easy'),
            _buildDifficultyChip('Medium'),
            _buildDifficultyChip('Hard'),
          ],
        ),
      ],
    );
  }

  Widget _buildDifficultyChip(String difficulty) {
    final isSelected = false; // You can implement this logic
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _getDifficultyIcon(difficulty),
            const SizedBox(width: 4),
            Text(difficulty),
          ],
        ),
        selected: isSelected,
        onSelected: (_) {},
      ),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _sortBy,
          items: ['Recent', 'Most Used', 'Difficulty', 'Alphabetical']
              .map((sort) => DropdownMenuItem(value: sort, child: Text(sort)))
              .toList(),
          onChanged: (v) => setState(() => _sortBy = v ?? 'Recent'),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _getTypeIcon(String type) {
    switch (type) {
      case 'MCQ':
        return const Icon(Icons.radio_button_checked,
            size: 18, color: Colors.blue);
      case 'Short Answer':
        return const Icon(Icons.short_text, size: 18, color: Colors.green);
      case 'True/False':
        return const Icon(Icons.check_circle_outline,
            size: 18, color: Colors.orange);
      case 'Essay':
        return const Icon(Icons.subject, size: 18, color: Colors.purple);
      default:
        return const Icon(Icons.help_outline, size: 18);
    }
  }

  Widget _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return const Icon(Icons.sentiment_satisfied,
            size: 18, color: Colors.green);
      case 'Medium':
        return const Icon(Icons.sentiment_neutral,
            size: 18, color: Colors.orange);
      case 'Hard':
        return const Icon(Icons.sentiment_dissatisfied,
            size: 18, color: Colors.red);
      default:
        return const Icon(Icons.sentiment_satisfied, size: 18);
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(64),
        child: TopBar(),
      ),
      drawer: const SideBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    _buildHeaderSection(),
                    const SizedBox(height: 24),

                    // Analytics Cards
                    _buildAnalyticsSection(),
                    const SizedBox(height: 24),

                    // Search and Actions Bar
                    _buildSearchSection(),
                    const SizedBox(height: 24),

                    // Questions Grid
                    _buildQuestionsSection(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Row(
      children: [
        Icon(Icons.quiz_outlined, size: 32, color: QuestionBankColors.primary),
        SizedBox(width: 12),
        Text(
          'Question Bank',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildAnalyticsSection() {
    final totalQuestions = _questions.length;
    final mcqCount = _questions.where((q) => q['type'] == 'MCQ').length;
    final easyCount = _questions.where((q) => q['difficulty'] == 'Easy').length;

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildAnalyticsCard('Total Questions', '$totalQuestions', Icons.quiz,
            QuestionBankColors.primary),
        _buildAnalyticsCard('MCQ Questions', '$mcqCount',
            Icons.radio_button_checked, Colors.blue),
        _buildAnalyticsCard('Easy Questions', '$easyCount',
            Icons.sentiment_satisfied, Colors.green),
        _buildAnalyticsCard(
            'Most Used', '23 times', Icons.trending_up, Colors.orange),
      ],
    );
  }

  Widget _buildAnalyticsCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search questions...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _showFilters,
              icon: const Icon(Icons.filter_list),
              label: const Text('Filters'),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _showAddQuestionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Question'),
              style: ElevatedButton.styleFrom(
                backgroundColor: QuestionBankColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionsSection() {
    if (_isLoading) {
      return _buildLoadingSkeleton();
    }

    if (_filteredQuestions.isEmpty) {
      return _buildEmptyState();
    }

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _filteredQuestions.length,
        itemBuilder: (context, index) =>
            _buildQuestionCard(_filteredQuestions[index]),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(question['difficulty'])
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    question['difficulty'],
                    style: TextStyle(
                      color: _getDifficultyColor(question['difficulty']),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showQuestionDialog(question: question);
                        break;
                      case 'delete':
                        _deleteQuestion(question);
                        break;
                      case 'duplicate':
                        _duplicateQuestion(question);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(
                        value: 'duplicate', child: Text('Duplicate')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question['text'],
              style: const TextStyle(fontWeight: FontWeight.w500),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  question['type'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Row(
                  children: [
                    const Icon(Icons.assessment_outlined,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${question['usageCount']} uses',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'No questions found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or filters, or add a new question',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddQuestionDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Question'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteQuestion(Map<String, dynamic> question) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Question?'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await ApiService.instance.deleteQuestion(question['id']);
      _loadQuestions();
    }
  }

  void _duplicateQuestion(Map<String, dynamic> question) async {
    await ApiService.instance.addQuestion(
      text: question['text'],
      type: question['type'],
      difficulty: question['difficulty'],
    );
    _loadQuestions();
  }

  void _showQuestionDialog({required Map<String, dynamic> question}) {
    _questionController.text = question['text'];
    _type = question['type'];
    _difficulty = question['difficulty'];
    _showAddQuestionDialog(); // reuse dialog
  }

  Widget _buildLoadingSkeleton() {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 4,
        itemBuilder: (context, index) => Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

extension on ApiService {
  Future<void> deleteQuestion(question) async {}
}

class QuestionBankColors {
  static const primary = Color(0xFF7E57C2);
  static const secondary = Color(0xFF26A69A);
  static const accent = Color(0xFF5C6BC0);
}
