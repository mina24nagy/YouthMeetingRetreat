import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/devotional.dart';
import '../services/database_service.dart';
import '../screens/devotional_detail_screen.dart';

class DevotionalsTab extends StatelessWidget {
  const DevotionalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<RealtimeDatabaseService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('التأملات اليومية')),
      body: StreamBuilder<List<Devotional>>(
        stream: db.getDevotionals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final devotionals = snapshot.data ?? [];
          if (devotionals.isEmpty) {
            return const Center(child: Text('سيتم إضافة التأملات قريباً!'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: devotionals.length,
            itemBuilder: (context, index) {
              final d = devotionals[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Day ${d.day}', style: const TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DevotionalDetailScreen(devotional: d)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
