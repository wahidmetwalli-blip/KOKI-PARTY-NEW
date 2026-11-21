import 'package:flutter/material.dart';
import 'create_room_screen.dart';
import 'room_screen.dart';

const Color bg = Color(0xFF090711);
const Color panel = Color(0xFF191529);
const Color gold = Color(0xFFD8B45A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;

  final List<Map<String, dynamic>> rooms = [
    {
      'name': 'غرفة الملوك',
      'owner': 'ملك الليل',
      'members': '124',
      'image': 'https://images.unsplash.com/photo-1519608487953-e999c86e7455?w=900',
    },
    {
      'name': 'مملكة KOKI',
      'owner': 'الأميرة',
      'members': '86',
      'image': 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=900',
    },
    {
      'name': 'عالم الأصدقاء',
      'owner': 'صاحب الغرفة',
      'members': '52',
      'image': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=900',
    },
    {
      'name': 'سهرة الملوك',
      'owner': 'VIP KING',
      'members': '39',
      'image': 'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=900',
    },
  ];

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: panel,
      ),
    );
  }

  void openCreateRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateRoomScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: IndexedStack(
            index: selectedTab,
            children: [
              homePage(),
              simplePage('اكتشف'),
              simplePage('الغرف'),
              simplePage('الرسائل'),
              simplePage('حسابي'),
            ],
          ),
        ),
        floatingActionButton: selectedTab == 0
            ? FloatingActionButton.extended(
                onPressed: openCreateRoom,
                backgroundColor: gold,
                foregroundColor: bg,
                icon: const Icon(Icons.add),
                label: const Text(
                  'إنشاء روم',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              )
            : null,
        bottomNavigationBar: bottomBar(),
      ),
    );
  }

  Widget homePage() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: header()),
        SliverToBoxAdapter(child: welcome()),
        SliverToBoxAdapter(child: shortcuts()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 15, 18, 12),
            child: Row(
              children: [
                const Text(
                  'الغرف الصوتية',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => selectedTab = 2),
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(color: gold),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => roomCard(rooms[index]),
            childCount: rooms.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: panel,
            child: Icon(
              Icons.workspace_premium,
              color: gold,
              size: 30,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KOKI PARTY',
                  style: TextStyle(
                    color: gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'THE ROYAL WORLD',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => showMessage('المحفظة هتتربط بنظام الشحن'),
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: gold),
              ),
              child: const Row(
                children: [
                  Icon(Icons.monetization_on, color: gold),
                  SizedBox(width: 5),
                  Text(
                    '100000',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget welcome() {
    return Container(
      height: 190,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF492D69),
            Color(0xFF171126),
            Color(0xFF30203D),
          ],
        ),
        border: Border.all(color: gold.withOpacity(0.5)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👑', style: TextStyle(fontSize: 38)),
          SizedBox(height: 8),
          Text(
            'WELCOME TO KOKI PARTY',
            style: TextStyle(
              color: gold,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'عالمك.. حفلتك.. مملكتك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget shortcuts() {
    final items = [
      ['الهدايا', Icons.card_giftcard],
      ['VIP', Icons.diamond],
      ['المحفظة', Icons.account_balance_wallet],
      ['الترتيب', Icons.emoji_events],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: items.map((item) {
          return InkWell(
            onTap: () => showMessage('قسم ${item[0]} قيد التجهيز'),
            child: Column(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: gold.withOpacity(0.4)),
                  ),
                  child: Icon(
                    item[1] as IconData,
                    color: gold,
                    size: 27,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  item[0] as String,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget roomCard(Map<String, dynamic> room) {
    return InkWell(
      onTap: () => showMessage(
        'هنفتح غرفة ${room['name']} بعد تجهيز شاشة الغرفة',
      ),
      child: Container(
        height: 190,
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: panel,
          border: Border.all(color: gold.withOpacity(0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              room['image'],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) {
                return Container(
                  color: const Color(0xFF30203D),
                  child: const Icon(
                    Icons.meeting_room,
                    color: gold,
                    size: 55,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.graphic_eq, color: gold, size: 16),
                    SizedBox(width: 5),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 15,
              right: 15,
              left: 15,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'المضيف: ${room['owner']}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '🎙 8 مقاعد  •  👥 ${room['members']}',
                          style: const TextStyle(
                            color: gold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios,
                    color: gold,
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget simplePage(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          color: gold,
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget bottomBar() {
    final items = [
      [Icons.home, 'الرئيسية'],
      [Icons.explore, 'اكتشف'],
      [Icons.meeting_room, 'الغرف'],
      [Icons.message, 'الرسائل'],
      [Icons.person, 'حسابي'],
    ];

    return Container(
      color: panel,
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final active = selectedTab == index;
            return InkWell(
              onTap: () => setState(() => selectedTab = index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[index][0] as IconData,
                      color: active ? gold : Colors.white54,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[index][1] as String,
                      style: TextStyle(
                        color: active ? gold : Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
