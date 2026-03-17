import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/session.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../screens/about_screen.dart';
import '../screens/session_detail_screen.dart';

import 'package:url_launcher/url_launcher.dart';

class LiveDashboard extends StatefulWidget {
  const LiveDashboard({super.key});

  @override
  State<LiveDashboard> createState() => _LiveDashboardState();
}

class _LiveDashboardState extends State<LiveDashboard> {
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch resource')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<RealtimeDatabaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('مؤتمر الإيمان'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Session>>(
        stream: db.getSessions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(child: Text('No sessions scheduled yet.'));
          }

          final now = DateTime.now();
          Session? currentSession;
          List<Session> upcomingSessions = [];

          for (var session in sessions) {
            if (now.isAfter(session.startTime) && now.isBefore(session.endTime)) {
              currentSession = session;
            } else if (now.isBefore(session.startTime)) {
              upcomingSessions.add(session);
            }
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (currentSession != null) ...[
                  _buildHeader('يحدث الآن'),
                  _buildCurrentSessionCard(currentSession),
                  const SizedBox(height: 24),
                ] else ...[
                  _buildHeader('التالي'),
                  if (upcomingSessions.isNotEmpty)
                    _buildUpcomingSessionCard(upcomingSessions.first)
                  else
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('لا يوجد فقرات مجدولة حالياً.'),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
                _buildHeader('البرنامج'),
                ..._buildGroupedSessions(sessions, currentSession),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildGroupedSessions(List<Session> sessions, Session? currentSession) {
    List<Widget> widgets = [];
    DateTime? lastDate;

    // Start from the first session's date to calculate day numbers accurately
    if (sessions.isEmpty) return widgets;
    
    final firstDate = DateTime(
      sessions.first.startTime.year,
      sessions.first.startTime.month,
      sessions.first.startTime.day,
    );

    for (var session in sessions) {
      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (lastDate == null || !lastDate.isAtSameMomentAs(sessionDate)) {
        lastDate = sessionDate;
        
        final dayNumber = sessionDate.difference(firstDate).inDays + 1;
        String dayText;
        if (dayNumber == 1) {
          dayText = 'اليوم الأول';
        } else if (dayNumber == 2) {
          dayText = 'اليوم الثاني';
        } else if (dayNumber == 3) {
          dayText = 'اليوم الثالث';
        } else {
          dayText = 'اليوم $dayNumber';
        }

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  dayText,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      widgets.add(_buildSessionTile(session, session == currentSession));
    }
    return widgets;
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }

  Widget _buildCurrentSessionCard(Session session) {
    return Card(
      elevation: 4,
      color: AppTheme.softBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.primaryBlue, width: 2),
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SessionDetailScreen(session: session)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'مباشر الآن',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                session.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.slateGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${DateFormat('jm').format(session.startTime)} - ${DateFormat('jm').format(session.endTime)}',
                style: const TextStyle(color: AppTheme.slateGrey, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.slateGrey),
                  const SizedBox(width: 4),
                  Text(session.location, style: const TextStyle(color: AppTheme.slateGrey)),
                ],
              ),
              if (session.resources.isNotEmpty) ...[
                const Divider(height: 24),
                const Text('الملفات والروابط:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: session.resources.map((r) => _buildResourceChip(r)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingSessionCard(Session session) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SessionDetailScreen(session: session)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(
            session.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${DateFormat('jm').format(session.startTime)} @ ${session.location}'),
              const SizedBox(height: 4),
              Text(session.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }

  Widget _buildSessionTile(Session session, bool isCurrent) {
    return Opacity(
      opacity: DateTime.now().isAfter(session.endTime) ? 0.5 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isCurrent ? 4 : 1,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SessionDetailScreen(session: session)),
          ),
          child: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('jm').format(session.startTime),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
            title: Text(
              session.title,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? AppTheme.primaryBlue : AppTheme.slateGrey,
              ),
            ),
            subtitle: Text(session.location),
            trailing: const Icon(Icons.chevron_right, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildResourceChip(Resource resource) {
    return ActionChip(
      avatar: Icon(
        resource.type == 'pdf' ? Icons.picture_as_pdf : Icons.insert_drive_file,
        size: 16,
        color: AppTheme.primaryBlue,
      ),
      label: Text(resource.name),
      onPressed: () => _launchURL(resource.url),
    );
  }
}
