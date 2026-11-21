import 'package:flutter/material.dart';
import 'room_screen.dart';
import 'create_room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _selectedCategory = 0;

  final List<String> _categories = ['الكل 🔥', 'ملكية 👑', 'موسيقى 🎵', 'دردشة 💬'];

  final List<Map<String, dynamic>> _rooms = [
    {
      'title': 'غرفة الملوك VIP',
      'host': 'KOKI KING',
      'id': '10001',
      'listeners': 148,
      'tag': 'ملكية 👑',
      'color1': const Color(0xFF4A148C),
      'color2': const Color(0xFF1A0933),
    },
    {
      'title': 'سهرة طرب وموسيقى',
      'host': 'Royal Star',
      'id': '10024',
      'listeners': 92,
      'tag': 'موسيقى 🎵',
      'color1': const Color(0xFF311B92),
      'color2': const Color(0xFF120826),
    },
    {
      'title': 'عالم الأصدقاء والضحك',
      'host': 'Amira VIP',
      'id': '10058',
      'listeners': 64,
      'tag': 'دردشة 💬',
      'color1': const Color(0xFF6A1B9A),
      'color2': const Color(0xFF1E0B36),
    },
    {
      'title': 'تحدي الهدايا الكبير',
      'host': 'Night King',
      'id': '10099',
      'listeners': 215,
      'tag': 'ملكية 👑',
      'color1': const Color(0xFF880E4F),
      'color2': const Color(0xFF1F0722),
    },
  ];

  void _openCreateRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateRoomScreen()),
    );
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
          child: SafeArea(child: pages[_currentIndex]),
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            color: active ? const Color(0xFFFFD54F) : Colors.white54,
            size: 24,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xFFFFD54F) : Colors.white54,
              fontSize: 11,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
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
        style: const TextStyle(color: Colors.white70, fontSize: 18),
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
                colors: [Color(0xFFFFD54F), Color(0xFFE040FB), Color(0xFFFF6F00)],
              ),
            ),
            child: const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFF1D0D3B),
              child: Icon(Icons.person, color: Color(0xFFFFD54F), size: 46),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'KOKI USER',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'ID: 10134700  •  SVIP 3 👑',
              style: TextStyle(color: Color(0xFFFFD54F), fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF311B92)],
              ),
              border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFFD54F), size: 30),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الرصيد الحالي', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      '10,000 عملة',
                      style: TextStyle(color: Color(0xFFFFD54F), fontSize: 18, fontWeight: FontWeight.bold),
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
              _ProfileTile(icon: Icons.diamond_rounded, label: 'نادي VIP'),
              _ProfileTile(icon: Icons.storefront_rounded, label: 'الإطارات'),
              _ProfileTile(icon: Icons.card_giftcard_rounded, label: 'الهدايا'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFD54F), Color(0xFFFF6F00)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFF231642),
                  child: Icon(Icons.workspace_premium, color: Color(0xFFFFD54F)),
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
                    style: TextStyle(color: Colors.white54, fontSize: 10, letterSpacing: 1.5),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.monetization_on, color: Color(0xFFFFD54F), size: 18),
                    SizedBox(width: 6),
                    Text(
                      '10,000',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), Color(0xFF311B92), Color(0xFF1A0933)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7B1FA2).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
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
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome, color: Color(0xFFFFD54F), size: 32),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _quickCard('الفعاليات', 'جوائز يومية', Icons.celebration, const [Color(0xFFFF6F00), Color(0xFFD84315)]),
              const SizedBox(width: 10),
              _quickCard('نادي VIP', 'إطارات ملكية', Icons.diamond, const [Color(0xFF8E24AA), Color(0xFF4A148C)]),
              const SizedBox(width: 10),
              _quickCard('المتجر', 'هدايا وسيارات', Icons.storefront, const [Color(0xFF00838F), Color(0xFF004D40)]),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = _selectedCategory == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: selected
                          ? const LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFFA000)])
                          : null,
                      color: selected ? null : Colors.white.withValues(alpha: 0.08),
                    ),
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color: selected ? const Color(0xFF120826) : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _rooms.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.86,
            ),
            itemBuilder: (context, index) {
              final room = _rooms[index];
              final String title = room['title'] as String;
              final String host = room['host'] as String;
              final String id = room['id'] as String;
              final String tag = room['tag'] as String;
              final int listeners = room['listeners'] as int;
              final Color color1 = room['color1'] as Color;
              final Color color2 = room['color2'] as Color;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoomScreen(
                        roomTitle: title,
                        hostName: host,
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
                      colors: [color1, color2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(color: Color(0xFFFFD54F), fontSize: 10),
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.graphic_eq, color: Color(0xFFFFD54F), size: 15),
                              const SizedBox(width: 3),
                              Text(
                                '$listeners',
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                              ),
                            ],
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
                              colors: [Color(0xFFFFD54F), Color(0xFFE040FB)],
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 26,
                            backgroundColor: Color(0xFF140B29),
                            child: Icon(Icons.person, color: Color(0xFFFFD54F), size: 28),
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
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'المضيف: $host',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickCard(String title, String sub, IconData icon, List<Color> colors) {
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
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            Text(
              sub,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
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
