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

  // لوحة ألوان فاخرة موحدة لـ KOKI PARTY
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

  Map<String, dynamic> _profile = {};
  Map<String, dynamic> _wallet = {};

  String? get currentUserId => AuthSession.user?['id']?.toString();

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
    final merged = {...?AuthSession.user, ..._profile};
    final candidates = [
      merged['displayName'],
      merged['userName'],
      merged['username'],
      merged['name'],
    ];
    for (final c in candidates) {
      final str = c?.toString().trim();
      if (str != null && str.isNotEmpty && !_looksLikeUuid(str)) {
        return str;
      }
    }
    return 'عضو #${formatShortId(currentUserId)}';
  }
    Future<dynamic> apiRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$apiUrl$path');
      final request = await client.openUrl(method, uri);
      headers.forEach((key, value) => request.headers.set(key, value));
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('خطأ من السيرفر (${response.statusCode}): $responseText');
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
      final meResponse = await apiRequest('GET', '/api/auth/me');
      Map<String, dynamic> profileData = {};

      if (meResponse is Map<String, dynamic>) {
        final rawUser = meResponse['user'] ?? meResponse['data'] ?? meResponse;
        if (rawUser is Map) {
          profileData = Map<String, dynamic>.from(rawUser);
        }
      }

      Map<String, dynamic> walletData = {};
      try {
        final walletResponse = await apiRequest('GET', '/api/wallet');
        if (walletResponse is Map) {
          final rawWallet = walletResponse['data'] ?? walletResponse;
          if (rawWallet is Map) {
            walletData = Map<String, dynamic>.from(rawWallet);
          }
        }
      } catch (_) {
        // إذا لم يكن المسار متاحًا في النسخة الحالية نعتمد على بيانات الحساب
      }

      if (!mounted) return;
      setState(() {
        _profile = profileData;
        _wallet = walletData;
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

  String _formatBalance(List<String> keys, {String fallback = '0'}) {
    final sources = [_wallet, _profile, ...?AuthSession.user == null ? [] : [AuthSession.user!]];
    for (final src in sources) {
      for (final key in keys) {
        final val = src[key];
        if (val != null && val.toString().trim().isNotEmpty) {
          return val.toString();
        }
      }
    }
    return fallback;
  }

  void _showComingSoon(String featureName) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '$featureName متاح قريبًا في صالون KOKI PARTY الفاخر ✨',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: luxurySurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: pureGold.withOpacity(0.55)),
        ),
      ),
    );
  }
    Widget _buildLuxuryProfileCard() {
    final shortId = formatShortId(currentUserId);
    final coinsBalance = _formatBalance([
      'coins',
      'coinBalance',
      'balance',
      'diamondsBalance',
    ]);
    final hostDiamonds = _formatBalance([
      'hostDiamonds',
      'diamonds',
      'earnings',
      'hostBalance',
    ]);
    final vipLevel = _formatBalance(
      ['vipLevel', 'vip'],
      fallback: 'VIP 👑',
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF421782),
            luxurySurface,
            luxuryObsidian,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: pureGold.withOpacity(0.65), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: pureGold.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // أفاتار ذهبي متعدد الطبقات
              Container(
                width: 68,
                height: 68,
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
                padding: const EdgeInsets.all(2.8),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: luxuryVoid,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [champagneGold, pureGold, antiqueGold],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            vipLevel.toString().startsWith('VIP')
                                ? vipLevel
                                : 'VIP $vipLevel',
                            style: const TextStyle(
                              color: luxuryVoid,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: pureGold.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: pureGold.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        'ID: $shortId',
                        style: const TextStyle(
                          color: champagneGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'تحديث البيانات',
                onPressed: loadAccountData,
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: champagneGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceTile(
                  'العملات الذهبية',
                  coinsBalance,
                  Icons.monetization_on_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBalanceTile(
                  'ألماس المضيف',
                  hostDiamonds,
                  Icons.diamond_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: luxuryVoid.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pureGold.withOpacity(0.38)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pureGold.withOpacity(0.16),
            ),
            child: Icon(icon, color: pureGold, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
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

  Widget _buildShortcutsGrid() {
    final shortcuts = [
      ('شحن الرصيد', Icons.account_balance_wallet_rounded, 'شحن الرصيد'),
      ('الوكالة', Icons.groups_rounded, 'إدارة الوكالة'),
      ('المتجر VIP', Icons.diamond_rounded, 'متجر VIP'),
      ('الدعوات', Icons.card_giftcard_rounded, 'مركز الدعوات'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: shortcuts.map((item) {
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _showComingSoon(item.$3),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [luxuryPanel, luxuryObsidian],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: pureGold.withOpacity(0.35)),
                ),
                child: Column(
                  children: [
                    Icon(item.$2, color: pureGold, size: 23),
                    const SizedBox(height: 6),
                    Text(
                      item.$1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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
    Widget _buildAccountMenu() {
    final menuItems = [
      (
        'الشارات والإطارات الفاخرة',
        'إطارات المقعد والشارات المميزة داخل الغرف',
        Icons.military_tech_rounded,
      ),
      (
        'سجل الهدايا والمعاملات',
        'متابعة الهدايا المرسلة والمستلمة في KOKI PARTY',
        Icons.history_rounded,
      ),
      (
        'الأمان والخصوصية',
        'إعدادات الحساب وحماية الجلسة',
        Icons.verified_user_rounded,
      ),
      (
        'الدعم والمساعدة',
        'تواصل مع فريق الدعم الخاص بالمنصة',
        Icons.support_agent_rounded,
      ),
    ];

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 16),
        children: [
          ...menuItems.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: luxuryPanel.withOpacity(0.75),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: pureGold.withOpacity(0.28)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pureGold.withOpacity(0.14),
                    border: Border.all(color: pureGold.withOpacity(0.35)),
                  ),
                  child: Icon(item.$3, color: pureGold, size: 20),
                ),
                title: Text(
                  item.$1,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  item.$2,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11.5,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: pureGold,
                  size: 14,
                ),
                onTap: () => _showComingSoon(item.$1),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.redAccent.withOpacity(0.45)),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              onTap: () async {
                AuthSession.accessToken = null;
                AuthSession.user = null;
                if (mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: luxuryVoid,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF06020F),
                    Color(0xFF1A0B3B),
                    Color(0xFF0C051F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _LuxuryProfileStarsPainter(),
              ),
            ),
            SafeArea(
              child: loading
                  ? const Center(
                      child: CircularProgressIndicator(color: pureGold),
                    )
                  : errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  color: pureGold,
                                  size: 42,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  errorMessage!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(height: 16),
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
                        )
                      : Column(
                          children: [
                            _buildLuxuryProfileCard(),
                            _buildShortcutsGrid(),
                            _buildAccountMenu(),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryProfileStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(108);

    for (int i = 0; i < 45; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * (size.height * 0.65);
      final radius = 0.7 + rng.nextDouble() * 1.6;
      final opacity = 0.14 + rng.nextDouble() * 0.45;

      starPaint.color = (i % 3 == 0
              ? const Color(0xFFFFF0B3)
              : Colors.white)
          .withOpacity(opacity);
      canvas.drawCircle(Offset(dx, dy), radius, starPaint);
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFC93C).withOpacity(0.12),
          const Color(0xFF9C5CFF).withOpacity(0.14),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.22),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.22),
      size.width * 0.6,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
