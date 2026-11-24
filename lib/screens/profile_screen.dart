import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../services/auth_session.dart';

class LuxuryProfileScreen extends StatefulWidget {
  const LuxuryProfileScreen({super.key});

  @override
  State<LuxuryProfileScreen> createState() => _LuxuryProfileScreenState();
}

class _LuxuryProfileScreenState extends State<LuxuryProfileScreen> {
  static const String apiUrl = 'https://koki-party-new.onrender.com';

  // لوحة ألوان KOKI PARTY الفاخرة
  static const Color luxuryVoid = Color(0xFF070312);
  static const Color luxuryObsidian = Color(0xFF130829);
  static const Color luxuryPanel = Color(0xFF1E0D40);
  static const Color luxurySurface = Color(0xFF2B135C);
  static const Color champagneGold = Color(0xFFFFF0B3);
  static const Color pureGold = Color(0xFFFFC93C);
  static const Color antiqueGold = Color(0xFFB87914);
  static const Color royalAmethyst = Color(0xFF9C5CFF);

  bool loading = true;
  String? errorMessage;
  Map<String, dynamic> _accountData = {};

  String? get currentUserId =>
      _accountData['id']?.toString() ?? AuthSession.user?['id']?.toString();

  Map<String, String> get headers {
    final token = AuthSession.accessToken;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  String formatShortId(String? rawId) {
    if (rawId == null || rawId.trim().isEmpty) return '1000';
    final cleaned = rawId.replaceAll('-', '').trim();
    if (cleaned.length <= 6) return cleaned.toUpperCase();
    final hash = cleaned.codeUnits.fold<int>(
      0,
      (acc, c) => (acc * 31 + c) % 9000,
    );
    return '${1000 + hash}';
  }

  bool _looksLikeUuid(String value) => value.length >= 24 && value.contains('-');

  String get _displayName {
    final candidates = [
      _accountData['name'],
      _accountData['username'],
      _accountData['nickname'],
      AuthSession.user?['name'],
      AuthSession.user?['username'],
    ];
    for (final c in candidates) {
      final str = c?.toString().trim();
      if (str != null && str.isNotEmpty && !_looksLikeUuid(str)) {
        return str;
      }
    }
    return 'عضو #${formatShortId(currentUserId)}';
  }

  String _formatBalance(List<String> keys, {String fallback = '0'}) {
    for (final key in keys) {
      final val = _accountData[key] ?? AuthSession.user?[key];
      if (val != null && val.toString().trim().isNotEmpty) {
        return val.toString();
      }
    }
    return fallback;
  }

  Future<dynamic> apiRequest(String method, String path) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$apiUrl$path');
      final request = await client.openUrl(method, uri);
      headers.forEach((key, value) => request.headers.set(key, value));
      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('خطأ من السيرفر (${response.statusCode})');
      }
      if (responseText.isEmpty) return null;
      return jsonDecode(responseText);
    } finally {
      client.close();
    }
  }

  @override
  void initState() {
    super.initState();
    loadAccountData();
  }

  Future<void> loadAccountData() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      Map<String, dynamic> merged = {
        if (AuthSession.user is Map) ...Map<String, dynamic>.from(AuthSession.user as Map),
      };

      try {
        final meRes = await apiRequest('GET', '/api/auth/me');
        if (meRes is Map) {
          final userObj = meRes['user'] is Map
              ? Map<String, dynamic>.from(meRes['user'] as Map)
              : Map<String, dynamic>.from(meRes);
          merged = {...merged, ...userObj};
        }
      } catch (_) {}

      try {
  final walletRes = await apiRequest('GET', '/api/wallet');
  if (walletRes is Map) {
    final walletObj = walletRes['wallet'] is Map
        ? Map<String, dynamic>.from(walletRes['wallet'] as Map)
        : Map<String, dynamic>.from(walletRes);
    merged = {...merged, ...walletObj};
  }
} catch (_) {}
      

      if (!mounted) return;
      setState(() {
        _accountData = merged;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  void _showComingSoon(String sectionTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: luxuryPanel,
        content: Text(
          '$sectionTitle — قيد التفعيل في KOKI PARTY',
          style: const TextStyle(color: champagneGold),
        ),
      ),
    );
  }
    Widget _buildProfileCard() {
    final coins = _formatBalance(['coins', 'balance', 'goldCoins'], fallback: '0');
    final diamonds = _formatBalance(['diamonds', 'gems', 'hostDiamonds'], fallback: '0');
    final shortId = formatShortId(currentUserId);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3E167A),
            luxurySurface,
            Color(0xFF170836),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: pureGold.withOpacity(0.7), width: 1.4),
        boxShadow: [
          BoxShadow(
            color: pureGold.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [champagneGold, pureGold, antiqueGold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: pureGold.withOpacity(0.45),
                      blurRadius: 14,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(2.5),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: luxuryVoid,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: champagneGold,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: luxuryVoid.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: pureGold.withOpacity(0.45)),
                      ),
                      child: Text(
                        'عضو #$shortId',
                        style: const TextStyle(
                          color: champagneGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: loadAccountData,
                icon: const Icon(Icons.refresh_rounded, color: champagneGold),
                tooltip: 'تحديث البيانات',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceTile(
                  label: 'العملات الذهبية',
                  value: coins,
                  icon: Icons.monetization_on_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBalanceTile(
                  label: 'ألماس المضيف',
                  value: diamonds,
                  icon: Icons.diamond_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceTile({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: luxuryObsidian.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pureGold.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: pureGold, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: champagneGold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsRow() {
    final actions = [
      ('شحن الرصيد', Icons.account_balance_wallet_rounded),
      ('المتجر الملكي', Icons.storefront_rounded),
      ('الوكالة', Icons.groups_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: actions.map((item) {
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showComingSoon(item.$1),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: luxuryPanel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: pureGold.withOpacity(0.45)),
                ),
                child: Column(
                  children: [
                    Icon(item.$2, color: champagneGold, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      item.$1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
    Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final accentColor = isDestructive ? Colors.redAccent : champagneGold;
    final borderColor = isDestructive
        ? Colors.redAccent.withOpacity(0.45)
        : pureGold.withOpacity(0.4);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: luxuryPanel.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: luxuryVoid.withOpacity(0.65),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, color: accentColor, size: 21),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.redAccent : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 11.5),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: accentColor.withOpacity(0.8),
          size: 15,
        ),
      ),
    );
  }

  void _handleLogout() {
    AuthSession.accessToken = null;
    AuthSession.user = null;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: luxuryPanel,
        content: Text(
          'تم مسح بيانات الجلسة المحلية بنجاح',
          style: TextStyle(color: champagneGold),
        ),
      ),
    );
    setState(() {
      _accountData = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (loading) {
      content = const Center(
        child: CircularProgressIndicator(color: pureGold),
      );
    } else if (errorMessage != null && _accountData.isEmpty) {
      content = Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: pureGold, size: 42),
              const SizedBox(height: 10),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pureGold,
                  foregroundColor: luxuryVoid,
                ),
                onPressed: loadAccountData,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    } else {
      content = ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _buildProfileCard(),
          _buildQuickActionsRow(),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                _buildMenuItem(
                  title: 'العضوية الملكية VIP',
                  subtitle: 'إطارات ذهبية وامتيازات خاصة داخل الغرف',
                  icon: Icons.workspace_premium_rounded,
                  onTap: () => _showComingSoon('العضوية الملكية VIP'),
                ),
                _buildMenuItem(
                  title: 'الإنجازات والشارات',
                  subtitle: 'مستوى الثروة والجاذبية في KOKI PARTY',
                  icon: Icons.military_tech_rounded,
                  onTap: () => _showComingSoon('الإنجازات والشارات'),
                ),
                _buildMenuItem(
                  title: 'إعدادات الحساب والخصوصية',
                  subtitle: 'إدارة بيانات الجلسة وتفضيلات التطبيق',
                  icon: Icons.settings_rounded,
                  onTap: () => _showComingSoon('إعدادات الحساب والخصوصية'),
                ),
                _buildMenuItem(
                  title: 'تسجيل الخروج',
                  subtitle: 'إنهاء الجلسة الحالية من الجهاز',
                  icon: Icons.logout_rounded,
                  isDestructive: true,
                  onTap: _handleLogout,
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _LuxuryProfileStarsPainter(),
            ),
          ),
          content,
        ],
      ),
    );
  }
}

class _LuxuryProfileStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(99);

    for (int i = 0; i < 35; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * (size.height * 0.75);
      final radius = 0.7 + rng.nextDouble() * 1.4;
      final opacity = 0.14 + rng.nextDouble() * 0.35;

      starPaint.color =
          (i % 3 == 0 ? const Color(0xFFFFF0B3) : Colors.white).withOpacity(opacity);
      canvas.drawCircle(Offset(dx, dy), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
