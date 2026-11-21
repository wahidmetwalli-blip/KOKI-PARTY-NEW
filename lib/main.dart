
import 'package:flutter/material.dart';

void main() {
  runApp(const KokiPartyApp());
}

const Color bg = Color(0xFF100D1D);
const Color panel = Color(0xFF201A32);
const Color purple = Color(0xFF8054E8);
const Color blue = Color(0xFF3979D8);

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
        colorScheme: ColorScheme.dark(
          primary: purple,
          secondary: blue,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedTab = 0;
  int coins = 13800;

  final List<Map<String, dynamic>> rooms = [
    {'name': 'غرفة الملوك', 'users': 24, 'color': purple},
    {'name': 'مملكة KOKI', 'users': 126, 'color': blue},
    {'name': 'عالم الأصدقاء', 'users': 84, 'color': Color(0xFF9B4BCB)},
    {'name': 'سهرة الملوك', 'users': 52, 'color': Color(0xFF345B9B)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            homeContent(),
            simplePage('اكتشف', 'اكتشف أصدقاء وغرف جديدة'),
            simplePage('الرسائل', 'محادثاتك ورسائلك الخاصة'),
            simplePage('حسابي', 'ملفك الشخصي وإعدادات حسابك'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        indicatorColor: purple.withOpacity(0.3),
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'اكتشف',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'الرسائل',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  Widget homeContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: purple,
              child: Icon(Icons.graphic_eq, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KOKI PARTY',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    'THE ROYAL WORLD',
                    style: TextStyle(fontSize: 10, color: Colors.white60),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
            InkWell(
              onTap: () => showWallet(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.amber),
                    const SizedBox(width: 5),
                    Text('$coins'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              colors: [Color(0xFF39216D), Color(0xFF172C59)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME TO',
                style: TextStyle(color: Colors.white70, letterSpacing: 2),
              ),
              SizedBox(height: 5),
              Text(
                'KOKI PARTY',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('عالمك.. حفلتك 🎉'),
              SizedBox(height: 18),
              Text(
                'ادخل عالم الغرف الصوتية وتعرّف على أصدقاء جدد',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'خدمات KOKI',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            service(Icons.card_giftcard, 'الهدايا'),
            service(Icons.workspace_premium, 'VIP'),
            service(Icons.account_balance_wallet, 'المحفظة',
                action: showWallet),
            service(Icons.leaderboard, 'الترتيب'),
          ],
        ),
        const SizedBox(height: 26),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الغرف الصوتية',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => setState(() => selectedTab = 1),
              child: const Text('اكتشف الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...rooms.map((room) => roomCard(room)),
      ],
    );
  }

  Widget service(IconData icon, String name, {VoidCallback? action}) {
    return Expanded(
      child: InkWell(
        onTap: action ?? () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name - قريباً')),
          );
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: panel,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: purple, size: 27),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget roomCard(Map<String, dynamic> room) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomPage(roomName: room['name']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: room['color'],
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.graphic_eq, size: 30),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${room['users']} مستمع • 8 مقاعد',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget simplePage(String title, String description) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.graphic_eq, size: 55, color: purple),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(description, style: const TextStyle(color: Colors.white60)),
        ],
      ),
    );
  }

  void showWallet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('محفظة KOKI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Text('$coins عملة',
                style: const TextStyle(fontSize: 25, color: Colors.amber)),
            const SizedBox(height: 15),
            const Text('الشحن الحقيقي هيتم ربطه بنظام دفع آمن لاحقاً'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class RoomPage extends StatefulWidget {
  final String roomName;

  const RoomPage({super.key, required this.roomName});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  final List<String?> seats = [
    'المضيف',
    null,
    'صديق',
    null,
    null,
    null,
    null,
    null,
  ];

  bool muted = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: panel,
        title: Text(widget.roomName),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: panel,
            child: const Column(
              children: [
                Icon(Icons.graphic_eq, size: 40, color: purple),
                SizedBox(height: 8),
                Text('أهلاً بيكم في الغرفة'),
                SizedBox(height: 5),
                Text('احترم الجميع واستمتع بوقتك',
                    style: TextStyle(color: Colors.white60)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('مقاعد المتحدثين',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 22,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final name = seats[index];
                return InkWell(
                  onTap: () => seatAction(index),
                  child: Column(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: name == null ? panel : purple,
                          border: Border.all(
                            color: name == null ? Colors.white24 : purple,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          name == null ? Icons.add : Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        name ?? 'مقعد ${index + 1}',
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            color: panel,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                controlButton(
                  muted ? Icons.mic_off : Icons.mic,
                  muted ? 'فتح المايك' : 'كتم المايك',
                  () => setState(() => muted = !muted),
                ),
                controlButton(Icons.card_giftcard, 'هدايا', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الهدايا قريباً')),
                  );
                }),
                controlButton(Icons.chat, 'الدردشة', () {
                  showChat();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget controlButton(IconData icon, String label, VoidCallback action) {
    return InkWell(
      onTap: action,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: purple,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  void seatAction(int index) {
    if (seats[index] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('المقعد مشغول بالفعل')),
      );
      return;
    }

    setState(() => seats[index] = 'أنت');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حجز المقعد ${index + 1} تجريبياً')),
    );
  }

  void showChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: panel,
        title: const Text('دردشة الغرفة'),
        content: const Text('واجهة الدردشة هتتضاف في المرحلة الجاية'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
