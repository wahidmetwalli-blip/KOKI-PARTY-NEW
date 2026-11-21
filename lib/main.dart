import 'package:flutter/material.dart';

void main() {
  runApp(const KokiPartyApp());
}

// ألوان التطبيق
const Color bg = Color(0xFF0B0915);
const Color panel = Color(0xFF191529);
const Color panel2 = Color(0xFF231D38);
const Color purple = Color(0xFF8957F5);
const Color blue = Color(0xFF397FE8);
const Color pink = Color(0xFFCE58C9);
const Color muted = Color(0xFFAAA5BC);

class KokiPartyApp extends StatelessWidget {
  const KokiPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KOKI PARTY',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// الصفحة الرئيسية
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;
  int coins = 10000;

  final List<Map<String, dynamic>> rooms = [
    {
      'name': 'غرفة الملوك',
      'host': 'المضيف الرئيسي',
      'members': '24',
      'color': purple,
      'icon': Icons.diamond,
    },
    {
      'name': 'مملكة KOKI',
      'host': 'KOKI HOST',
      'members': '126',
      'color': blue,
      'icon': Icons.mic,
    },
    {
      'name': 'عالم الأصدقاء',
      'host': 'Friend Group',
      'members': '84',
      'color': pink,
      'icon': Icons.people,
    },
    {
      'name': 'سهرة الملوك',
      'host': 'Royal Host',
      'members': '52',
      'color': purple,
      'icon': Icons.nightlife,
    },
    {
      'name': 'نجوم الليل',
      'host': 'Night Stars',
      'members': '39',
      'color': blue,
      'icon': Icons.star,
    },
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: panel2,
      ),
    );
  }

  void showWallet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'محفظتي',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.account_balance_wallet,
                color: purple,
                size: 55,
              ),
              const SizedBox(height: 12),
              const Text(
                'رصيد العملات',
                style: TextStyle(color: muted),
              ),
              const SizedBox(height: 8),
              Text(
                '$coins',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    showMessage('الشحن التجريبي غير متصل بالدفع الحقيقي');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('شحن العملات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void openRoom(String roomName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPage(roomName: roomName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: selectedTab,
            children: [
              buildHome(),
              buildDiscover(),
              buildMessages(),
              buildProfile(),
            ],
          ),
        ),
        bottomNavigationBar: bottomNavigation(),
      ),
    );
  }

  // واجهة الرئيسية
  Widget buildHome() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: topBar()),
        SliverToBoxAdapter(child: welcomeBanner()),
        SliverToBoxAdapter(child: servicesSection()),
        SliverToBoxAdapter(child: roomsTitle()),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final room = rooms[index];
              return roomCard(room);
            },
            childCount: rooms.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  // الشريط العلوي
  Widget topBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [purple, blue],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.graphic_eq,
              color: Colors.white,
              size: 27,
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'THE ROYAL WORLD',
                  style: TextStyle(
                    color: muted,
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: showWallet,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: panel2,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: purple.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.amber,
                    size: 19,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
              showMessage('مفيش إشعارات جديدة');
            },
            icon: const Icon(
              Icons.notifications_none,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // بانر الترحيب
  Widget welcomeBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: const EdgeInsets.all(20),
      height: 155,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF5132A0),
            Color(0xFF25205B),
            Color(0xFF17152D),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: purple.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'WELCOME TO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'KOKI PARTY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'عالمك.. حفلتك.. أصحابك',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = 1;
                    });
                  },
                  child: const Text(
                    'اكتشف دلوقتي  ←',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.headphones,
            color: Colors.white,
            size: 75,
          ),
        ],
      ),
    );
  }

  // الخدمات السريعة
  Widget servicesSection() {
    final services = [
      {
        'name': 'الغرف',
        'icon': Icons.mic,
        'color': purple,
      },
      {
        'name': 'الهدايا',
        'icon': Icons.card_giftcard,
        'color': pink,
      },
      {
        'name': 'VIP',
        'icon': Icons.workspace_premium,
        'color': Colors.amber,
      },
      {
        'name': 'المحفظة',
        'icon': Icons.account_balance_wallet,
        'color': blue,
      },
      {
        'name': 'الترتيب',
        'icon': Icons.leaderboard,
        'color': Colors.orange,
      },
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'الخدمات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'KOKI PARTY',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final item = services[index];
              return GestureDetector(
                onTap: () {
                  if (index == 3) {
                    showWallet();
                  } else {
                    showMessage(
                      'قسم ${item['name']} - نسخة تجريبية',
                    );
                  }
                },
                child: Container(
                  width: 72,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: (item['color'] as Color)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: (item['color'] as Color)
                                .withOpacity(0.5),
                          ),
                        ),
                        child: Icon(
                          item['icon'] as IconData,
                          color: item['color'] as Color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item['name'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // عنوان الغرف
  Widget roomsTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'الغرف الصوتية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                selectedTab = 1;
              });
            },
            child: const Text(
              'عرض الكل',
              style: TextStyle(
                color: purple,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بطاقة الغرفة
  Widget roomCard(Map<String, dynamic> room) {
    final Color roomColor = room['color'] as Color;

    return GestureDetector(
      onTap: () => openRoom(room['name'] as String),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 5, 16, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: roomColor.withOpacity(0.35),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    roomColor,
                    roomColor.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                room['icon'] as IconData,
                color: Colors.white,
                size: 29,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    room['host'] as String,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: muted,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        room['members'] as String,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.mic,
                        color: blue,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '8 مقاعد',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: muted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // صفحة الاكتشاف
  Widget buildDiscover() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'اكتشف KOKI PARTY',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'اختار غرفة وابدأ سهرتك',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 20),
        ...rooms.map((room) => roomCard(room)),
      ],
    );
  }

  // صفحة الرسائل
  Widget buildMessages() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.chat_bubble_outline,
            color: purple,
            size: 65,
          ),
          SizedBox(height: 15),
          Text(
            'الرسائل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'مفيش رسائل جديدة دلوقتي',
            style: TextStyle(color: muted),
          ),
        ],
      ),
    );
  }

  // صفحة الحساب
  Widget buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 25),
        const CircleAvatar(
          radius: 48,
          backgroundColor: panel2,
          child: Icon(
            Icons.person,
            color: purple,
            size: 55,
          ),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'KOKI USER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Center(
     const SizedBox(height: 15),
        const Center(
          child: Text(
            'KOKI USER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text(
            'ID: 1000001',
            style: TextStyle(color: muted),
          ),
        ),
        const SizedBox(height: 25),
        profileOption(
          Icons.account_balance_wallet,
          'المحفظة',
          showWallet,
        ),
        profileOption(
          Icons.workspace_premium,
          'عضوية VIP',
          () => showMessage('قسم VIP تجريبي'),
        ),
        profileOption(
          Icons.people,
          'الأصدقاء',
          () => showMessage('قسم الأصدقاء تجريبي'),
        ),
        profileOption(
          Icons.settings,
          'الإعدادات',
          () => showMessage('الإعدادات قريباً'),
        ),
      ],
    );
  }

  Widget profileOption(
    IconData icon,
    String title,
    VoidCallback action,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: action,
        leading: Icon(icon, color: purple),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: muted,
          size: 15,
        ),
      ),
    );
  }

  // شريط التنقل السفلي
  Widget bottomNavigation() {
    final items = [
      {'icon': Icons.home, 'name': 'الرئيسية'},
      {'icon': Icons.explore, 'name': 'اكتشف'},
      {'icon': Icons.chat, 'name': 'الرسائل'},
      {'icon': Icons.person, 'name': 'حسابي'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: panel,
        border: Border(
          top: BorderSide(color: Colors.white10),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: List.generate(items.length, (index) {
            final active = selectedTab == index;

            return Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedTab = index;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index]['icon'] as IconData,
                        color: active ? purple : muted,
                        size: 23,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        items[index]['name'] as String,
                        style: TextStyle(
                          color: active ? purple : muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
        }
        // ==========================================
// صفحة الغرفة الصوتية
// ==========================================

class RoomPage extends StatefulWidget {
  final String roomName;

  const RoomPage({
    super.key,
    required this.roomName,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  bool muted = true;

  final List<String?> seats = List<String?>.filled(8, null);

  final List<String> chatMessages = [
    'أهلاً بيكم في KOKI PARTY ❤️',
    'نورتوا الغرفة يا أصدقاء',
  ];

  void showRoomMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
        ),
        backgroundColor: panel2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: panel,
          elevation: 0,
          title: Text(
            widget.roomName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showRoomMessage('تم فتح معلومات الغرفة');
              },
              icon: const Icon(Icons.info_outline),
            ),
            IconButton(
              onPressed: () {
                showRoomMessage('تم فتح قائمة الغرفة');
              },
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(
          children: [
            roomHeader(),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'مقاعد الصوت',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '8 مقاعد',
                    style: TextStyle(color: muted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: 8,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 18,
                  childAspectRatio: 0.80,
                ),
                itemBuilder: (context, index) {
                  return seatWidget(index);
                },
              ),
            ),

            roomControls(),
          ],
        ),
      ),
    );
  }

  // معلومات الغرفة
  Widget roomHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF5132A0),
            Color(0xFF191529),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: purple.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.roomName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'أهلاً بيكم في غرفة KOKI PARTY',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 15),
          Row(
            children: const [
              Icon(
                Icons.people,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                'غرفة اجتماعية',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(width: 18),
              Icon(
                Icons.mic,
                color: Colors.white,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                '8 مقاعد صوت',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // شكل المقعد
  Widget seatWidget(int index) {
    final String? seatName = seats[index];
    final bool occupied = seatName != null;

    return GestureDetector(
      onTap: () {
        seatAction(index);
      },
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: occupied
                  ? purple.withOpacity(0.3)
                  : panel2,
              border: Border.all(
                color: occupied ? purple : Colors.white24,
                width: 2,
              ),
            ),
            child: Icon(
              occupied ? Icons.person : Icons.add,
              color: occupied ? Colors.white : muted,
              size: 29,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            seatName ?? 'مقعد ${index + 1}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),

          const SizedBox(height: 5),

          Icon(
            occupied ? Icons.mic : Icons.mic_none,
            color: occupied ? blue : muted,
            size: 17,
          ),
        ],
      ),
    );
  }

  // اختيار المقعد
  void seatAction(int index) {
    if (seats[index] == 'أنت') {
      setState(() {
        seats[index] = null;
        muted = true;
      });

      showRoomMessage('غادرت مقعد الصوت');
      return;
    }

    if (seats[index] != null) {
      showRoomMessage('المقعد محجوز بالفعل');
      return;
    }

    if (seats.contains('أنت')) {
      showRoomMessage('أنت بالفعل على مقعد صوت');
      return;
    }

    setState(() {
      seats[index] = 'أنت';
      muted = true;
    });

    showRoomMessage('تم حجز مقعدك التجريبي');
  }

  // أزرار التحكم
  Widget roomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 20),
      decoration: const BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          controlButton(
            icon: muted ? Icons.mic_off : Icons.mic,
            label: muted ? 'فتح المايك' : 'كتم المايك',
            onTap: () {
              if (!seats.contains('أنت')) {
                showRoomMessage('احجز مقعد الأول');
                return;
              }

              setState(() {
                muted = !muted;
              });

              showRoomMessage(
                muted ? 'تم كتم المايك' : 'تم فتح المايك التجريبي',
              );
            },
          ),

          controlButton(
            icon: Icons.card_giftcard,
            label: 'الهدايا',
            onTap: showGifts,
          ),

          controlButton(
            icon: Icons.chat_bubble_outline,
            label: 'الدردشة',
            onTap: showChat,
          ),

          controlButton(
            icon: Icons.exit_to_app,
            label: 'خروج',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: panel2,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: purple,
              size: 23,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // قائمة الهدايا
  void showGifts() {
    final gifts = [
      {
        'name': 'وردة',
        'icon': '🌹',
        'price': 10,
      },
      {
        'name': 'قلب',
        'icon': '❤️',
        'price': 50,
      },
      {
        'name': 'نجمة',
        'icon': '⭐',
        'price': 100,
      },
      {
        'name': 'تاج',
        'icon': '👑',
        'price': 500,
      },
      {
        'name': 'ألماسة',
        'icon': '💎',
        'price': 1000,
      },
      {
        'name': 'سيارة',
        'icon': '🏎️',
        'price': 5000,
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'هدايا KOKI PARTY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: gifts.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  final gift = gifts[index];

                  return GestureDetector(
                    onTap: () {
                      final int price = gift['price'] as int;

                      if (coins < price) {
                        Navigator.pop(sheetContext);
                        showRoomMessage('رصيدك مش كفاية');
                        return;
                      }

                      setState(() {
                        coins -= price;
                      });

                      Navigator.pop(sheetContext);

                      showRoomMessage(
                        'تم إرسال ${gift['name']} ${gift['icon']} تجريبياً',
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: panel2,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            gift['icon'] as String,
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            gift['name'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${gift['price']} عملة',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  // الدردشة
  void showChat() {
    final TextEditingController controller =
        TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, updateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SizedBox(
                height: 390,
                child: Column(
                  children: [
                    const Text(
                      'دردشة الغرفة',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Expanded(
                      child: ListView.builder(
                        itemCount: chatMessages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 9),
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: panel2,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              chatMessages[index],
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              hintText: 'اكتب رسالتك...',
                              hintStyle: const TextStyle(
                                color: muted,
                              ),
                              filled: true,
                              fillColor: panel2,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        IconButton(
                          onPressed: () {
                            final message = controller.text.trim();

                            if (message.isEmpty) {
                              return;
                            }

                            updateSheet(() {
                              chatMessages.add('أنت: $message');
                            });

                            controller.clear();
                          },
                          icon: const Icon(
                            Icons.send,
                            color: purple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
