import 'dart:convert';
import 'dart:io';

import 'agent_payout_screen.dart';
import 'package:flutter/material.dart';
import 'room_screen.dart';
import 'create_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String apiUrl =
      'https://koki-party-new.onrender.com/api/rooms';

  int _currentIndex = 0;

  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    HttpClient? client;

    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 25);

      final request = await client.getUrl(Uri.parse(apiUrl));
      final response = await request.close().timeout(
        const Duration(seconds: 35),
      );

      final responseText =
          await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw Exception('فشل تحميل الغرف');
      }

      final dynamic decoded = jsonDecode(responseText);

      if (decoded is! List) {
        throw Exception('بيانات الغرف غير صحيحة');
      }

      final loadedRooms = decoded
          .whereType<Map>()
          .map((room) => Map<String, dynamic>.from(room))
          .where((room) =>
              room['id'] != null && room['name'] != null)
          .toList();

      if (!mounted) return;

      setState(() {
        _rooms = loadedRooms;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'تعذر تحميل الغرف. تأكد من الإنترنت وحاول تاني.';
      });
    } finally {
      client?.close(force: true);
    }
  }

  void _openCreateRoom() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateRoomScreen(),
      ),
    );

    _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeBody(),
      _buildPlaceholderPage('استكشاف الفعاليات والتحديات ✨'),
      _buildPlaceholderPage('الرسائل الخاصة 💬'),
      _buildProfileTab(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0C061A),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1D0D3B),
                Color(0xFF0C061A),
                Color(0xFF080412),
              ],
            ),
          ),
          child: SafeArea(
            child: pages[_currentIndex],
          ),
        ),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: _openCreateRoom,
                backgroundColor: const Color(0xFFFFD54F),
                foregroundColor: const Color(0xFF120826),
                shape: const CircleBorder(),
                child: const Icon(Icons.mic_rounded, size: 30),
              )
            : null,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xFF140B29),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(Icons.home_rounded, 'الرئيسية', 0),
                _navItem(Icons.explore_rounded, 'اكتشف', 1),
                const SizedBox(width: 40),
                _navItem(Icons.chat_bubble_rounded, 'الرسائل', 2),
                _navItem(Icons.person_rounded, 'حسابي', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final active = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active
                ? const Color(0xFFFFD54F)
                : Colors.white54,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: active
                  ? const Color(0xFFFFD54F)
                  : Colors.white54,
              fontSize: 11,
              fontWeight:
                  active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderPage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 18,
        ),
      ),
    );
  }
    Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD54F),
                  Color(0xFFE040FB),
                  Color(0xFFFF6F00),
                ],
              ),
            ),
            child: const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFF1D0D3B),
              child: Icon(
                Icons.person,
                color: Color(0xFFFFD54F),
                size: 46,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'KOKI USER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'KOKI PARTY MEMBER 👑',
              style: TextStyle(
                color: Color(0xFFFFD54F),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6A1B9A),
                  Color(0xFF311B92),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFD54F)
                    .withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFFFFD54F),
                  size: 30,
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المحفظة',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'تفاصيل الرصيد قريباً',
                      style: TextStyle(
                        color: Color(0xFFFFD54F),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: const [
              _ProfileTile(
                icon: Icons.diamond_rounded,
                label: 'نادي VIP',
              ),
              _ProfileTile(
                icon: Icons.storefront_rounded,
                label: 'الإطارات',
              ),
              _ProfileTile(
                icon: Icons.card_giftcard_rounded,
                label: 'الهدايا',
              ),
            ],
          ),
        ],
      ),
    );
  }          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AgentPayoutScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('أرباح وكيل الشحن وطلبات السحب'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD54F),
                foregroundColor: const Color(0xFF120826),
              ),
            ),
          ),

  Widget _buildHomeBody() {
    return RefreshIndicator(
      color: const Color(0xFFFFD54F),
      backgroundColor: const Color(0xFF1D0D3B),
      onRefresh: _loadRooms,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 18),
            _buildWelcomeBanner(),
            const SizedBox(height: 18),
            Row(
              children: [
                _quickCard(
                  'الفعاليات',
                  'جوائز يومية',
                  Icons.celebration,
                  const [
                    Color(0xFFFF6F00),
                    Color(0xFFD84315),
                  ],
                ),
                const SizedBox(width: 10),
                _quickCard(
                  'نادي VIP',
                  'إطارات ملكية',
                  Icons.diamond,
                  const [
                    Color(0xFF8E24AA),
                    Color(0xFF4A148C),
                  ],
                ),
                const SizedBox(width: 10),
                _quickCard(
                  'المتجر',
                  'هدايا وسيارات',
                  Icons.storefront,
                  const [
                    Color(0xFF00838F),
                    Color(0xFF004D40),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الغرف الصوتية 👑',
                  style: TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _loadRooms,
                  icon: const Icon(
                    Icons.refresh,
                    color: Color(0xFFFFD54F),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildRoomsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFD54F),
                Color(0xFFFF6F00),
              ],
            ),
          ),
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFF231642),
            child: Icon(
              Icons.workspace_premium,
              color: Color(0xFFFFD54F),
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KOKI PARTY',
              style: TextStyle(
                color: Color(0xFFFFD54F),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'THE ROYAL WORLD',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFFD54F)
                  .withValues(alpha: 0.5),
            ),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.monetization_on,
                color: Color(0xFFFFD54F),
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                'المحفظة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6A1B9A),
            Color(0xFF311B92),
            Color(0xFF1A0933),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: const Color(0xFFFFD54F)
              .withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'موسم الملوك والهدايا 👑',
                  style: TextStyle(
                    color: Color(0xFFFFD54F),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'ادخل الغرف الصوتية، شارك المايك، وأرسل هدايا ملكية حصرية الآن',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Icon(
            Icons.auto_awesome,
            color: Color(0xFFFFD54F),
            size: 42,
          ),
        ],
      ),
    );
  }
    Widget _buildRoomsContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(35),
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFFD54F),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return _buildMessageBox(
        icon: Icons.wifi_off,
        message: _errorMessage!,
        buttonText: 'إعادة المحاولة',
        onPressed: _loadRooms,
      );
    }

    if (_rooms.isEmpty) {
      return _buildMessageBox(
        icon: Icons.meeting_room_outlined,
        message:
            'مفيش غرف صوتية حالياً.\nكن أول شخص ينشئ غرفة في KOKI PARTY!',
        buttonText: 'إنشاء غرفة',
        onPressed: _openCreateRoom,
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _rooms.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.86,
      ),
      itemBuilder: (context, index) {
        return _buildRoomCard(_rooms[index], index);
      },
    );
  }

  Widget _buildMessageBox({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF19112B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFD54F)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD54F),
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD54F),
              foregroundColor: const Color(0xFF120826),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(
    Map<String, dynamic> room,
    int index,
  ) {
    final String title =
        room['name']?.toString() ?? 'غرفة جديدة';

    final String id = room['id'].toString();

    final String ownerId =
        room['ownerUserId']?.toString() ?? 'غير معروف';

    final int maxSeats =
        int.tryParse(room['maxSeats']?.toString() ?? '') ?? 8;

    final colors = [
      const [Color(0xFF4A148C), Color(0xFF1A0933)],
      const [Color(0xFF311B92), Color(0xFF120826)],
      const [Color(0xFF6A1B9A), Color(0xFF1E0B36)],
      const [Color(0xFF880E4F), Color(0xFF1F0722)],
    ];

    final roomColors = colors[index % colors.length];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomScreen(
              roomTitle: title,
              hostName: ownerId,
              roomId: id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: roomColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'غرفة صوتية 👑',
                    style: TextStyle(
                      color: Color(0xFFFFD54F),
                      fontSize: 10,
                    ),
                  ),
                ),
                const Icon(
                  Icons.graphic_eq,
                  color: Color(0xFFFFD54F),
                  size: 18,
                ),
              ],
            ),
            const Spacer(),
            Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFD54F),
                      Color(0xFFE040FB),
                    ],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 26,
                  backgroundColor: Color(0xFF140B29),
                  child: Icon(
                    Icons.mic,
                    color: Color(0xFFFFD54F),
                    size: 28,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'المقاعد: $maxSeats',
              style: const TextStyle(
                color: Color(0xFFFFD54F),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'المالك: ${ownerId.length > 12 ? ownerId.substring(0, 12) : ownerId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickCard(
    String title,
    String sub,
    IconData icon,
    List<Color> colors,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(colors: colors),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              sub,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ProfileTile({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD54F),
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
