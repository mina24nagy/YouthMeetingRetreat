import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/devotional.dart';
import '../theme/app_theme.dart';

class DevotionalDetailScreen extends StatelessWidget {
  final Devotional devotional;

  const DevotionalDetailScreen({super.key, required this.devotional});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تأمل اليوم ${devotional.day}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              devotional.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, d MMMM yyyy').format(devotional.date),
              style: const TextStyle(color: AppTheme.slateGrey),
            ),
            const Divider(height: 40),
            Text(
              devotional.content,
              style: const TextStyle(
                fontSize: 18,
                height: 1.6,
                color: AppTheme.slateGrey,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
