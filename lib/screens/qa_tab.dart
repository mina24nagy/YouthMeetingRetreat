import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class QATab extends StatefulWidget {
  const QATab({super.key});

  @override
  State<QATab> createState() => _QATabState();
}

class _QATabState extends State<QATab> {
  final TextEditingController _controller = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final db = Provider.of<RealtimeDatabaseService>(context, listen: false);
    final id = await db.getUserId();
    if (mounted) {
      setState(() => _userId = id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<RealtimeDatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('أسئلة وأجوبة')),
      body: _userId == null 
        ? const Center(child: CircularProgressIndicator())
        : Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Question>>(
              stream: db.getQuestions('current_session_id', userId: _userId!), 
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final questions = snapshot.data ?? [];
                if (questions.isEmpty) {
                  return const Center(child: Text('لا توجد أسئلة بعد. كن أول من يسأل!'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return Card(
                      child: ListTile(
                        title: Text(q.text),
                        subtitle: Text(
                          'Just now', // Format timestamp
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'اسأل سؤالاً (بدون اسم)...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    if (_controller.text.isNotEmpty && _userId != null) {
                      await db.submitQuestion(Question(
                        id: '',
                        sessionId: 'current_session_id',
                        text: _controller.text,
                        timestamp: DateTime.now(),
                        userId: _userId!,
                      ));
                      _controller.clear();
                    }
                  },
                  icon: const Icon(Icons.send, color: AppTheme.primaryBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
