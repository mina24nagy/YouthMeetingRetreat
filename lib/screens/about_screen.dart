import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../screens/admin_dashboard.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مؤتمر الإيمان')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onLongPress: () {
                  _showAdminPinDialog(context);
                },
                child: Image.asset(
                  'assets/images/about_banner.jpg',
                  width: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.church, size: 100, color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'مؤتمر الإيمان',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
              ),
              const Text(
                'v1.0.0',
                style: TextStyle(color: AppTheme.slateGrey),
              ),
              const SizedBox(height: 32),
              const Text(
                'أهلاً بكم في هذا المؤتمر الذي نجتمع فيه معاً لنتأمل في أعظم عطية تُمنح لنا، وهي "الإيمان". الإيمان هو بدء الطريق الموصل إلى الله، وهو "الثقة بما يرجى والإيقان بأمور لا ترى".\n\n'
                'إن الإيمان المسيحي الحقيقي ليس مجرد إيمان عقلي يكتفي بالتصديق على الحقائق وتوفر الأدلة، ولا هو مجرد "إيمان قول" سطحي لا يُغير من واقعنا شيئاً. بل هو ارتباط شخصي عميق بيسوع المسيح، واتحاد حقيقي به، وائتمانه بالكامل على كل تفاصيل حياتنا. فنحن نؤمن لكي ننال الغاية العظمى والمكافأة الأكبر، وهي "خلاص النفوس" واسترجاع إنسانيتنا وصورتنا التي قصدها الله لنا.\n\n'
                'وهذا الإيمان الحي لا يمكن أن ينفصل عن الحياة العملية، فالإيمان بدون أعمال ميت في ذاته. فكما يتبرر الإنسان أمام الله بالإيمان، فإن هذا الإيمان يتبرر ويُثبت صحته أمام الناس بالأعمال الصالحة، وبحياة طاهرة تعكس "الإيمان العامل بالمحبة".\n\n'
                'وفي رحلتنا اليومية، نمر جميعاً بسلسلة مستمرة من "امتحانات الإيمان" من خلال الضيقات، والمواقف، والقرارات الصعبة. هذه الامتحانات تسمح بها يد الله الحانية لتنقية إيماننا لكي ينمو من إيمان ضعيف أو محدود، إلى ثقة مطلقة وتسليم كامل. وعندما ينضج إيماننا، يتحول إلى قوة تطرد الخوف وتمنحنا السلام العجيب، قوة قادرة على "نقل الجبال"؛ سواء كانت جبالاً من المشاكل والتحديات التي تبدو مستحيلة، أو جبالاً من الخطايا والطباع الشخصية المتجذرة في داخلنا.\n\n'
                'ندعوكم في أيام هذا المؤتمر أن نفتح قلوبنا لتنقية إيماننا، وأن نصرخ معاً بقلب واحد سائلين الرب: "يا رب زِد إيماننا"، لكي نخرج من هنا ونحن نحيا حياة مسيحية حقيقية ممتلئة بالنصرة والرجاء.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6, color: AppTheme.slateGrey),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showAdminPinDialog(BuildContext context) {
    final TextEditingController pinController = TextEditingController();
    final db = Provider.of<RealtimeDatabaseService>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('دخول الإدارة'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'أدخل رقم السر'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final secret = await db.getAdminSecret();
              if (!context.mounted) return;
              if (pinController.text == secret) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboard()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('رقم سر غير صحيح')),
                );
              }
            },
            child: const Text('دخول'),
          ),
        ],
      ),
    );
  }
}
