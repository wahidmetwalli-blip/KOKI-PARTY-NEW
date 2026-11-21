import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  final String roomTitle;
  final String hostName;
  final String roomId;

  const RoomScreen({
    super.key,
    this.roomTitle = 'غرفة الملوك VIP',
    this.hostName = 'KOKI KING',
    this.roomId = '10001',
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  bool isMicMuted = false;
  int coins = 10000;
  String? activeGiftBanner;

  final TextEditingController _chatController = TextEditingController();
  
final List<Map<String, String>> _messages = [
  
    {'user': 'النظام', 'text': 'مرحباً بكم في عالم KOKI PARTY الملكي 👑'},
    {'user': 'Amira VIP', 'text': 'منورين الغرفة جميعاً ✨'},
  ];

  
final List<Map<String, dynamic>> _gifts = [
  
    {'name': 'قلب ملكي', 'icon': '💖', 'price': 10},
    {'name': 'تاج الذهب', 'icon': '👑', 'price': 100},
    {'name': 'سيارة فاخرة', 'icon': '🏎️', 'price': 500},
    {'name': 'حصان مجنح', 'icon': '🦄', 'price': 1000},
    {'name': 'قلعة الأحلام', 'icon': '🏰', 'price': 2500},
    {'name': 'صاروخ VIP', 'icon': '🚀', 'price': 5000},
  ];

  void _sendMessage() {
    final txt = _chatController.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _messages.add({'user': 'KOKI USER', 'text': txt});
      _chatController.clear();
    });
  }

  void _openGiftBox() {
    int selectedGiftIndex = 0;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF150B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'صندوق الهدايا الملكية 🎁',
                        style: TextStyle(
                          color: Color(0xFFFFD54F),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          'الرصيد: $coins 💰',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _gifts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.05,
                    ),
                    itemBuilder: (_, i) {
                      final g = _gifts[i];
                      final String iconText = g['icon'] as String;
                      final String nameText = g['name'] as String;
                      final int priceVal = g['price'] as int;
                      final selected = selectedGiftIndex == i;
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedGiftIndex = i),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF221347),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected ? const Color(0xFFFFD54F) : Colors.white12,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(iconText, style: const TextStyle(fontSize: 30)),
                              const SizedBox(height: 4),
                              Text(
                                nameText,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                              Text(
                                '$priceVal عملة',
                                style: const TextStyle(
                                  color: Color(0xFFFFD54F),
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD54F),
                        foregroundColor: const Color(0xFF120826),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        final gift = _gifts[selectedGiftIndex];
                        final int price = gift['price'] as int;
                        final String giftName = gift['name'] as String;
                        final String giftIcon = gift['icon'] as String;
                        if (coins >= price) {
                          Navigator.pop(ctx);
                          setState(() {
                            coins -= price;
                            activeGiftBanner =
                                'أرسل KOKI USER هدية $giftName $giftIcon';
                            _messages.add({
                              'user': 'هدية ملكية',
                              'text': 'أرسل KOKI USER $giftName $giftIcon',
                            });
                          });
                          Future.delayed(const Duration(seconds: 3), () {
                            if (mounted) {
                              setState(() => activeGiftBanner = null);
                            }
                          });
                        }
                      },
                      child: const Text(
                        'إرسال الهدية الآن',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF281052), Color(0xFF130729), Color(0xFF090414)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Color(0xFFFFD54F),
                              child: Icon(Icons.workspace_premium, color: Color(0xFF120826), size: 18),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.roomTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'ID: ${widget.roomId}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                if (activeGiftBanner != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6F00), Color(0xFFD500F9)],
                      ),
                    ),
                    child: Text(
                      activeGiftBanner!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD54F), Color(0xFFFF6F00), Color(0xFFFFD54F)],
                        ),
                      ),
                      child: const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFF1D0D3B),
                        child: Icon(Icons.person, color: Color(0xFFFFD54F), size: 36),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '👑 ${widget.hostName}',
                        style: const TextStyle(
                          color: Color(0xFF120826),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 8,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemBuilder: (_, index) {
                      return Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: const Color(0xFFFFD54F).withValues(alpha: 0.45),
                              ),
                            ),
                            child: const Icon(
                              Icons.chair_rounded,
                              color: Color(0xFFFFD54F),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No.${index + 1}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      return Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black38,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${msg['user']}: ',
                                  style: const TextStyle(
                                    color: Color(0xFFFFD54F),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                TextSpan(
                                  text: msg['text'],
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _chatController,
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                  decoration: const InputDecoration(
                                    hintText: 'اكتب رسالة...',
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: _sendMessage,
                                child: const Icon(Icons.send_rounded, color: Color(0xFFFFD54F), size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.12),
                        child: IconButton(
                          icon: Icon(
                            isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            color: isMicMuted ? Colors.redAccent : Colors.white,
                          ),
                          onPressed: () => setState(() => isMicMuted = !isMicMuted),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _openGiftBox,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFFF6F00), Color(0xFFE040FB)],
                            ),
                          ),
                          child: const Icon(Icons.card_giftcard_rounded, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
