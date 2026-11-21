
import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  final String roomName;
  final Map<String, dynamic>? roomData;

  const RoomScreen({
    super.key,
    this.roomName = 'غرفة الملوك',
    this.roomData,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  static const Color bg = Color(0xFF090711);
  static const Color panel = Color(0xFF191529);
  static const Color gold = Color(0xFFFFD36A);
  static const Color purple = Color(0xFF8957F5);

  bool isMuted = false;
  bool allowRequests = true;

  late String ownerName;
  late List<String?> seats;

  final List<String> messages = [
    'أهلاً بيكم في KOKI PARTY 👑',
    'منورين الغرفة ❤️',
  ];

  final TextEditingController messageController =
      TextEditingController();

  bool get isOwner => ownerName == 'KOKI USER';

  @override
  void initState() {
    super.initState();

    ownerName = widget.roomData?['owner']?.toString()
        ?? 'KOKI USER';

    allowRequests =
        widget.roomData?['allowRequests'] as bool? ?? true;

    seats = List<String?>.filled(8, null);
    seats[0] = ownerName;
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  String get roomDescription =>
      widget.roomData?['description']?.toString() ??
      'غرفة صوتية ملكية • 8 مقاعد';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: panel,
          foregroundColor: gold,
          centerTitle: true,
          title: Text(widget.roomName),
          actions: [
            IconButton(
              onPressed: roomMenu,
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
        body: Column(
          children: [
            roomHeader(),
            Expanded(child: buildSeats()),
            buildChat(),
            buildControls(),
          ],
        ),
      ),
    );
  }

  Widget roomHeader() {
    final occupied = seats.where((user) => user != null).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      color: panel,
      child: Column(
        children: [
          const Icon(
            Icons.workspace_premium,
            color: gold,
            size: 35,
          ),
          const SizedBox(height: 7),
          const Text(
            'THE ROYAL WORLD',
            style: TextStyle(
              color: gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            roomDescription.isEmpty
                ? 'غرفة صوتية ملكية'
                : roomDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people, color: gold, size: 17),
              const SizedBox(width: 5),
              Text(
                '$occupied/8 مقاعد',
                style: const TextStyle(color: Colors.white70),
              ),
              if (widget.roomData?['isPrivate'] == true) ...[
                const SizedBox(width: 12),
                const Icon(Icons.lock, color: gold, size: 15),
                const SizedBox(width: 4),
                const Text(
                  'خاصة',
                  style: TextStyle(color: gold),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSeats() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) => seatItem(index),
    );
  }

  Widget seatItem(int index) {
    final user = seats[index];
    final occupied = user != null;

    return InkWell(
      onTap: () => onSeatTap(index),
      borderRadius: BorderRadius.circular(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: occupied ? purple : panel,
              border: Border.all(
                color: occupied ? gold : Colors.white24,
                width: 2,
              ),
            ),
            child: Icon(
              occupied ? Icons.person : Icons.add,
              color: occupied ? gold : Colors.white70,
              size: 30,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            occupied ? user! : 'مقعد ${index + 1}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Icon(
            occupied ? Icons.mic : Icons.mic_off,
            color: occupied ? gold : Colors.white38,
            size: 17,
          ),
        ],
      ),
    );
  }

  void onSeatTap(int index) {
    if (seats[index] == null) {
      if (!allowRequests && !isOwner) {
        showMessage('طلبات المايك غير متاحة حاليًا');
        return;
      }

      setState(() {
        seats[index] = 'أنت';
      });

      showMessage('تم الانضمام للمقعد تجريبيًا');
      return;
    }

    if (isOwner && index != 0) {
      showSeatOptions(index);
    } else {
      showMessage('المقعد مشغول بواسطة ${seats[index]}');
    }
  }
  
  Widget buildChat() {
    return Container(
      height: 165,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      color: panel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'دردشة الغرفة',
            style: TextStyle(
              color: gold,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 7),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    messages[index],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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
                  controller: messageController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle:
                        const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: bg,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => sendMessage(),
                ),
              ),
              IconButton(
                onPressed: sendMessage,
                icon: const Icon(Icons.send, color: gold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add('أنت: $text');
      messageController.clear();
    });
  }

  Widget buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 20),
      color: const Color(0xFF120F20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          controlButton(
            isMuted ? Icons.mic_off : Icons.mic,
            isMuted ? 'فتح المايك' : 'كتم المايك',
            () {
              setState(() => isMuted = !isMuted);
              showMessage(
                isMuted ? 'تم كتم المايك' : 'تم فتح المايك',
              );
            },
          ),
          controlButton(
            Icons.card_giftcard,
            'الهدايا',
            openGifts,
          ),
          controlButton(
            Icons.chat,
            'الدردشة',
            () => showMessage('اكتب رسالتك في صندوق الدردشة'),
          ),
          controlButton(
            Icons.settings,
            'الإدارة',
            roomMenu,
          ),
        ],
      ),
    );
  }

  Widget controlButton(
    IconData icon,
    String label,
    VoidCallback action,
  ) {
    return InkWell(
      onTap: action,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: gold, size: 25),
          const SizedBox(height: 5),
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

  void openGifts() {
    final gifts = [
      ['❤️', 'قلب'],
      ['🌹', 'وردة'],
      ['👑', 'تاج'],
      ['💎', 'ماسة'],
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'هدايا KOKI PARTY',
                  style: TextStyle(
                    color: gold,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: gifts.map((gift) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(sheetContext);
                        showMessage(
                          'اخترت ${gift[1]} - الهدية تجريبية',
                        );
                      },
                      child: Column(
                        children: [
                          Text(
                            gift[0],
                            style: const TextStyle(fontSize: 32),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            gift[1],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void roomMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isOwner)
                ListTile(
                  leading: const Icon(
                    Icons.people,
                    color: gold,
                  ),
                  title: const Text(
                    'إدارة المقاعد',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    showMessage('اضغط على مقعد لإدارته');
                  },
                ),
              if (isOwner)
                SwitchListTile(
                  value: allowRequests,
                  activeColor: gold,
                  title: const Text(
                    'السماح بطلب المايك',
                    style: TextStyle(color: Colors.white),
                  ),
                  onChanged: (value) {
                    setState(() => allowRequests = value);
                    Navigator.pop(sheetContext);
                  },
                ),
              ListTile(
                leading: const Icon(
                  Icons.shield,
                  color: gold,
                ),
                title: const Text(
                  'إدارة المشرفين',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  showMessage('إدارة المشرفين قيد الربط');
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.exit_to_app,
                  color: gold,
                ),
                title: const Text(
                  'مغادرة الغرفة',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showSeatOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.person_remove,
                  color: gold,
                ),
                title: const Text(
                  'إخلاء المقعد',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  setState(() => seats[index] = null);
                  showMessage('تم إخلاء المقعد تجريبيًا');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
