
import 'package:flutter/material.dart';

void main() {
  runApp(const KokiPartyApp());
}

const Color bg = Color(0xFF100D1C);
const Color card = Color(0xFF1D1830);
const Color purple = Color(0xFF8155E8);
const Color blue = Color(0xFF3979E8);
const Color white = Color(0xFFF5F2FF);
const Color muted = Color(0xFFAAA3BD);

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        fontFamily: 'Arial',
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

  final List<Map<String, String>> rooms = [
    {'name': 'غرفة الملوك', 'host': 'الملك أحمد', 'users': '24'},
    {'name': 'مملكة KOKI', 'host': 'KOKI HOST', 'users': '126'},
    {'name': 'عالم الأصدقاء', 'host': 'سارة', 'users': '84'},
    {'name': 'سهرة الملوك', 'host': 'محمد', 'users': '52'},
  ];

  void openRoom(Map<String, String> room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RoomPage(room: room),
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
              homeContent(),
              simplePage('اكتشف', Icons.explore),
              simplePage('الرسائل', Icons.chat_bubble_outline),
              simplePage('حسابي', Icons.person_outline),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          backgroundColor: const Color(0xFF191428),
          indicatorColor: purple.withValues(alpha: 0.25),
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
              icon: Icon(Icons.chat_outlined),
              label: 'الرسائل',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  Widget homeContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [purple, blue],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.mic, color: white, size: 27),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KOKI PARTY',
                    style: TextStyle(
                      color: white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'عالمك.. حفلتك',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => showMessage('المحفظة - نسخة تجريبية'),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.monetization_on, color: Colors.amber),
                    SizedBox(width: 5),
                    Text('13,800', style: TextStyle(color: white)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Color(0xFF49318B), Color(0xFF202D61)],
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'WELCOME TO KOKI PARTY',
                style: TextStyle(
                  color: white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'ادخل عالمك.. قابل أصحابك واصنع حفلتك',
                style: TextStyle(color: white, fontSize: 14),
              ),
              SizedBox(height: 15),
              Icon(Icons.graphic_eq, color: white, size: 38),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'خدمات KOKI',
          style: TextStyle(
            color: white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            serviceButton(Icons.card_giftcard, 'الهدايا'),
            serviceButton(Icons.workspace_premium, 'VIP'),
            serviceButton(Icons.account_balance_wallet, 'المحفظة'),
            serviceButton(Icons.emoji_events, 'الترتيب'),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الغرف الصوتية',
              style: TextStyle(
                color: white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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

  Widget serviceButton(IconData icon, String label) {
    return Expanded(
      child: InkWell(
        onTap: () => showMessage('$label - هنضيف الخدمة في المرحلة الجاية'),
        child: Column(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(icon, color: purple, size: 26),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              style: const TextStyle(color: muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget roomCard(Map<String, String> room) {
    return InkWell(
      onTap: () => openRoom(room),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [purple, blue],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.mic, color: white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room['name']!,
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'المضيف: ${room['host']}',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '8 مقاعد صوتية',
                    style: TextStyle(color: purple, fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Icon(Icons.people, color: muted, size: 18),
                Text(
                  room['users']!,
                  style: const TextStyle(color: white, fontSize: 12),
                ),
                const Icon(Icons.chevron_left, color: purple),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget simplePage(String title, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: purple, size: 55),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(color: white, fontSize: 22),
          ),
          const SizedBox(height: 8),
          const Text(
            'القسم ده هنبنيه في الخطوات الجاية',
            style: TextStyle(color: muted),
          ),
        ],
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class RoomPage extends StatefulWidget {
  final Map<String, String> room;

  const RoomPage({super.key, required this.room});

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  int? mySeat;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: card,
          title: Text(widget.room['name']!),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Icon(Icons.graphic_eq, color: purple, size: 45),
                  const SizedBox(height: 10),
                  Text(
                    widget.room['name']!,
                    style: const TextStyle(
                      color: white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'المضيف: ${widget.room['host']}',
                    style: const TextStyle(color: muted),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'مقاعد الغرفة',
                    style: TextStyle(color: purple),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 8,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 18,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, index) {
                final occupied = index == 0 || index == 3;
                final mine = mySeat == index;

                return InkWell(
                  onTap: () {
                    if (mine) {
                      setState(() => mySeat = null);
                    } else if (!occupied && mySeat == null) {
                      setState(() => mySeat = index);
                    } else if (occupied) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('المقعد ده مشغول'),
                        ),
                      );
                    }
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 57,
                        height: 57,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mine
                              ? purple
                              : occupied
                                  ? blue.withValues(alpha: 0.35)
                                  : card,
                          border: Border.all(
                            color: mine ? purple : Colors.white24,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          occupied
                              ? Icons.person
                              : mine
                                  ? Icons.person
                                  : Icons.add,
                          color: white,
                          size: 27,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        mine
                            ? 'أنت'
                            : occupied
                                ? 'مشغول'
                                : 'مقعد ${index + 1}',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => mySeat = null);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('غادرت المقعد')),
                );
              },
              icon: const Icon(Icons.exit_to_app),
              label: const Text('مغادرة المقعد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: white,
                padding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'دي مقاعد تجريبية، والصوت المباشر هنضيفه بعد كده',
                style: TextStyle(color: muted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
