import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../screens/live_dashboard.dart';
import '../screens/devotionals_tab.dart';
import '../screens/gallery_tab.dart';
import '../screens/qa_tab.dart';
import '../screens/treasure_hunt_screen.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  StreamSubscription? _broadcastSubscription;
  int? _lastSeenTimestamp;

  @override
  void initState() {
    super.initState();
    _initBroadcastListener();
    _initFCMListener();
  }

  void _initFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showBroadcastAlert(
          "${message.notification!.title}\n${message.notification!.body}",
        );
      }
    });
  }

  @override
  void dispose() {
    _broadcastSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initBroadcastListener() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSeenTimestamp = prefs.getInt('last_broadcast_ts');
    
    // If first time, set to current time to avoid showing all history
    if (_lastSeenTimestamp == null) {
      _lastSeenTimestamp = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('last_broadcast_ts', _lastSeenTimestamp!);
    }

    if (!mounted) return;
    final db = Provider.of<RealtimeDatabaseService>(context, listen: false);
    
    _broadcastSubscription = db.getBroadcastsStream().listen((broadcast) {
      if (broadcast != null) {
        final ts = broadcast['timestamp'] as int? ?? 0;
        if (ts > (_lastSeenTimestamp ?? 0)) {
          _showBroadcastAlert(broadcast['message'] ?? '');
          _lastSeenTimestamp = ts;
          prefs.setInt('last_broadcast_ts', ts);
        }
      }
    });
  }

  void _showBroadcastAlert(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: const [
            Icon(Icons.campaign, color: Colors.orange, size: 30),
            SizedBox(width: 10),
            Text('تنبيه هام!', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  final List<Widget> _tabs = [
    const LiveDashboard(),
    const DevotionalsTab(),
    const GalleryTab(),
    const QATab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'البرنامج',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'تأملات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'الصور',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_outlined),
            activeIcon: Icon(Icons.question_answer),
            label: 'أسئلة',
          ),
        ],
      ),
    );
  }
}
