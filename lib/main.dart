
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KokiPartyApp());
}

// ==========================================
// KOKI PARTY - THE ROYAL WORLD
// MAIN CONFIGURATION
// ==========================================

class KokiColors {
  static const Color background = Color(0xFF090711);
  static const Color panel = Color(0xFF171326);
  static const Color panelLight = Color(0xFF211A35);
  static const Color purple = Color(0xFF8957F5);
  static const Color purpleDark = Color(0xFF5126A8);
  static const Color gold = Color(0xFFD8B45A);
  static const Color goldLight = Color(0xFFFFE6A0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFFAAA4B8);
  static const Color green = Color(0xFF36D69A);
  static const Color red = Color(0xFFFF5368);
}

// ==========================================
// APPLICATION
// ==========================================

class KokiPartyApp extends StatelessWidget {
  const KokiPartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KOKI PARTY',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: KokiColors.background,
        primaryColor: KokiColors.purple,
        colorScheme: const ColorScheme.dark(
          primary: KokiColors.gold,
          secondary: KokiColors.purple,
          surface: KokiColors.panel,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const KokiHomePage(),
    );
  }
}

// ==========================================
// DATA MODELS
// ==========================================

class PartyRoom {
  final int id;
  final String name;
  final String owner;
  final String description;
  final int listeners;
  final int speakers;
  final String country;
  final String emoji;

  const PartyRoom({
    required this.id,
    required this.name,
    required this.owner,
    required this.description,
    required this.listeners,
    required this.speakers,
    required this.country,
    required this.emoji,
  });
}

class PartyUser {
  final String name;
  final String id;
  final String avatar;
  final int level;
  final int coins;
  final int diamonds;

  const PartyUser({
    required this.name,
    required this.id,
    required this.avatar,
    required this.level,
    required this.coins,
    required this.diamonds,
  });
}

class PartyGift {
  final String name;
  final String emoji;
  final int price;

  const PartyGift({
    required this.name,
    required this.emoji,
    required this.price,
  });
}

// ==========================================
// DEMO DATA
// ==========================================

class KokiDemoData {
  static const PartyUser currentUser = PartyUser(
    name: 'KOKI KING',
    id: '1000001',
    avatar: '👑',
    level: 12,
    coins: 100000,
    diamonds: 2500,
  );

  static const List<PartyRoom> rooms = [
    PartyRoom(
      id: 101,
      name: 'غرفة الملوك',
      owner: 'Royal King',
      description: 'أهلاً بيكم في مملكة الملوك',
      listeners: 126,
      speakers: 5,
      country: '🌍',
      emoji: '👑',
    ),
    PartyRoom(
      id: 102,
      name: 'مملكة KOKI',
      owner: 'KOKI Admin',
      description: 'عالم المرح والأصدقاء',
      listeners: 84,
      speakers: 4,
      country: '🌍',
      emoji: '🏰',
    ),
    PartyRoom(
      id: 103,
      name: 'سهرة الملوك',
      owner: 'Night Star',
      description: 'سهرة صوتية مميزة',
      listeners: 52,
      speakers: 3,
      country: '🌍',
      emoji: '🌙',
    ),
    PartyRoom(
      id: 104,
      name: 'عالم الأصدقاء',
      owner: 'Friends',
      description: 'اتعرف على أصدقاء جدد',
      listeners: 39,
      speakers: 2,
      country: '🌍',
      emoji: '💜',
    ),
  ];

  static const List<PartyGift> gifts = [
    PartyGift(name: 'وردة', emoji: '🌹', price: 100),
    PartyGift(name: 'قلب', emoji: '💖', price: 500),
    PartyGift(name: 'تاج', emoji: '👑', price: 1000),
    PartyGift(name: 'سيارة', emoji: '🏎️', price: 5000),
    PartyGift(name: 'قلعة', emoji: '🏰', price: 10000),
    PartyGift(name: 'يخت', emoji: '🛥️', price: 20000),
  ];
}

// ==========================================
// STAGE 2 - HOME SCREEN
// ==========================================

class KokiHomePage extends StatefulWidget {
  const KokiHomePage({super.key});

  @override
  State<KokiHomePage> createState() => _KokiHomePageState();
}

class _KokiHomePageState extends State<KokiHomePage> {
  int selectedTab = 0;

  void openFeature(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title - قريباً في KOKI PARTY'),
        backgroundColor: KokiColors.purpleDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcome(),
                    const SizedBox(height: 22),
                    _buildShortcuts(),
                    const SizedBox(height: 25),
                    _buildSectionTitle('الغرف الصوتية', 'استكشف'),
                    const SizedBox(height: 12),
                    ...KokiDemoData.rooms.map(
                      (room) => _buildRoomCard(room),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 13,
      ),
      decoration: const BoxDecoration(
        color: KokiColors.panel,
        border: Border(
          bottom: BorderSide(
            color: KokiColors.gold,
            width: 0.4,
          ),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: KokiColors.gold,
            radius: 23,
            child: Text('👑', style: TextStyle(fontSize: 25)),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KOKI PARTY',
                  style: TextStyle(
                    color: KokiColors.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'THE ROYAL WORLD',
                  style: TextStyle(
                    color: KokiColors.muted,
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => openFeature('المحفظة'),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: KokiColors.panelLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: KokiColors.gold.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: KokiColors.gold,
                    size: 19,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${KokiDemoData.currentUser.coins}',
                    style: const TextStyle(
                      color: KokiColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(
                    Icons.add_circle,
                    color: KokiColors.green,
                    size: 17,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF49217E),
            Color(0xFF211633),
            Color(0xFF11101B),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        border: Border.all(
          color: KokiColors.gold.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: KokiColors.purple.withValues(alpha: 0.2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WELCOME TO',
            style: TextStyle(
              color: KokiColors.goldLight,
              letterSpacing: 3,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'KOKI PARTY 👑',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'عالمك.. حفلتك.. مملكتك',
            style: TextStyle(
              fontSize: 16,
              color: KokiColors.goldLight,
            ),
          ),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: () => openFeature('اكتشف الغرف'),
              style: FilledButton.styleFrom(
                backgroundColor: KokiColors.gold,
                foregroundColor: KokiColors.background,
              ),
              icon: const Icon(Icons.explore),
              label: const Text('ابدأ المغامرة'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShortcuts() {
    final items = [
      ['VIP', '👑'],
      ['الهدايا', '🎁'],
      ['المحفظة', '💰'],
      ['الترتيب', '🏆'],
    ];

    return Row(
      children: items.map((item) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => openFeature(item[0]),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: KokiColors.panel,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: KokiColors.gold.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      item[1],
                      style: const TextStyle(fontSize: 27),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item[0],
                      style: const TextStyle(
                        color: KokiColors.goldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title, String action) {
    return Row(
      children: [
        const Icon(
          Icons.graphic_eq,
          color: KokiColors.gold,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: () => openFeature(action),
          child: Text(
            action,
            style: const TextStyle(color: KokiColors.gold),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard(PartyRoom room) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RoomPage(room: room),
          ),
        );
      },
      borderRadius: BorderRadius.circular(19),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: KokiColors.panel,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: KokiColors.gold.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 57,
              height: 57,
              decoration: BoxDecoration(
                color: KokiColors.purpleDark,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Text(
                room.emoji,
                style: const TextStyle(fontSize: 29),
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
                      color: KokiColors.goldLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    room.description,
                    style: const TextStyle(
                      color: KokiColors.muted,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.headphones,
                        color: KokiColors.green,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${room.listeners} مستمع',
                        style: const TextStyle(
                          color: KokiColors.muted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.mic,
                        color: KokiColors.gold,
                        size: 15,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${room.speakers}/8 متحدثين',
                        style: const TextStyle(
                          color: KokiColors.muted,
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
              color: KokiColors.gold,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    final items = [
      [Icons.home_rounded, 'الرئيسية'],
      [Icons.explore, 'اكتشف'],
      [Icons.mic, 'الغرف'],
      [Icons.message, 'الرسائل'],
      [Icons.person, 'حسابي'],
    ];

    return Container(
      decoration: const BoxDecoration(
        color: KokiColors.panel,
        border: Border(
          top: BorderSide(
            color: KokiColors.gold,
            width: 0.4,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) {
          setState(() => selectedTab = index);
          if (index != 0) {
            openFeature(items[index][1] as String);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: KokiColors.panel,
        selectedItemColor: KokiColors.gold,
        unselectedItemColor: KokiColors.muted,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: items.map((item) {
          return BottomNavigationBarItem(
            icon: Icon(item[0] as IconData),
            label: item[1] as String,
          );
        }).toList(),
      ),
    );
  }
}

class GiftsWalletPage extends StatefulWidget {
  const GiftsWalletPage({super.key});

  @override
  State<GiftsWalletPage> createState() => _GiftsWalletPageState();
}

class _GiftsWalletPageState extends State<GiftsWalletPage> {
  int selectedGift = 0;
  int coins = KokiDemoData.currentUser.coins;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: KokiColors.panelLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KokiColors.background,
      appBar: AppBar(
        backgroundColor: KokiColors.background,
        foregroundColor: KokiColors.gold,
        title: const Text(
          'الهدايا والمحفظة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWallet(),
          const SizedBox(height: 24),
          _buildTitle('متجر الهدايا'),
          const SizedBox(height: 12),
          _buildGifts(),
          const SizedBox(height: 20),
          _buildSendButton(),
          const SizedBox(height: 24),
          _buildRechargeButton(),
        ],
      ),
    );
  }

  Widget _buildWallet() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF55318A),
            Color(0xFF21172F),
            Color(0xFF171326),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: KokiColors.gold.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: KokiColors.gold,
            size: 38,
          ),
          const SizedBox(height: 10),
          const Text(
            'محفظة KOKI PARTY',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'رصيد العملات',
            style: TextStyle(color: KokiColors.gold),
          ),
          const SizedBox(height: 6),
          Text(
            coins.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(color: Color(0x55D8B45A)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.diamond_rounded,
                color: Colors.lightBlueAccent,
              ),
              const SizedBox(width: 8),
              Text(
                '${KokiDemoData.currentUser.diamonds} ألماسة',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: KokiColors.gold,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGifts() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: KokiDemoData.gifts.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final gift = KokiDemoData.gifts[index];
        final isSelected = selectedGift == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedGift = index;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: KokiColors.panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? KokiColors.gold
                    : KokiColors.gold.withValues(alpha: 0.15),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  color: KokiColors.gold,
                  size: 34,
                ),
                const SizedBox(height: 8),
                Text(
                  gift.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${gift.price} عملة',
                  style: const TextStyle(
                    color: KokiColors.gold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSendButton() {
    final gift = KokiDemoData.gifts[selectedGift];

    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          if (coins < gift.price) {
            showMessage('رصيدك مش كافي لإرسال الهدية');
            return;
          }

          setState(() {
            coins -= gift.price;
          });

          showMessage(
            'تم خصم ${gift.price} عملة تجريبياً',
          );
        },
        icon: const Icon(Icons.card_giftcard_rounded),
        label: const Text('إرسال الهدية المختارة'),
        style: ElevatedButton.styleFrom(
          backgroundColor: KokiColors.purple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  Widget _buildRechargeButton() {
    return OutlinedButton.icon(
      onPressed: () {
        showMessage(
          'الشحن الحقيقي هيتوصل بوكلاء الشحن ونظام الدفع',
        );
      },
      icon: const Icon(Icons.add_card_rounded),
      label: const Text('شحن العملات'),
      style: OutlinedButton.styleFrom(
        foregroundColor: KokiColors.gold,
        side: const BorderSide(color: KokiColors.gold),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class VipRankingPage extends StatefulWidget {
  const VipRankingPage({super.key});

  @override
  State<VipRankingPage> createState() => _VipRankingPageState();
}

class _VipRankingPageState extends State<VipRankingPage> {
  int selectedVip = 0;

  final List<Map<String, dynamic>> vipLevels = [
    {
      'name': 'VIP 1',
      'price': 5000,
      'color': Color(0xFF8E78C8),
      'icon': Icons.workspace_premium_rounded,
    },
    {
      'name': 'VIP 2',
      'price': 15000,
      'color': Color(0xFFD8B45A),
      'icon': Icons.military_tech_rounded,
    },
    {
      'name': 'VIP 3',
      'price': 30000,
      'color': Color(0xFFFFD700),
      'icon': Icons.diamond_rounded,
    },
  ];

  final List<Map<String, dynamic>> ranking = [
    {'name': 'ROYAL KING', 'coins': 95000},
    {'name': 'KOKI STAR', 'coins': 82000},
    {'name': 'QUEEN KOKI', 'coins': 76000},
    {'name': 'ROYAL VIP', 'coins': 54000},
    {'name': 'PARTY HERO', 'coins': 42000},
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: KokiColors.panelLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KokiColors.background,
      appBar: AppBar(
        backgroundColor: KokiColors.background,
        foregroundColor: KokiColors.gold,
        title: const Text('VIP والترتيب'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildVipBanner(),
          const SizedBox(height: 22),
          _buildTitle('عضويات VIP'),
          const SizedBox(height: 12),
          _buildVipCards(),
          const SizedBox(height: 25),
          _buildTitle('قائمة أفضل المستخدمين'),
          const SizedBox(height: 12),
          _buildRanking(),
        ],
      ),
    );
  }

  Widget _buildVipBanner() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF56328B),
            Color(0xFF171326),
          ],
        ),
        border: Border.all(
          color: KokiColors.gold.withValues(alpha: 0.5),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            color: KokiColors.gold,
            size: 52,
          ),
          SizedBox(height: 10),
          Text(
            'THE ROYAL VIP CLUB',
            style: TextStyle(
              color: KokiColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'تميز بإطلالة ملكية داخل عالم KOKI PARTY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: KokiColors.gold,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVipCards() {
    return Column(
      children: List.generate(vipLevels.length, (index) {
        final level = vipLevels[index];
        final selected = selectedVip == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedVip = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KokiColors.panel,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: selected
                    ? KokiColors.gold
                    : KokiColors.gold.withValues(alpha: 0.2),
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  level['icon'] as IconData,
                  color: level['color'] as Color,
                  size: 38,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${level['price']} عملة',
                        style: const TextStyle(
                          color: KokiColors.gold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: KokiColors.gold,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRanking() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KokiColors.panel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: KokiColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: List.generate(ranking.length, (index) {
          final user = ranking[index];

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              border: index == ranking.length - 1
                  ? null
                  : const Border(
                      bottom: BorderSide(
                        color: Color(0xFF302641),
                      ),
                    ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 35,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: index == 0
                          ? KokiColors.gold
                          : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 19,
                  backgroundColor: KokiColors.purpleDark,
                  child: Icon(
                    index == 0
                        ? Icons.workspace_premium_rounded
                        : Icons.person_rounded,
                    color: KokiColors.gold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    user['name'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '${user['coins']}',
                  style: const TextStyle(
                    color: KokiColors.gold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.monetization_on_rounded,
                  color: KokiColors.gold,
                  size: 17,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: KokiColors.panelLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = KokiDemoData.currentUser;

    return Scaffold(
      backgroundColor: KokiColors.background,
      appBar: AppBar(
        backgroundColor: KokiColors.background,
        foregroundColor: KokiColors.gold,
        title: const Text('حسابي'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfile(user),
          const SizedBox(height: 20),
          _buildStats(user),
          const SizedBox(height: 22),
          _buildMenu(context),
        ],
      ),
    );
  }

  Widget _buildProfile(PartyUser user) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF513080),
            Color(0xFF171326),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: KokiColors.gold.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: KokiColors.gold,
                width: 3,
              ),
            ),
            child: const CircleAvatar(
              radius: 43,
              backgroundColor: KokiColors.panelLight,
              child: Icon(
                Icons.person_rounded,
                size: 48,
                color: KokiColors.gold,
              ),
            ),
          ),
          const SizedBox(height: 13),
          Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'ID: ${user.id}',
            style: const TextStyle(
              color: KokiColors.gold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: KokiColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ROYAL MEMBER',
              style: TextStyle(
                color: KokiColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(PartyUser user) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.monetization_on_rounded,
            '${user.coins}',
            'العملات',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.diamond_rounded,
            '${user.diamonds}',
            'الألماس',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.workspace_premium_rounded,
            'VIP 0',
            'العضوية',
          ),
        ),
      ],
    );
  }

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 5,
      ),
      decoration: BoxDecoration(
        color: KokiColors.panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: KokiColors.gold.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: KokiColors.gold, size: 25),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: KokiColors.muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu(BuildContext context) {
    final items = [
      [Icons.person_outline_rounded, 'تعديل الملف الشخصي'],
      [Icons.chat_bubble_outline_rounded, 'الرسائل الخاصة'],
      [Icons.notifications_none_rounded, 'الإشعارات'],
      [Icons.people_alt_outlined, 'الأصدقاء'],
      [Icons.history_rounded, 'سجل المعاملات'],
      [Icons.security_rounded, 'الأمان والخصوصية'],
      [Icons.settings_outlined, 'الإعدادات'],
      [Icons.help_outline_rounded, 'المساعدة والدعم'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: KokiColors.panel,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return ListTile(
            leading: Icon(
              item[0] as IconData,
              color: KokiColors.gold,
            ),
            title: Text(
              item[1] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: KokiColors.muted,
              size: 15,
            ),
            onTap: () {
              showMessage(
                context,
                '${item[1]}: هتتضاف وظائفها في المراحل القادمة',
              );
            },
          );
        }),
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  final List<Map<String, String>> conversations = const [
    {
      'name': 'ROYAL KING',
      'message': 'أهلاً بيك في KOKI PARTY',
      'time': 'الآن',
    },
    {
      'name': 'KOKI STAR',
      'message': 'عامل إيه؟',
      'time': 'منذ 5 دقائق',
    },
    {
      'name': 'QUEEN KOKI',
      'message': 'شكراً على الهدية ❤️',
      'time': 'منذ ساعة',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KokiColors.background,
      appBar: AppBar(
        backgroundColor: KokiColors.background,
        foregroundColor: KokiColors.gold,
        title: const Text('الرسائل'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final chat = conversations[index];

          return Card(
            color: KokiColors.panel,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: KokiColors.purpleDark,
                child: Icon(
                  Icons.person_rounded,
                  color: KokiColors.gold,
                ),
              ),
              title: Text(
                chat['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                chat['message']!,
                style: const TextStyle(
                  color: KokiColors.muted,
                ),
              ),
              trailing: Text(
                chat['time']!,
                style: const TextStyle(
                  color: KokiColors.gold,
                  fontSize: 10,
                ),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'المحادثات الحقيقية هتتربط بالخادم لاحقاً',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  final List<String> notifications = const [
    'أهلاً بيك في عالم KOKI PARTY 👑',
    'استكشف غرف الملوك والسهرة',
    'تابع الهدايا ومستويات VIP',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KokiColors.background,
      appBar: AppBar(
        backgroundColor: KokiColors.background,
        foregroundColor: KokiColors.gold,
        title: const Text('الإشعارات'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: KokiColors.panel,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: KokiColors.gold.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_rounded,
                  color: KokiColors.gold,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    notifications[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class AdminAgencyPage extends StatefulWidget {
  const AdminAgencyPage({super.key});

  @override
  State<AdminAgencyPage> createState() => _AdminAgencyPageState();
}

class _AdminAgencyPageState extends State<AdminAgencyPage> {
  int selectedSection = 0;

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'لوحة التحكم',
      'icon': Icons.dashboard_rounded,
    },
    {
      'title': 'وكلاء المضيفين',
      'icon': Icons.groups_rounded,
    },
    {
      'title': 'وكلاء الشحن',
      'icon': Icons.monetization_on_rounded,
    },
    {
      'title': 'إدارة المضيفين',
      'icon': Icons.mic_rounded,
    },
    {
      'title': 'الأرباح والسحب',
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'title': 'طلبات السحب',
      'icon': Icons.payments_rounded,
    },
    {
      'title': 'إدارة المستخدمين',
      'icon': Icons.people_alt_rounded,
    },
    {
      'title': 'إدارة الغرف',
      'icon': Icons.meeting_room_rounded,
    },
  ];

  final List<Map<String, String>> hostAgents = [
    {'name': 'ROYAL AGENT 1', 'id': 'AG1001', 'status': 'نشط'},
    {'name': 'KOKI AGENT 2', 'id': 'AG1002', 'status': 'نشط'},
  ];

  final List<Map<String, String>> rechargeAgents = [
    {'name': 'CHARGE AGENT 1', 'id': 'CH2001', 'status': 'نشط'},
    {'name': 'CHARGE AGENT 2', 'id': 'CH2002', 'status': 'مراجعة'},
  ];

  final List<Map<String, String>> withdrawalRequests = [
    {
      'user': 'HOST 1001',
      'amount': '50000',
      'status': 'قيد المراجعة',
    },
    {
      'user': 'HOST 1002',
      'amount': '25000',
      'status': 'قيد المراجعة',
    },
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: KokiColors.panelLight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KokiColors.background,
      appBar: AppBar(
        backgroundColor: KokiColors.background,
        foregroundColor: KokiColors.gold,
        title: const Text('إدارة KOKI PARTY'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildAdminHeader(),
          _buildMenu(),
          Expanded(
            child: _buildSectionContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      margin: const EdgeInsets.all(14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF56328A),
            Color(0xFF171326),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: KokiColors.gold.withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.admin_panel_settings_rounded,
            color: KokiColors.gold,
            size: 42,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ROYAL ADMIN',
                  style: TextStyle(
                    color: KokiColors.gold,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'لوحة إدارة التطبيق',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final item = menuItems[index];
          final selected = selectedSection == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedSection = index;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: selected
                    ? KokiColors.purple
                    : KokiColors.panel,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? KokiColors.gold
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: selected
                        ? Colors.white
                        : KokiColors.gold,
                    size: 17,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    item['title'] as String,
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
      ),
    );
  }

  Widget _buildSectionContent() {
    switch (selectedSection) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildAgentList(
          'وكلاء المضيفين',
          hostAgents,
        );
      case 2:
        return _buildAgentList(
          'وكلاء الشحن',
          rechargeAgents,
        );
      case 3:
        return _buildSimpleSection(
          'إدارة المضيفين',
          'متابعة المضيفين وساعات العمل والأرباح',
          Icons.mic_rounded,
        );
      case 4:
        return _buildSimpleSection(
          'الأرباح والسحب',
          'متابعة أرباح المضيفين وعمليات السحب',
          Icons.account_balance_wallet_rounded,
        );
      case 5:
        return _buildWithdrawals();
      case 6:
        return _buildSimpleSection(
          'إدارة المستخدمين',
          'عرض المستخدمين ومراجعة الحسابات والبلاغات',
          Icons.people_alt_rounded,
        );
      case 7:
        return _buildSimpleSection(
          'إدارة الغرف',
          'متابعة الغرف وإعداداتها والمشرفين',
          Icons.meeting_room_rounded,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                'المستخدمون',
                '1,250',
                Icons.people_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'الغرف',
                '24',
                Icons.meeting_room_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'المضيفون',
                '85',
                Icons.mic_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                'الوكلاء',
                '12',
                Icons.groups_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'إدارة النظام',
          style: TextStyle(
            color: KokiColors.gold,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'اختار القسم المطلوب من القائمة الموجودة فوق.',
          style: TextStyle(
            color: KokiColors.muted,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: KokiColors.panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: KokiColors.gold.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: KokiColors.gold, size: 27),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              color: KokiColors.muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentList(
    String title,
    List<Map<String, String>> agents,
  ) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        Text(
          title,
          style: const TextStyle(
            color: KokiColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => showMessage(
            'إضافة وكيل حقيقي تحتاج صلاحيات الإدارة والخادم',
          ),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('إضافة وكيل'),
          style: ElevatedButton.styleFrom(
            backgroundColor: KokiColors.purple,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        ...agents.map((agent) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: KokiColors.panel,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: KokiColors.purpleDark,
                  child: Icon(
                    Icons.person_rounded,
                    color: KokiColors.gold,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        agent['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'ID: ${agent['id']}',
                        style: const TextStyle(
                          color: KokiColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  agent['status']!,
                  style: const TextStyle(
                    color: KokiColors.green,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSimpleSection(
    String title,
    String description,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: KokiColors.gold,
              size: 55,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: KokiColors.muted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () => showMessage(
                'القسم ده هيتوصل بقاعدة البيانات في مرحلة الربط',
              ),
              child: const Text('فتح القسم'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawals() {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        const Text(
          'طلبات السحب',
          style: TextStyle(
            color: KokiColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...withdrawalRequests.map((request) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: KokiColors.panel,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: KokiColors.gold.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request['user']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'المبلغ: ${request['amount']} عملة',
                  style: const TextStyle(
                    color: KokiColors.gold,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'الحالة: ${request['status']}',
                  style: const TextStyle(
                    color: KokiColors.muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => showMessage(
                          'الموافقة الحقيقية تحتاج تسجيل العملية بالخادم',
                        ),
                        child: const Text('موافقة'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => showMessage(
                          'رفض الطلب يحتاج صلاحية إدارية',
                        ),
                        child: const Text('رفض'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

Widget _buildBottomNavigation() {
  return BottomNavigationBar(
    currentIndex: selectedTab,
    type: BottomNavigationBarType.fixed,
    backgroundColor: KokiColors.panel,
    selectedItemColor: KokiColors.gold,
    unselectedItemColor: KokiColors.muted,
    selectedFontSize: 11,
    unselectedFontSize: 10,
    items: const [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: 'الرئيسية',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.workspace_premium_rounded),
        label: 'اكتشف',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.meeting_room_rounded),
        label: 'الغرف',
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
    onTap: (index) {
      setState(() {
        selectedTab = index;
      });

      Widget? page;

      switch (index) {
        case 1:
          page = const VipRankingPage();
          break;
        case 2:
          page = const RoomsDirectoryPage();
          break;
        case 3:
          page = const MessagesPage();
          break;
        case 4:
          page = const AccountPage();
          break;
      }

      if (page != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page!),
        ).then((_) {
          if (mounted) {
            setState(() {
              selectedTab = 0;
            });
          }
        });
      }
    },
  );
}
