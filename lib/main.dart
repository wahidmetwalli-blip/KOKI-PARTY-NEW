import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

// بيانات الغرف
class RoomInfo {
  final String name;
  final String host;
  final int members;
  final Color color;
  final IconData icon;

  const RoomInfo({
    required this.name,
    required this.host,
    required this.members,
    required this.color,
    required this.icon,
  });
}

// التطبيق
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

  final List<RoomInfo> rooms = const [
    RoomInfo(
      name: 'غرفة الملوك',
      host: 'المضيف الرئيسي',
      members: 24,
      color: purple,
      icon: Icons.diamond,
    ),
    RoomInfo(
      name: 'مملكة KOKI',
      host: 'KOKI HOST',
      members: 126,
      color: blue,
      icon: Icons.mic,
    ),
    RoomInfo(
      name: 'عالم الأصدقاء',
      host: 'Friend Group',
      members: 84,
      color: pink,
      icon: Icons.people,
    ),
    RoomInfo(
      name: 'سهرة الملوك',
      host: 'Royal Host',
      members: 52,
      color: purple,
      icon: Icons.nightlife,
    ),
    RoomInfo(
      name: 'نجوم الليل',
      host: 'Night Stars',
      members: 39,
      color: blue,
      icon: Icons.star,
    ),
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

  // تحديث رصيد العملات
  void updateCoins(int newBalance) {
    setState(() {
      coins = newBalance;
    });
  }

  // فتح المحفظة
  void showWallet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, updateSheet) {
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
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        showMessage(
                          'الشحن الحقيقي لسه محتاج ربط بوابة دفع',
                        );
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
      },
    );
  }

  // فتح غرفة مع تمرير رصيد المحفظة
  void openRoom(RoomInfo room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPage(
          roomName: room.name,
          coins: coins,
          onCoinsChanged: updateCoins,
        ),
      ),
    );
  }
  
  // بناء التطبيق والتنقل بين الصفحات
  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      buildDiscover(),
      buildMessages(),
      buildProfile(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: pages[selectedTab],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: panel,
            border: Border(
              top: BorderSide(color: panel2),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: selectedTab,
            onTap: (index) {
              setState(() {
                selectedTab = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: panel,
            selectedItemColor: const Color(0xFFFFD76A),
            unselectedItemColor: muted,
            selectedFontSize: 11,
            unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.explore_rounded),
                label: 'اكتشف',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_rounded),
                label: 'الرسائل',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'حسابي',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // الصفحة الرئيسية
  Widget buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        topBar(),
        const SizedBox(height: 20),
        welcomeBanner(),
        const SizedBox(height: 22),
        servicesSection(),
        const SizedBox(height: 25),
        roomsTitle(),
        const SizedBox(height: 12),
        ...rooms.map((room) => roomCard(room)),
        const SizedBox(height: 25),
      ],
    );
  }

  // الشريط العلوي
  Widget topBar() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: panel2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD4AF37),
            ),
          ),
          child: const Icon(
            Icons.workspace_premium,
            color: Color(0xFFFFD76A),
            size: 29,
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
                  color: Color(0xFFFFD76A),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
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
        InkWell(
          onTap: showWallet,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: panel2,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFFD4AF37),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.monetization_on,
                  color: Color(0xFFFFD76A),
                  size: 19,
                ),
                const SizedBox(width: 6),
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
      ],
    );
  }

  // بانر الترحيب
  Widget welcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF39235F),
            Color(0xFF171126),
            Color(0xFF302044),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WELCOME TO',
            style: TextStyle(
              color: Color(0xFFFFD76A),
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'KOKI PARTY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'عالمك.. حفلتك',
            style: TextStyle(
              color: Color(0xFFFFD76A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'استمتع بأجمل الغرف الصوتية والهدايا والأصدقاء',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedTab = 1;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4AF37),
              foregroundColor: Colors.black,
            ),
            child: const Text(
              'اكتشف الآن',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // الخدمات الرئيسية
  Widget servicesSection() {
    final services = [
      {
        'title': 'الغرف',
        'icon': Icons.mic,
        'color': purple,
      },
      {
        'title': 'الهدايا',
        'icon': Icons.card_giftcard,
        'color': pink,
      },
      {
        'title': 'VIP',
        'icon': Icons.workspace_premium,
        'color': Colors.amber,
      },
      {
        'title': 'المحفظة',
        'icon': Icons.account_balance_wallet,
        'color': blue,
      },
      {
        'title': 'الترتيب',
        'icon': Icons.emoji_events,
        'color': Colors.orange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الخدمات الملكية',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final service = services[index];

              return InkWell(
                onTap: () {
                  final title = service['title'] as String;

                  if (title == 'المحفظة') {
                    showWallet();
                  } else if (title == 'الغرف') {
                    setState(() {
                      selectedTab = 1;
                    });
                  } else {
                    showMessage(
                      'قسم $title هيتم تفعيله في المراحل القادمة',
                    );
                  }
                },
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  width: 82,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: panel2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        service['icon'] as IconData,
                        color: service['color'] as Color,
                        size: 29,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
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
    return Row(
      children: [
        const Expanded(
          child: Text(
            'الغرف الصوتية',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              selectedTab = 1;
            });
          },
          child: const Text(
            'عرض الكل',
            style: TextStyle(
              color: Color(0xFFFFD76A),
            ),
          ),
        ),
      ],
    );
  }

  // بطاقة الغرفة
  Widget roomCard(RoomInfo room) {
    return InkWell(
      onTap: () => openRoom(room),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: room.color.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 53,
              height: 53,
              decoration: BoxDecoration(
                color: room.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                room.icon,
                color: room.color,
                size: 29,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    room.host,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: muted,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${room.members} متصل',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 9),
                      const Icon(
                        Icons.mic,
                        color: Color(0xFFFFD76A),
                        size: 14,
                      ),
                      const SizedBox(width: 3),
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
              color: Color(0xFFFFD76A),
              size: 17,
            ),
          ],
        ),
      ),
    );
  }
  
  // صفحة اكتشاف الغرف
  Widget buildDiscover() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'اكتشف عالم KOKI',
          style: TextStyle(
            color: Color(0xFFFFD76A),
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'اختار غرفتك وابدأ سهرتك',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search, color: muted),
              hintText: 'ابحث عن غرفة...',
              hintStyle: TextStyle(color: muted),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'الغرف المميزة',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        ...rooms.map((room) => roomCard(room)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: purple),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.workspace_premium,
                color: Color(0xFFFFD76A),
                size: 40,
              ),
              const SizedBox(height: 10),
              const Text(
                'عالم الملوك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'استمتع بتجربة KOKI PARTY الملكية',
                style: TextStyle(color: muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () {
                  openRoom(rooms.first);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('ادخل الغرفة'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // صفحة الرسائل
  Widget buildMessages() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'الرسائل',
          style: TextStyle(
            color: Color(0xFFFFD76A),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'تواصل مع أصدقائك في KOKI PARTY',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.mark_chat_unread,
                color: purple,
                size: 55,
              ),
              SizedBox(height: 13),
              Text(
                'أهلاً بيك في الرسائل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'هنا هتظهر محادثاتك وأصدقاؤك بعد تفعيل نظام الرسائل',
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const CircleAvatar(
            backgroundColor: panel2,
            child: Icon(Icons.support_agent, color: purple),
          ),
          title: const Text(
            'خدمة عملاء KOKI',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: const Text(
            'مركز المساعدة',
            style: TextStyle(color: muted),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: muted,
            size: 15,
          ),
          onTap: () {
            showMessage('خدمة العملاء هتتفعّل قريباً');
          },
        ),
      ],
    );
  }

  // صفحة الحساب الشخصي
  Widget buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF8957F5),
                  Color(0xFFD4AF37),
                ],
              ),
              border: Border.all(
                color: const Color(0xFFFFD76A),
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 58,
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'KOKI MEMBER',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 7),
        const Center(
          child: Text(
            'معرف المستخدم: 1000001',
            style: TextStyle(color: muted),
          ),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: panel,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: panel2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _profileStat('العملات', '$coins'),
              _profileStat('المستوى', '1'),
              _profileStat('VIP', 'عادي'),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'إعدادات الحساب',
          style: TextStyle(
            color: Color(0xFFFFD76A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _profileOption(
          Icons.account_balance_wallet,
          'المحفظة',
          showWallet,
        ),
        _profileOption(
          Icons.workspace_premium,
          'عضوية VIP',
          () => showMessage('عضوية VIP هتتفعّل قريباً'),
        ),
        _profileOption(
          Icons.card_giftcard,
          'الهدايا',
          () => showMessage('قسم الهدايا هيتفعّل قريباً'),
        ),
        _profileOption(
          Icons.security,
          'الخصوصية والأمان',
          () => showMessage('إعدادات الخصوصية هتتضاف قريباً'),
        ),
        _profileOption(
          Icons.help_outline,
          'المساعدة والدعم',
          () => showMessage('مركز المساعدة هيتفعّل قريباً'),
        ),
        _profileOption(
          Icons.info_outline,
          'عن KOKI PARTY',
          () => showMessage('KOKI PARTY - THE ROYAL WORLD'),
        ),
        const SizedBox(height: 25),
        const Center(
          child: Text(
            'KOKI PARTY • THE ROYAL WORLD',
            style: TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ),
      ],
    );
  }

  // إحصائيات الحساب
  Widget _profileStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFFFD76A),
            fontSize: 19,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: muted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // خيارات الحساب
  Widget _profileOption(
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
        leading: Icon(
          icon,
          color: const Color(0xFFFFD76A),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: muted,
          size: 14,
        ),
      ),
    );
  }
  
}

// شاشة الغرفة الصوتية
class RoomPage extends StatefulWidget {
  final String roomName;
  final int coins;
  final ValueChanged<int> onCoinsChanged;

  const RoomPage({
    super.key,
    required this.roomName,
    required this.coins,
    required this.onCoinsChanged,
  });

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late int coins;
  bool isMicMuted = true;

  final List<String?> seats =
      List<String?>.filled(8, null);

  final List<String> chatMessages = [
    'أهلاً بيكم في KOKI PARTY',
    'نورتوا غرفة الملوك 👑',
  ];

  @override
  void initState() {
    super.initState();
    coins = widget.coins;
  }

  // تحديث العملات
  void changeCoins(int amount) {
    setState(() {
      coins = amount;
    });

    widget.onCoinsChanged(amount);
  }

  // رسالة داخل الغرفة
  void addMessage(String message) {
    setState(() {
      chatMessages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              roomHeader(),
              const SizedBox(height: 15),
              roomInfo(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      const Text(
                        'مقاعد المتحدثين',
                        style: TextStyle(
                          color: Color(0xFFFFD76A),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: 8,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemBuilder: (context, index) {
                          return seatWidget(index);
                        },
                      ),
                      const SizedBox(height: 22),
                      chatPreview(),
                    ],
                  ),
                ),
              ),
              roomControls(),
            ],
          ),
        ),
      ),
    );
  }

  // رأس الغرفة
  Widget roomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              widget.roomName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          InkWell(
            onTap: showRoomMenu,
            child: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // معلومات الغرفة
  Widget roomInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: panel2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mic,
            color: Color(0xFFFFD76A),
            size: 30,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KOKI PARTY LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'غرفة صوتية ملكية',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 8,
                ),
                SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
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

  // المقعد
  Widget seatWidget(int index) {
    final user = seats[index];

    return InkWell(
      onTap: () => seatAction(index),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: user == null ? panel2 : purple,
              shape: BoxShape.circle,
              border: Border.all(
                color: user == null
                    ? muted
                    : const Color(0xFFFFD76A),
                width: 2,
              ),
            ),
            child: Icon(
              user == null
                  ? Icons.add
                  : Icons.person,
              color: Colors.white,
              size: 29,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            user ?? 'مقعد ${index + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Icon(
            user == null ? Icons.mic_off : Icons.mic,
            color: user == null ? muted : Colors.green,
            size: 15,
          ),
        ],
      ),
    );
  }

  // طلب دخول المقعد
  void seatAction(int index) {
    if (seats[index] != null) {
      showMessage('المقعد مشغول حالياً');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'دخول مقعد المتحدث',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'هل تريد الجلوس على هذا المقعد؟',
                  style: TextStyle(color: muted),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        seats[index] = 'أنت';
                      });

                      Navigator.pop(sheetContext);
                      showMessage('أنت الآن على المقعد');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('اجلس على المقعد'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                  },
                  child: const Text(
                    'إلغاء',
                    style: TextStyle(color: muted),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // أزرار الغرفة
  Widget roomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: panel,
        border: Border(
          top: BorderSide(color: panel2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          controlButton(
            isMicMuted ? Icons.mic_off : Icons.mic,
            isMicMuted ? 'فتح المايك' : 'كتم',
            () {
              setState(() {
                isMicMuted = !isMicMuted;
              });
              showMessage(
                isMicMuted ? 'تم كتم المايك' : 'تم فتح المايك',
              );
            },
          ),
          controlButton(
            Icons.card_giftcard,
            'هدايا',
            showGifts,
          ),
          controlButton(
            Icons.chat,
            'دردشة',
            showChat,
          ),
          controlButton(
            Icons.account_balance_wallet,
            'المحفظة',
            showRoomWallet,
          ),
          controlButton(
            Icons.exit_to_app,
            'خروج',
            () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  // زر تحكم
  Widget controlButton(
    IconData icon,
    String title,
    VoidCallback action,
  ) {
    return InkWell(
      onTap: action,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFFFFD76A),
            size: 23,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // رسالة للمستخدم
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: panel2,
      ),
    );
  }
  
  // قائمة الهدايا
  void showGifts() {
    final gifts = [
      {'name': 'وردة', 'icon': '🌹', 'price': 100},
      {'name': 'قلب', 'icon': '❤️', 'price': 300},
      {'name': 'نجمة', 'icon': '⭐', 'price': 500},
      {'name': 'تاج', 'icon': '👑', 'price': 1000},
      {'name': 'ماسة', 'icon': '💎', 'price': 2000},
      {'name': 'قلعة', 'icon': '🏰', 'price': 5000},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'هدايا KOKI PARTY',
                  style: TextStyle(
                    color: Color(0xFFFFD76A),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'رصيدك: $coins عملة',
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  itemCount: gifts.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final gift = gifts[index];
                    final price = gift['price'] as int;

                    return InkWell(
                      onTap: () {
                        if (coins < price) {
                          Navigator.pop(sheetContext);
                          showMessage('رصيدك غير كافي لإرسال الهدية');
                          return;
                        }

                        changeCoins(coins - price);

                        Navigator.pop(sheetContext);

                        showMessage(
                          'تم إرسال ${gift['name']} بنجاح',
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: panel2,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: muted),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              gift['icon'] as String,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              gift['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$price عملة',
                              style: const TextStyle(
                                color: Color(0xFFFFD76A),
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
          ),
        );
      },
    );
  }

  // دردشة الغرفة
  void showChat() {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              left: 15,
              right: 15,
              top: 20,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 15,
            ),
            child: SizedBox(
              height: 380,
              child: Column(
                children: [
                  const Text(
                    'دردشة الغرفة',
                    style: TextStyle(
                      color: Color(0xFFFFD76A),
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
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
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'اكتب رسالتك...',
                            hintStyle: const TextStyle(color: muted),
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

                          if (message.isEmpty) return;

                          addMessage('أنت: $message');
                          controller.clear();
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Color(0xFFFFD76A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // محفظة الغرفة
  void showRoomWallet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFFFFD76A),
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  'محفظتك',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$coins عملة',
                  style: const TextStyle(
                    color: Color(0xFFFFD76A),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      showMessage(
                        'الشحن الحقيقي محتاج ربط بوابة دفع',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purple,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('شحن العملات'),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // قائمة خيارات الغرفة
  void showRoomMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.report,
                  color: Colors.orange,
                ),
                title: const Text(
                  'الإبلاغ عن الغرفة',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showMessage('تم تسجيل طلب الإبلاغ بشكل تجريبي');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.share,
                  color: purple,
                ),
                title: const Text(
                  'مشاركة الغرفة',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showMessage('مشاركة الغرفة هتتفعّل قريباً');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.close,
                  color: muted,
                ),
                title: const Text(
                  'إغلاق',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
