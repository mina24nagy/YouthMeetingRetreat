import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TreasureHuntScreen extends StatefulWidget {
  const TreasureHuntScreen({super.key});

  @override
  State<TreasureHuntScreen> createState() => _TreasureHuntScreenState();
}

class _TreasureHuntScreenState extends State<TreasureHuntScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _teamController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مسابقة الكنز الكتابي')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.auto_stories, size: 80, color: AppTheme.primaryBlue),
            const SizedBox(height: 16),
            const Text(
              'هل وجدت كوداً سرياً؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.slateGrey),
            ),
            const SizedBox(height: 8),
            const Text(
              'أدخل الكود واسم فريقك هنا لتربح نقاطاً في لوحة المتصدرين!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.slateGrey),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _teamController,
              decoration: const InputDecoration(
                labelText: 'اسم الفريق',
                prefixIcon: Icon(Icons.group),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'الكود السري',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitCode,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white) 
                : const Text('استبدال الكود'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitCode() async {
    if (_teamController.text.isEmpty || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك أدخل اسم الفريق والكود أولاً')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Logic to verify code and add points in Firebase
    // For now, we'll just show a success message
    await Future.delayed(const Duration(seconds: 1)); 

    setState(() => _isLoading = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('تم قبول الكود! أضيفت النقاط لفريقك.'),
        ),
      );
      _codeController.clear();
    }
  }
}
