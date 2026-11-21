
import 'package:flutter/material.dart';

class RoomScreen extends StatefulWidget {
  final String roomName;

  const RoomScreen({
    super.key,
    this.roomName = 'غرفة الملوك',
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
  bool isOwner = true;

  final List<String> seats = [
    'صاحب الروم',
    'مقعد 2',
    'مقعد 3',
    'مقعد 4',
    'مقعد 5',
    'مقعد 6',
    'مقعد 7',
    'مقعد 8',
  ];

  final List<String> messages = [
    'أهلاً بيكم في KOKI PARTY 👑',
    'منورين غرفة الملوك ❤️',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: panel,
        foregroundColor: gold,
        title: Text(widget.roomName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _roomMenu,
          ),
        ],
      ),
      body: Column(
        children: [
          _roomHeader(),
          Expanded(
            child: _buildSeats(),
          ),
          _buildChat(),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _roomHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: panel,
      child: const Column(
        children: [
          Text(
            'THE ROYAL WORLD',
            style: TextStyle(
              color: gold,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'غرفة صوتية ملكية • 8 مقاعد',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSeats() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: seats.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 18,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        return _seatItem(index);
      },
    );
  }
  

  Widget _seatItem(int index) {
    final bool occupied = index == 0;

    return Column(
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
          occupied ? 'صاحب الروم' : 'مقعد ${index + 1}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
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
    );
  }

  Widget _buildChat() {
    return Container(
      height: 125,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 8),
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
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 22),
      color: const Color(0xFF120F20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _controlButton(
            isMuted ? Icons.mic_off : Icons.mic,
            isMuted ? 'فتح المايك' : 'كتم المايك',
            () {
              setState(() {
                isMuted = !isMuted;
              });
            },
          ),
          _controlButton(
            Icons.card_giftcard,
            'الهدايا',
            () {
              _showMessage('الهدايا هتتربط بنظام المحفظة لاحقاً');
            },
          ),
          _controlButton(
            Icons.chat,
            'الدردشة',
            () {
              _showMessage('الدردشة ظاهرة داخل الغرفة');
            },
          ),
          _controlButton(
            Icons.settings,
            'الإدارة',
            _roomMenu,
          ),
        ],
      ),
    );
  }

  Widget _controlButton(
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

  void _roomMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: panel,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.people, color: gold),
                title: const Text(
                  'إدارة المقاعد',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showMessage('إدارة المقاعد قيد الربط');
                },
              ),
              ListTile(
                leading: const Icon(Icons.shield, color: gold),
                title: const Text(
                  'إدارة المشرفين',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showMessage('إدارة المشرفين قيد الربط');
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: gold),
                title: const Text(
                  'مغادرة الغرفة',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
