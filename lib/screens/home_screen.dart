import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../services/auth_session.dart';
import 'room_screen.dart';
import 'profile_screen.dart';

class LuxuryHomeScreen extends StatefulWidget {
  const LuxuryHomeScreen({super.key});

  @override
  State<LuxuryHomeScreen> createState() => _LuxuryHomeScreenState();
}

class _LuxuryHomeScreenState extends State<LuxuryHomeScreen> {
  static const String apiUrl = 'https://koki-party-new.onrender.com';

  // لوحة ألوان فاخرة متناسقة مع شاشة الغرفة
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

  int _bottomNavIndex = 0; // 0: الرئيسية، 1: اكتشف، 2: الرسائل، 3: حسابي
  int _topFeedTab = 1; // 0: غرفتي، 1: الأكثر رواجًا
  String _selectedRegion = 'ALL'; // ALL, EG, YE
  String _selectedCategory = 'رائج';
  String _searchQuery = '';

  

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

  String _formatHostLabel(Map<String, dynamic> roomItem) {
    final candidates = [
      roomItem['hostName'],
      roomItem['ownerName'],
      roomItem['creatorName'],
    ];
    for (final c in candidates) {
      final str = c?.toString().trim();
      if (str != null && str.isNotEmpty && !_looksLikeUuid(str)) {
        return str;
      }
    }
    final ownerId = roomItem['ownerUserId']?.toString() ??
        roomItem['hostUserId']?.toString();
    return 'مضيف #${formatShortId(ownerId)}';
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
    loadRooms();
  }

  Future<void> loadRooms() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final response = await apiRequest('GET', '/api/rooms');
      final rawList = response is Map
          ? (response['data'] ?? response['rooms'] ?? [])
          : (response ?? []);

      if (rawList is! List) {
        throw Exception('صيغة قائمة الغرف غير صحيحة');
      }

      if (!mounted) return;
      setState(() {
        _rooms = rawList
            .map>(
              (item) => Map<String, dynamic>.from(item as Map),
            )
            .toList();
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

  List<Map<String, dynamic>> get _filteredRooms {
  if (_searchQuery.isEmpty) {
    return _rooms;
  }

  return _rooms.where((room) {
    final name = (room['name'] ?? '').toString().toLowerCase();
    return name.contains(_searchQuery.toLowerCase());
  }).toList();
  }
    if (_selectedRegion != 'ALL') {
      final country = (roomItem['country'] ??
              roomItem['region'] ??
              roomItem['countryCode'] ??
              '')
          .toString()
          .toUpperCase();
      if (country.isNotEmpty && country != _selectedRegion) {
        return false;
      }
    }

    if (_selectedCategory == 'VIP') {
      final isVip = roomItem['isVip'] == true ||
          (roomItem['vipLevel'] is num && (roomItem['vipLevel'] as num) > 0);
      if (!isVip) return false;
    }

    return true;
  }).toList();
  }
  
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final title = (roomItem['title'] ?? '').toString().toLowerCase();
        final roomIdStr = (roomItem['id'] ?? '').toString().toLowerCase();
        final shortCode = formatShortId(roomItem['id']?.toString()).toLowerCase();
        final hostLabel = _formatHostLabel(roomItem).toLowerCase();

        final matches = title.contains(q) ||
            roomIdStr.contains(q) ||
            shortCode.contains(q) ||
            hostLabel.contains(q);
        if (!matches) return false;
      }

      return true;
    }).toList();
  }

  void _openRoom(Map<String, dynamic> roomItem) {
    final roomId = roomItem['id']?.toString() ?? '';
    if (roomId.isEmpty) return;

    final title = roomItem['title']?.toString().trim().isNotEmpty == true
        ? roomItem['title'].toString()
        : 'صالون #${formatShortId(roomId)}';
    final hostLabel = _formatHostLabel(roomItem);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomScreen(
          roomTitle: title,
          hostName: hostLabel,
          roomId: roomId,
        ),
      ),
    );
  }

  void _openSearchSheet() {
    final controller = TextEditingController(text: _searchQuery);
    showModalBottomSheet(
      context: context,
      backgroundColor: luxuryObsidian,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 18,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🔍 بحث في صالونات KOKI PARTY',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: champagneGold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث باسم الغرفة، المضيف، أو رقم ID...',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: luxuryPanel,
                prefixIcon: const Icon(Icons.search_rounded, color: pureGold),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: pureGold.withOpacity(0.45)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: champagneGold, width: 1.5),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: pureGold.withOpacity(0.35)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      setState(() => _searchQuery = '');
                      Navigator.pop(ctx);
                    },
                    child: const Text('مسح البحث'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pureGold,
                      foregroundColor: luxuryVoid,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'تطبيق',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
    Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _openSearchSheet,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: luxuryPanel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: pureGold.withOpacity(0.45)),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: champagneGold,
                size: 21,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildTopFeedSwitch('غرقتي', 0),
          const SizedBox(width: 16),
          _buildTopFeedSwitch('الأكثر رواجًا', 1),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  pureGold.withOpacity(0.22),
                  antiqueGold.withOpacity(0.14),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: pureGold.withOpacity(0.55)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, color: pureGold, size: 15),
                SizedBox(width: 4),
                Text(
                  'KOKI VIP',
                  style: TextStyle(
                    color: champagneGold,
                    fontSize: 11,
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

  Widget _buildTopFeedSwitch(String title, int index) {
    final active = _topFeedTab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _topFeedTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: active ? champagneGold : Colors.white60,
              fontSize: active ? 16 : 14,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 3,
            width: active ? 28 : 0,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [champagneGold, pureGold, antiqueGold],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuxuryBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3E167A),
            luxurySurface,
            Color(0xFF1A0A3B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: pureGold.withOpacity(0.65), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: pureGold.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: pureGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: pureGold.withOpacity(0.5)),
                  ),
                  child: const Text(
                    '✨ صالونات النخبة',
                    style: TextStyle(
                      color: champagneGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'أفخم السهرات الصوتية في KOKI PARTY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'تواصل مباشر، هدايا فاخرة، ومقاعد ملكية متجددة.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
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
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: luxuryVoid,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumStrip() {
    final podiums = [
      ('الجاذبية', Icons.favorite_rounded, const Color(0xFF5B1D8A)),
      ('الثروة', Icons.diamond_rounded, const Color(0xFF7A4908)),
      ('الغرفة', Icons.castle_rounded, const Color(0xFF281366)),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: podiums.map((item) {
          final label = item.$1;
          final icon = item.$2;
          final baseColor = item.$3;

          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    baseColor.withOpacity(0.9),
                    luxuryObsidian.withOpacity(0.95),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: pureGold.withOpacity(0.55), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text('👑', style: TextStyle(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      color: champagneGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (idx) {
                      final isCenter = idx == 1;
                      return Container(
                        width: isCenter ? 34 : 28,
                        height: isCenter ? 34 : 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [champagneGold, pureGold, antiqueGold],
                          ),
                          boxShadow: isCenter
                              ? [
                                  BoxShadow(
                                    color: pureGold.withOpacity(0.45),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: luxuryVoid,
                          ),
                          child: Icon(
                            icon,
                            size: isCenter ? 16 : 13,
                            color: champagneGold,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFiltersRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          _buildRegionChip('الكل', 'ALL'),
          const SizedBox(width: 8),
          _buildRegionChip('مصر 🇪🇬', 'EG'),
          const SizedBox(width: 8),
          _buildRegionChip('اليمن 🇾🇪', 'YE'),
          const Spacer(),
          _buildCategoryChip('رائج'),
          const SizedBox(width: 6),
          _buildCategoryChip('VIP'),
        ],
      ),
    );
  }

  Widget _buildRegionChip(String label, String code) {
    final active = _selectedRegion == code;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedRegion = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: active ? pureGold.withOpacity(0.22) : luxuryPanel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? champagneGold : pureGold.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? champagneGold : Colors.white70,
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final active = _selectedCategory == label;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [champagneGold, pureGold, antiqueGold],
                )
              : null,
          color: active ? null : luxuryPanel,
          borderRadius: BorderRadius.circular(14),
          border: active
              ? null
              : Border.all(color: pureGold.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? luxuryVoid : Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
    Widget _buildRoomsGrid() {
    final items = _filteredRooms;

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.meeting_room_outlined,
                color: pureGold.withOpacity(0.75),
                size: 46,
              ),
              const SizedBox(height: 10),
              const Text(
                'لا توجد غرف مطابقة للفلتر الحالي',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: champagneGold,
                  side: BorderSide(color: pureGold.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _topFeedTab = 1;
                    _selectedRegion = 'ALL';
                    _selectedCategory = 'رائج';
                    _searchQuery = '';
                  });
                },
                icon: const Icon(Icons.filter_alt_off_rounded, size: 18),
                label: const Text('إعادة ضبط الفلاتر'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: pureGold,
      backgroundColor: luxuryPanel,
      onRefresh: loadRooms,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 18),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.84,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final roomItem = items[index];
          final roomIdStr = roomItem['id']?.toString() ?? '$index';
          final shortCode = formatShortId(roomIdStr);
          final title = roomItem['title']?.toString().trim().isNotEmpty == true
              ? roomItem['title'].toString()
              : 'صالون #$shortCode';
          final hostLabel = _formatHostLabel(roomItem);
          final seatsCount = (roomItem['activeSeatsCount'] ??
                  roomItem['seatsCount'] ??
                  roomItem['occupiedSeats'] ??
                  0)
              .toString();
          final maxSeatsCount = (roomItem['maxSeats'] ?? 8).toString();
          final isVip = roomItem['isVip'] == true ||
              (roomItem['vipLevel'] is num &&
                  (roomItem['vipLevel'] as num) > 0);

          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _openRoom(roomItem),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    luxurySurface,
                    luxuryPanel,
                    luxuryObsidian,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isVip
                      ? champagneGold.withOpacity(0.85)
                      : pureGold.withOpacity(0.45),
                  width: isVip ? 1.6 : 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: pureGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: pureGold.withOpacity(0.55),
                          ),
                        ),
                        child: Text(
                          'ID: $shortCode',
                          style: const TextStyle(
                            color: champagneGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (isVip)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [champagneGold, pureGold, antiqueGold],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              color: luxuryVoid,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [champagneGold, pureGold, antiqueGold],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: pureGold.withOpacity(0.35),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(2.4),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: luxuryVoid,
                        ),
                        child: const Icon(
                          Icons.mic_external_on_rounded,
                          color: champagneGold,
                          size: 27,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    hostLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        color: pureGold.withOpacity(0.9),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$seatsCount/$maxSeatsCount',
                        style: const TextStyle(
                          color: champagneGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: pureGold,
                        size: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSecondaryTabPlaceholder(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [luxurySurface, luxuryPanel, luxuryObsidian],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: pureGold.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [champagneGold, pureGold, antiqueGold],
                  ),
                ),
                child: Icon(icon, color: luxuryVoid, size: 32),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: champagneGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: pureGold,
                  foregroundColor: luxuryVoid,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => setState(() => _bottomNavIndex = 0),
                child: const Text(
                  'العودة إلى الرئيسية',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final tabs = [
      ('الرئيسية', Icons.home_rounded, 0),
      ('اكتشف', Icons.explore_rounded, 1),
      ('الرسائل', Icons.chat_bubble_rounded, 2),
      ('حسابي', Icons.person_rounded, 3),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [luxuryObsidian, luxuryVoid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: pureGold.withOpacity(0.4)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: tabs.map((tab) {
          final label = tab.$1;
          final icon = tab.$2;
          final idx = tab.$3;
          final active = _bottomNavIndex == idx;

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _bottomNavIndex = idx),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [champagneGold, pureGold, antiqueGold],
                      )
                    : null,
                color: active ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: pureGold.withOpacity(0.35),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 19,
                    color: active ? luxuryVoid : Colors.white70,
                  ),
                  if (active) ...[
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: const TextStyle(
                        color: luxuryVoid,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHomeBody() {
    if (loading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: pureGold),
        ),
      );
    }

    if (errorMessage != null) {
      return Expanded(
        child: Center(
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
                  onPressed: loadRooms,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          _buildLuxuryBanner(),
          _buildPodiumStrip(),
          _buildFiltersRow(),
          Expanded(child: _buildRoomsGrid()),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_bottomNavIndex == 0) {
      bodyContent = Column(
        children: [
          _buildTopBar(),
          _buildHomeBody(),
        ],
      );
    } else if (_bottomNavIndex == 1) {
      bodyContent = _buildSecondaryTabPlaceholder(
        'اكتشف صالونات KOKI PARTY',
        'استكشف الفعاليات والغرف المميزة والوكالات المعتمدة قريبًا.',
        Icons.explore_rounded,
      );
    } else if (_bottomNavIndex == 2) {
      bodyContent = _buildSecondaryTabPlaceholder(
        'الرسائل والإشعارات',
        'صندوق الرسائل والتنبيهات الخاص بحسابك داخل التطبيق.',
        Icons.chat_bubble_rounded,
      );
    } else {
      bodyContent = _buildSecondaryTabPlaceholder(
        'حسابي الفاخر',
        'بيانات الحساب والرصيد والهدايا جاهزة للانتقال إلى شاشة الحساب الكاملة.',
        Icons.person_rounded,
      );
    }

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
                painter: _LuxuryHomeStarsPainter(),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(child: bodyContent),
                  _buildBottomNavBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LuxuryHomeStarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(77);

    for (int i = 0; i < 48; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * (size.height * 0.72);
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
          const Color(0xFFFFC93C).withOpacity(0.11),
          const Color(0xFF9C5CFF).withOpacity(0.14),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.2),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.2),
      size.width * 0.6,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
