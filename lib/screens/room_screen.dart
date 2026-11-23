import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../services/auth_session.dart';

class RoomScreen extends StatefulWidget {
  final String roomTitle;
  final String hostName;
  final String roomId;

  const RoomScreen({
    super.key,
    required this.roomTitle,
    required this.hostName,
    required this.roomId,
  });

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  static const String apiUrl =
      'https://koki-party-new.onrender.com';

  static const Color gold = Color(0xFFFFD54F);
  static const Color purple = Color(0xFF150B2E);

  bool loading = true;
  bool busy = false;
  bool isMicMuted = true;

  Map<String, dynamic>? room;
  List<dynamic> seats = [];

  String? errorMessage;
  String? activeGiftBanner;

  final TextEditingController _chatController =
      TextEditingController();

  final List<Map<String, String>> _messages = [
    {
      'user': 'النظام',
      'text': 'مرحباً بكم في عالم KOKI PARTY الملكي 👑',
    },
  ];

  final List<Map<String, dynamic>> _gifts = [
    {'name': 'قلب ملكي', 'icon': '💖', 'price': 10},
    {'name': 'تاج الذهب', 'icon': '👑', 'price': 100},
    {'name': 'سيارة فاخرة', 'icon': '🏎️', 'price': 500},
    {'name': 'حصان مجنح', 'icon': '🦄', 'price': 1000},
    {'name': 'قلعة الأحلام', 'icon': '🏰', 'price': 2500},
    {'name': 'صاروخ VIP', 'icon': '🚀', 'price': 5000},
  ];

  String? get currentUserId =>
      AuthSession.user?['id']?.toString();

  bool get isRoomOwner =>
      currentUserId != null &&
      room?['ownerUserId']?.toString() == currentUserId;

  int get maxSeats =>
      (room?['maxSeats'] as num?)?.toInt() ?? 8;

  Map<String, String> get headers {
    final token = AuthSession.accessToken;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> apiRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient();

    try {
      final uri = Uri.parse('$apiUrl$path');
      final request = await client.openUrl(method, uri);

      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close();
      final responseText =
          await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          'خطأ من السيرفر (${response.statusCode}): $responseText',
        );
      }

      if (responseText.isEmpty) return null;

      return jsonDecode(responseText);
    } finally {
      client.close();
    }
  }

  @override
  void initState() {
    super.initState();
    loadRoomData();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> loadRoomData() async {
    if (mounted) {
      setState(() {
        loading = true;
        errorMessage = null;
      });
    }

    try {
      final results = await Future.wait([
        apiRequest('GET', '/api/rooms/${widget.roomId}'),
        apiRequest(
          'GET',
          '/api/rooms/${widget.roomId}/seats',
        ),
      ]);

      if (!mounted) return;

            final loadedSeats = List<dynamic>.from(results[1]);

      final mySeat = loadedSeats.where(
        (seat) => seat['userId']?.toString() == currentUserId,
      ).toList();

      setState(() {
        room = Map<String, dynamic>.from(results[0]);
        seats = loadedSeats;
        isMicMuted = mySeat.isEmpty ||
            mySeat.first['isMuted'] == true;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> takeSeat(int seatNumber) async {
    if (busy) return;

    if (AuthSession.accessToken == null) {
      showMessage('سجّل الدخول الأول علشان تحجز مقعد');
      return;
    }

    setState(() => busy = true);

    try {
      await apiRequest(
        'POST',
        '/api/rooms/${widget.roomId}/seats/$seatNumber/take',
      );

      await loadRoomData();
      showMessage('تم حجز المقعد رقم $seatNumber');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

    Future<void> leaveSeat() async {
    if (busy) return;

    setState(() => busy = true);

    try {
      await apiRequest(
        'DELETE',
        '/api/rooms/${widget.roomId}/seats/leave',
      );

      await loadRoomData();
      showMessage('تم ترك المقعد');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> toggleMic() async {
    if (busy) return;

    final mySeat = seats.where(
      (seat) => seat['userId']?.toString() == currentUserId,
    ).toList();

    if (mySeat.isEmpty) {
      showMessage('لازم تحجز مقعد الأول علشان تستخدم المايك');
      return;
    }

    final seatNumber =
        (mySeat.first['seatNumber'] as num).toInt();

    final newMuteState = !isMicMuted;

    setState(() => busy = true);

    try {
      await apiRequest(
        'PATCH',
        '/api/rooms/${widget.roomId}/seats/$seatNumber/mute',
        body: {'isMuted': newMuteState},
      );

      if (!mounted) return;

      setState(() {
        isMicMuted = newMuteState;
      });

      await loadRoomData();

      showMessage(
        newMuteState ? 'تم كتم المايك' : 'تم فتح المايك',
      );
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  Future<void> changeSeatCount(int count) async {
    if (busy) return;

    setState(() => busy = true);

    try {
      await apiRequest(
        'PATCH',
        '/api/rooms/${widget.roomId}',
        body: {'maxSeats': count},
      );

      await loadRoomData();
      showMessage('تم تحديث عدد المقاعد');
    } catch (e) {
      showMessage(e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: purple,
      ),
    );
  }
  void openSeatSettings() {
    if (!isRoomOwner) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: purple,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'إعدادات مقاعد الغرفة 👑',
                  style: TextStyle(
                    color: gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'اختار عدد المقاعد الجديد',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [10, 12, 15, 20].map((count) {
                    final selected = count == maxSeats;

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selected ? gold : const Color(0xFF302052),
                        foregroundColor:
                            selected ? purple : Colors.white,
                      ),
                      onPressed: busy
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              changeSeatCount(count);
                            },
                      child: Text('$count مقعد'),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                const Text(
                  'مش هتقدر تقلل العدد لو فيه أعضاء قاعدين في المقاعد اللي هتتشال.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
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

  void openGiftBox() {
    int selectedGiftIndex = 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: purple,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'صندوق الهدايا الملكية 🎁',
                      style: TextStyle(
                        color: gold,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics:
                          const NeverScrollableScrollPhysics(),
                      itemCount: _gifts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.05,
                      ),
                      itemBuilder: (_, i) {
                        final gift = _gifts[i];
                        final selected =
                            selectedGiftIndex == i;

                        return GestureDetector(
                          onTap: () => setModalState(
                            () => selectedGiftIndex = i,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF221347),
                              borderRadius:
                                  BorderRadius.circular(16),
                              border: Border.all(
                                color: selected
                                    ? gold
                                    : Colors.white12,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text(
                                  gift['icon'],
                                  style: const TextStyle(
                                    fontSize: 30,
                                  ),
                                ),
                                Text(
                                  gift['name'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${gift['price']} عملة',
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'واجهة الهدايا دي تجريبية ولسه مش بتخصم عملات حقيقية.',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إغلاق'),
                      ),
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

  void sendMessage() {
    final message = _chatController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add({
        'user': 'أنا',
        'text': message,
      });
      _chatController.clear();
    });
  }

  Widget buildSeat(Map<String, dynamic> seat) {
    final number = (seat['seatNumber'] as num?)?.toInt() ?? 0;
    final userId = seat['userId']?.toString();
    final occupied = userId != null && userId.isNotEmpty;
    final isMine = userId == currentUserId;

    return GestureDetector(
      onTap: () {
        if (occupied) {
          if (isMine) {
            leaveSeat();
          } else {
            showMessage('المقعد مشغول بالفعل');
          }
        } else {
          takeSeat(number);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: occupied
                  ? const Color(0xFF53317D)
                  : Colors.white.withValues(alpha: 0.08),
              border: Border.all(
                color: isMine ? gold : gold.withValues(alpha: 0.45),
                width: isMine ? 2.5 : 1,
              ),
            ),
            child: Icon(
              occupied
                  ? Icons.person_rounded
                  : Icons.chair_rounded,
              color: gold,
              size: 25,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            occupied
                ? (isMine ? 'أنت' : 'مشغول')
                : 'No.$number',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          if (occupied && seat['isMuted'] == true)
            const Icon(
              Icons.mic_off,
              color: Colors.white54,
              size: 12,
            ),
        ],
      ),
    );
  }

  Widget buildRoomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: gold.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 17,
                    backgroundColor: gold,
                    child: Icon(
                      Icons.workspace_premium,
                      color: purple,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          room?['name']?.toString() ??
                              widget.roomTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'ID: ${widget.roomId}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isRoomOwner)
            IconButton(
              tooltip: 'إعدادات المقاعد',
              onPressed: openSeatSettings,
              icon: const Icon(
                Icons.settings,
                color: gold,
              ),
            ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.power_settings_new_rounded,
              color: Colors.white70,
            ),
          ),
        ],
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
              colors: [
                Color(0xFF281052),
                Color(0xFF130729),
                Color(0xFF090414),
              ],
            ),
          ),
          child: SafeArea(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: gold,
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: gold,
                                size: 42,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'مش قادرين نحمل بيانات الغرفة',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: loadRoomData,
                                child: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          buildRoomHeader(),

                          if (activeGiftBanner != null)
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF6F00),
                                    Color(0xFFD500F9),
                                  ],
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

                          const SizedBox(height: 10),

                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      gold,
                                      Color(0xFFFF6F00),
                                      gold,
                                    ],
                                  ),
                                ),
                                child: const CircleAvatar(
                                  radius: 32,
                                  backgroundColor: Color(0xFF1D0D3B),
                                  child: Icon(
                                    Icons.person,
                                    color: gold,
                                    size: 35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: gold,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '👑 ${widget.hostName}',
                                  style: const TextStyle(
                                    color: purple,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'مقاعد الغرفة ($maxSeats)',
                                  style: const TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${seats.where((s) => s['userId'] != null).length} مشغول',
                                  style: const TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              itemCount: seats.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.85,
                              ),
                              itemBuilder: (_, index) {
                                final seat =
                                    Map<String, dynamic>.from(
                                  seats[index],
                                );
                                return buildSeat(seat);
                              },
                            ),
                          ),

                          const SizedBox(height: 8),

                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              itemCount: _messages.length,
                              itemBuilder: (_, i) {
                                final msg = _messages[i];

                                return Align(
                                  alignment: Alignment.centerRight,
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                      bottom: 6,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${msg['user']}: ',
                                            style: const TextStyle(
                                              color: gold,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          TextSpan(
                                            text: msg['text'],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(22),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _chatController,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                            ),
                                            decoration:
                                                const InputDecoration(
                                              hintText: 'اكتب رسالة...',
                                              hintStyle: TextStyle(
                                                color: Colors.white54,
                                              ),
                                              border: InputBorder.none,
                                            ),
                                            onSubmitted: (_) =>
                                                sendMessage(),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: sendMessage,
                                          child: const Icon(
                                            Icons.send_rounded,
                                            color: gold,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.12),
                                  child: IconButton(
                                    icon: Icon(
                                      isMicMuted
                                          ? Icons.mic_off_rounded
                                          : Icons.mic_rounded,
                                      color: isMicMuted
                                          ? Colors.redAccent
                                          : Colors.white,
                                    ),
                                    onPressed: toggleMic,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: openGiftBox,
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF6F00),
                                          Color(0xFFE040FB),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.card_giftcard_rounded,
                                      color: Colors.white,
                                    ),
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
