import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/session.dart';
import '../theme/app_theme.dart';

class SessionDetailScreen extends StatelessWidget {
  final Session session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final startTime = DateFormat('h:mm a').format(session.startTime);
    final endTime = DateFormat('h:mm a').format(session.endTime);
    final dayFormat = DateFormat('EEEE, d MMMM');
    final dateStr = dayFormat.format(session.startTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل الفقرة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.access_time, size: 20, color: AppTheme.slateGrey),
                const SizedBox(width: 8),
                Text(
                  '$startTime - $endTime',
                  style: const TextStyle(fontSize: 16, color: AppTheme.slateGrey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: AppTheme.slateGrey),
                const SizedBox(width: 8),
                Text(
                  dateStr,
                  style: const TextStyle(fontSize: 16, color: AppTheme.slateGrey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20, color: AppTheme.slateGrey),
                const SizedBox(width: 8),
                Text(
                  session.location,
                  style: const TextStyle(fontSize: 16, color: AppTheme.slateGrey),
                ),
              ],
            ),
            const Divider(height: 48),
            const Text(
              'عن الفقرة:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              session.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            if (session.resources.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'الملفات والروابط:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...session.resources.map((res) => _buildResourceTile(context, res)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResourceTile(BuildContext context, Resource res) {
    IconData icon;
    switch (res.type.toLowerCase()) {
      case 'pdf':
        icon = Icons.picture_as_pdf;
        break;
      case 'link':
        icon = Icons.link;
        break;
      default:
        icon = Icons.description;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(res.name),
        trailing: const Icon(Icons.open_in_new, size: 20),
        onTap: () async {
          final uri = Uri.parse(res.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Could not launch resource')),
              );
            }
          }
        },
      ),
    );
  }
}
