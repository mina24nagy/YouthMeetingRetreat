import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/session.dart';
import '../models/question.dart';
import '../models/devotional.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<RealtimeDatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم المسؤول'),
        backgroundColor: AppTheme.slateGrey,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          _buildSectionHeader('التحكم في البث'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showBroadcastDialog(context, db),
                    icon: const Icon(Icons.campaign),
                    label: const Text('إرسال تنبيه "تجمعوا الآن"'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('إدارة البرنامج'),
          StreamBuilder<List<Session>>(
            stream: db.getSessions(),
            builder: (context, snapshot) {
              final sessions = snapshot.data ?? [];
              return Column(
                children: sessions.map((s) => _buildSessionEditTile(context, s, db)).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('تنسيق الأسئلة والأجوبة'),
          StreamBuilder<List<Question>>(
            stream: db.getQuestions('current_session_id'), // Simplified
            builder: (context, snapshot) {
              final questions = snapshot.data ?? [];
              return Column(
                children: questions.map((q) => _buildQuestionModTile(context, q, db)).toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('إدارة التأملات'),
          StreamBuilder<List<Devotional>>(
            stream: db.getDevotionals(),
            builder: (context, snapshot) {
              final devotionals = snapshot.data ?? [];
              return Column(
                children: [
                   ElevatedButton.icon(
                    onPressed: () => _showEditDevotionalDialog(context, null, db),
                    icon: const Icon(Icons.add),
                    label: const Text('إضافة تأمل جديد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...devotionals.map((d) => _buildDevotionalEditTile(context, d, db)).toList(),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.slateGrey),
      ),
    );
  }

  Widget _buildSessionEditTile(BuildContext context, Session session, RealtimeDatabaseService db) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(session.title),
        subtitle: Text(session.location),
        trailing: const Icon(Icons.edit),
        onTap: () => _showEditSessionDialog(context, session, db),
      ),
    );
  }

  Widget _buildQuestionModTile(BuildContext context, Question question, RealtimeDatabaseService db) {
    return Card(
      key: ValueKey('question_${question.id}'),
      margin: const EdgeInsets.all(8),
      child: ListTile(
        title: Text(question.text),
        trailing: IconButton(
          icon: const Icon(Icons.archive, color: Colors.grey),
          onPressed: () => db.archiveQuestion(question.id),
        ),
      ),
    );
  }

  void _showBroadcastDialog(BuildContext context, RealtimeDatabaseService db) {
    final controller = TextEditingController(text: '🚨 تجمعوا الآن: الفقرة التالية ستبدأ خلال 5 دقائق! 🚨');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنبيه عام'),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              db.broadcastBroadcastNotification(controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال التنبيه!')));
            },
            child: const Text('إرسال الآن'),
          ),
        ],
      ),
    );
  }

  void _showEditSessionDialog(BuildContext context, Session session, RealtimeDatabaseService db) {
    // Logic to edit session title/time would go here
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ميزة التعديل جاهزة للتفعيل')));
  }

  Widget _buildDevotionalEditTile(BuildContext context, Devotional d, RealtimeDatabaseService db) {
    return Card(
      key: ValueKey('devotional_${d.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(d.title),
        subtitle: Text('اليوم ${d.day}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
              onPressed: () => _showEditDevotionalDialog(context, d, db),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDevotionalConfirm(context, d, db),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDevotionalConfirm(BuildContext context, Devotional d, RealtimeDatabaseService db) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف التأمل'),
        content: Text('هل أنت متأكد من حذف "${d.title}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              db.deleteDevotional(d.id);
              Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditDevotionalDialog(BuildContext context, Devotional? d, RealtimeDatabaseService db) {
    final titleController = TextEditingController(text: d?.title ?? '');
    final dayController = TextEditingController(text: d?.day.toString() ?? '');
    final contentController = TextEditingController(text: d?.content ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(d == null ? 'إضافة تأمل' : 'تعديل التأمل'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dayController,
                decoration: const InputDecoration(labelText: 'رقم اليوم'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'المحتوى'),
                maxLines: 5,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final newDev = Devotional(
                id: d?.id ?? '',
                day: int.tryParse(dayController.text) ?? 1,
                title: titleController.text,
                content: contentController.text,
                date: d?.date ?? DateTime.now(),
              );

              if (d == null) {
                db.addDevotional(newDev);
              } else {
                db.updateDevotional(newDev);
              }
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
