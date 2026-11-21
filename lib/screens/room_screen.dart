
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
  
