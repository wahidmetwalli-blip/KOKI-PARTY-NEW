import 'package:flutter/material.dart';

import 'create_room_screen.dart';
import 'room_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color bg = Color(0xFF090711);
  static const Color panel = Color(0xFF191529);
  static const Color gold = Color(0xFFFFD36A);
  static const Color purple = Color(0xFF8957F5);

  int selectedIndex = 0;
  int coins = 10000;

  final List<Map<String, dynamic>> rooms = [
    {
      'name': 'غرفة الملوك',
      'owner': 'KOKI KING',
      'description': 'أهلاً بيكم في غرفة الملوك',
      'members': 24,
      'speakers': 3,
      'icon': Icons.workspace_premium,
      'isPrivate': false,
      'hasPassword': false,
      'password': '',
      'allowRequests': true,
    },
    {
      'name': 'مملكة KOKI',
      'owner': 'Royal Star',
      'description': 'المملكة الملكية',
      'members': 126,
      'speakers': 5,
      'icon': Icons.diamond,
      'isPrivate': false,
      'hasPassword': false,
      'password': '',
      'allowRequests': true,
    },
    {
      'name': 'عالم الأصدقاء',
      'owner': 'Friends',
      'description': 'غرفة الأصدقاء',
      'members': 84,
      'speakers': 4,
      'icon': Icons.groups,
      'isPrivate': false,
      'hasPassword': false,
      'password': '',
      'allowRequests': true,
    },
    {
      'name': 'سهرة الملوك',
      'owner': 'Night King',
      'description': 'سهرة ملكية',
      'members': 52,
      'speakers': 2,
      'icon': Icons.nightlight_round,
      'isPrivate': false,
      'hasPassword': false,
      'password': '',
      'allowRequests': true,
    },
  ];

  Future<void> openCreateRoom() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateRoomScreen(),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      result['members'] = 1;
      result['speakers'] = 1;
      result['icon'] = Icons.meeting_room;
      rooms.insert(0, result);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنشاء الغرفة بنجاح 👑'),
      ),
    );
  }

  void openRoom(Map<String, dynamic> room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomScreen(
          roomName: room['name']?.toString() ?? 'غرفة جديدة',
          roomData: room,
        ),
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
            index: selectedIndex,
            children: [
              homePage(),
              discoverPage(),
              messagesPage(),
              accountPage(),
            ],
          ),
        ),
        bottomNavigationBar: bottomBar(),
        floatingActionButton: selectedIndex == 0
            ? FloatingActionButton(
                backgroundColor: gold,
                foregroundColor: bg,
                onPressed: openCreateRoom,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget homePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        header(),
        const SizedBox(height: 22),
        welcomeBanner(),
        const SizedBox(height: 22),
        shortcuts(),
        const SizedBox(height: 25),
        sectionTitle('الغرف الصوتية'),
        const SizedBox(height: 12),
        ...rooms.map((room) => roomCard(room)),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget header() {
    return Row(
      children: [
        const Icon(
          Icons.workspace_premium,
          color: gold,
          size: 38,
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KOKI PARTY',
                style: TextStyle(
                  color: gold,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'THE ROYAL WORLD',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 9,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: gold),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.monetization_on,
                color: gold,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                '$coins',
                style: const TextStyle(
                  color: gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget welcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF352052),
            Color(0xFF171126),
            Color(0xFF0D0A16),
          ],
        ),
        border: Border.all(
          color: gold.withOpacity(0.4),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WELCOME TO',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'KOKI PARTY 👑',
            style: TextStyle(
              color: gold,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'عالمك.. حفلتك.. مملكتك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget shortcuts() {
    final items = [
      {'name': 'الغرف', 'icon': Icons.mic},
      {'name': 'الهدايا', 'icon': Icons.card_giftcard},
      {'name': 'VIP', 'icon': Icons.diamond},
      {
        'name': 'المحفظة',
        'icon': Icons.account_balance_wallet,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (index == 0) {
              setState(() => selectedIndex = 0);
            } else {
              showInfo(items[index]['name'] as String);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: gold.withOpacity(0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  items[index]['icon'] as IconData,
                  color: gold,
                  size: 27,
                ),
                const SizedBox(height: 8),
                Text(
                  items[index]['name'] as String,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: gold,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget roomCard(Map<String, dynamic> room) {
    return InkWell(
      onTap: () => openRoom(room),
      borderRadius: BorderRadius.circular(17),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: gold.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: purple.withOpacity(0.25),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                room['icon'] is IconData
                    ? room['icon'] as IconData
                    : Icons.meeting_room,
                color: gold,
                size: 29,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room['name']?.toString() ?? 'غرفة جديدة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'المضيف: ${room['owner'] ?? 'KOKI USER'}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${room['speakers'] ?? 0} متحدثين • '
                    '${room['members'] ?? 0} مستمع',
                    style: const TextStyle(
                      color: gold,
                      fontSize: 11,
                    ),
                  ),
                  if (room['isPrivate'] == true)
                    const Text(
                      'غرفة خاصة 🔒',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios,
              color: gold,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget discoverPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.explore,
            color: gold,
            size: 65,
          ),
          const SizedBox(height: 15),
          const Text(
            'اكتشف الغرف',
            style: TextStyle(
              color: gold,
              fontSize: 23,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              setState(() => selectedIndex = 0);
            },
            child: const Text('عرض الغرف'),
          ),
        ],
      ),
    );
  }

  Widget messagesPage() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message,
            color: gold,
            size: 65,
          ),
          SizedBox(height: 15),
          Text(
            'الرسائل',
            style: TextStyle(
              color: gold,
              fontSize: 23,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'قريباً: المحادثات الخاصة والأصدقاء',
            style: TextStyle(
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget accountPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: purple,
            child: Icon(
              Icons.person,
              color: gold,
              size: 45,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'KOKI USER',
            style: TextStyle(
              color: gold,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'رصيدك: $coins عملة',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget bottomBar() {
    final labels = [
      'الرئيسية',
      'اكتشف',
      'الرسائل',
      'حسابي',
    ];

    final icons = [
      Icons.home,
      Icons.explore,
      Icons.message,
      Icons.person,
    ];

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: (index) {
        setState(() {
          selectedIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: panel,
      selectedItemColor: gold,
      unselectedItemColor: Colors.white54,
      items: List.generate(
        labels.length,
        (index) => BottomNavigationBarItem(
          icon: Icon(icons[index]),
          label: labels[index],
        ),
      ),
    );
  }

  void showInfo(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title: القسم قيد التجهيز'),
      ),
    );
  }
}
