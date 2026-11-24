import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

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

class _RoomScreenState extends State<RoomScreen>
    with SingleTickerProviderStateMixin {
  static const String apiUrl = 'https://koki-party-new.onrender.com';

  // لوحة ألوان فاخرة (Ultra Luxury Noir + Champagne Gold + Amethyst)
  static const Color luxuryVoid = Color(0xFF070312);
  static const Color luxuryObsidian = Color(0xFF130829);
  static const Color luxuryPanel = Color(0xFF1E0D40);
  static const Color luxurySurface = Color(0xFF291257);
  static const Color champagneGold = Color(0xFFFFF0B3);
  static const Color pureGold = Color(0xFFFFC93C);
  static const Color antiqueGold = Color(0xFFB87914);
  static const Color royalAmethyst = Color(0xFF9C5CFF);

  bool loading = true;
  bool busy = false;
  bool isMicMuted = true;
  bool giftsLoading = false;
  int _selectedTabIndex = 0;

  Map<String, dynamic>? room;
  List<dynamic> seats = [];

  String? errorMessage;
  String? activeGiftBanner;
  Timer? _giftBannerTimer;

  late final AnimationController _auraController;
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

    final List<Map<String, dynamic>> _messages = [
    {
      'user': 'النظام الفاخر',
      'text': 'أهلًا بك في صالون KOKI PARTY الفاخر ✨ استمتع بأجواء راقية.',
      'isSystem': 'true',
    },
  ];

   List<Map<String, dynamic>> _gifts = [];
  
  String? get currentUserId => AuthSession.user?['id']?.toString();
  String? get ownerUserId => room?['ownerUserId']?.toString();

  bool get isRoomOwner =>
      currentUserId != null &&
      ownerUserId != null &&
      ownerUserId == currentUserId;

  int get maxSeats => (room?['maxSeats'] as num?)?.toInt() ?? 8;

  bool get isCurrentUserSeated => seats.any(
        (seat) => seat['userId']?.toString() == currentUserId,
      );

  Map<String, String> get headers {
    final token = AuthSession.accessToken;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  String formatShortId(String? rawId) {
    if (rawId == null || rawId.trim().isEmpty) return '0000';
    final cleaned = rawId.replaceAll('-', '').trim();
    if (cleaned.length <= 6) return cleaned.toUpperCase();
    final hash = cleaned.codeUnits.fold<int>(
      0,
      (acc, c) => (acc * 31 + c) % 9000,
    );
    return '${1000 + hash}';
  }

  String formatMemberLabel(Map<String, dynamic>? data, {String? fallbackId}) {
    final candidates = [
      data?['userName'],
      data?['displayName'],
      data?['username'],
      data?['name'],
    ];
    for (final item in candidates) {
      final value = item?.toString().trim();
      if (value != null && value.isNotEmpty && !_looksLikeUuid(value)) {
        return value;
      }
    }
    final id = data?['userId']?.toString() ?? fallbackId;
    return 'عضو #${formatShortId(id)}';
  }

  bool _looksLikeUuid(String value) => value.length >= 24 && value.contains('-');

  Future<dynamic> apiRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('$apiUrl$path');
      final request = await client.openUrl(method, uri);
      headers.forEach((key, value) => request.headers.set(key, value));
      if (body != null) {
        request.write(jsonEncode(body));
      }
      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('خطأ من السيرفر (${response.statusCode}): $responseText');
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
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    loadRoomData();
    loadGifts();
  }

  @override
  void dispose() {
    _giftBannerTimer?.cancel();
    _auraController.dispose();
    _chatController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }
      Future<void> loadGifts() async {
    if (giftsLoading) return;
    if (mounted) setState(() => giftsLoading = true);

    try {
      final response = await apiRequest('GET', '/api/gifts');
      final data = response is Map ? response['data'] : response;
      if (data is! List) {
        throw Exception('قائمة الهدايا غير صحيحة');
      }
      if (!mounted) return;
      setState(() {
        _gifts = data
            .map((gift) => Map<String, dynamic>.from(gift as Map))
            .toList();
      });
    } catch (e) {
      if (mounted) showMessage('تعذر تحميل الهدايا: $e');
    } finally {
      if (mounted) setState(() => giftsLoading = false);
    }
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
        apiRequest('GET', '/api/rooms/${widget.roomId}/seats'),
      ]);

      if (!mounted) return;
      final loadedSeats = List<dynamic>.from(results[1] ?? []);
      final mySeat = loadedSeats
          .where((seat) => seat['userId']?.toString() == currentUserId)
          .toList();

      setState(() {
        room = Map<String, dynamic>.from(results[0] ?? {});
        seats = loadedSeats;
        isMicMuted = mySeat.isEmpty || mySeat.first['isMuted'] == true;
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
    setState(() => busy = true);

    try {
      await apiRequest(
        'POST',
        '/api/rooms/${widget.roomId}/seats/$seatNumber/take',
      );
      await loadRoomData();
      showMessage('تم اعتلاء المقعد رقم $seatNumber بنجاح ✨');
    } catch (e) {
      showMessage('تعذر حجز المقعد: $e');
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
      showMessage('تم النزول من المقعد');
    } catch (e) {
      showMessage('تعذر مغادرة المقعد: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> toggleMic() async {
    final mySeats = seats
        .where((seat) => seat['userId']?.toString() == currentUserId)
        .toList();

    if (mySeats.isEmpty) {
      showMessage('اصعد على مقعد أولًا لتشغيل المايك');
      return;
    }

    final seatNumber = (mySeats.first['seatNumber'] as num).toInt();
    final newMuteState = !isMicMuted;

    try {
      await apiRequest(
        'PATCH',
        '/api/rooms/${widget.roomId}/seats/$seatNumber/mute',
        body: {'isMuted': newMuteState},
      );
      if (!mounted) return;
      setState(() => isMicMuted = newMuteState);
      await loadRoomData();
    } catch (e) {
      showMessage('تعذر تغيير حالة المايك: $e');
    }
  }

  Future<void> changeSeatCount(int count) async {
    if (!isRoomOwner || busy) return;
    setState(() => busy = true);

    try {
      await apiRequest(
        'PATCH',
        '/api/rooms/${widget.roomId}',
        body: {'maxSeats': count},
      );
      await loadRoomData();
      showMessage('تم تحديث عدد المقاعد إلى $count مقعد');
    } catch (e) {
      showMessage('تعذر تحديث المقاعد: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _sendLocalMessage() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    final senderLabel = formatMemberLabel(
      AuthSession.user,
      fallbackId: currentUserId,
    );

    setState(() {
      _messages.add({
        'user': senderLabel,
        'text': text,
        'isSystem': 'false',
      });
      _chatController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: luxurySurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: pureGold.withOpacity(0.55)),
        ),
      ),
    );
  }

  void openSeatSettings() {
    if (!isRoomOwner) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: luxuryObsidian,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [champagneGold, antiqueGold],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Text(
                  'إعدادات مقاعد الصالون الفاخر',
                  style: TextStyle(
                    color: champagneGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                ...[8, 10, 12, 15, 20].map(
                  (count) => ListTile(
                    leading: const Icon(Icons.chair_alt_rounded, color: pureGold),
                    title: Text(
                      '$count مقعد',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: count == maxSeats
                        ? const Icon(Icons.check_circle_rounded, color: pureGold)
                        : null,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      changeSeatCount(count);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSeatPressed(int seatNumber, Map<String, dynamic>? seatData) {
    final occupantId = seatData?['userId']?.toString();
    final isOccupied = occupantId != null && occupantId.isNotEmpty;

    if (!isOccupied) {
      takeSeat(seatNumber);
      return;
    }

    if (occupantId == currentUserId) {
      showModalBottomSheet(
        context: context,
        backgroundColor: luxuryObsidian,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        builder: (sheetCtx) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'تحكم المقعد #$seatNumber',
                  style: const TextStyle(
                    color: champagneGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: Icon(
                    isMicMuted ? Icons.mic_rounded : Icons.mic_off_rounded,
                    color: pureGold,
                  ),
                  title: Text(
                    isMicMuted ? 'فتح المايك' : 'كتم المايك',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    toggleMic();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: const Text(
                    'النزول من المقعد',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                  onTap: () {
                    Navigator.pop(sheetCtx);
                    leaveSeat();
                  },
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    openGiftBox(preselectedSeatNumber: seatNumber);
  }

  Future<void> _sendGiftToSeat(
    Map<String, dynamic> gift,
    int seatNumber,
    String hostUserId,
    String recipientLabel,
  ) async {
    if (busy) return;

    final senderId = currentUserId;
    if (senderId == null || senderId.isEmpty) {
      showMessage('سجل الدخول أولًا');
      return;
    }

    final giftId = gift['id']?.toString();
    final giftName = gift['name']?.toString() ?? 'هدية';
    final rawEmoji = gift['emoji']?.toString();
    final giftEmoji = (rawEmoji == null || rawEmoji.isEmpty) ? '🎁' : rawEmoji;
    final giftPrice = gift['coinPrice']?.toString() ?? '0';

    if (giftId == null || giftId.isEmpty) {
      showMessage('الهدية غير صالحة');
      return;
    }

    if (hostUserId.isEmpty || hostUserId == senderId) {
      showMessage('اختر مضيفًا آخر لإرسال الهدية');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: luxuryObsidian,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: pureGold.withOpacity(0.6)),
          ),
          title: const Text(
            'تأكيد إرسال الهدية الفاخرة',
            style: TextStyle(color: champagneGold, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'إرسال $giftEmoji $giftName إلى $recipientLabel (مقعد $seatNumber) مقابل $giftPrice عملة؟',
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: pureGold,
                foregroundColor: luxuryVoid,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'إرسال الهدية',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    setState(() => busy = true);

    try {
      final latestSeatsResponse = await apiRequest(
        'GET',
        '/api/rooms/${widget.roomId}/seats',
      );
      final latestSeats = List<dynamic>.from(latestSeatsResponse ?? []);

      final recipientStillSeated = latestSeats.any(
        (seat) =>
            seat['seatNumber']?.toString() == seatNumber.toString() &&
            seat['userId']?.toString() == hostUserId,
      );

      if (!recipientStillSeated) {
        throw Exception('المضيف غادر المقعد، اختر مقعدًا آخر');
      }

      await apiRequest(
        'POST',
        '/api/host-diamonds/send-gift',
        body: {
          'giftId': giftId,
          'hostUserId': hostUserId,
          'reference':
              'room-${widget.roomId}-seat-$seatNumber-${DateTime.now().millisecondsSinceEpoch}',
          'roomId': widget.roomId,
          'seatNumber': seatNumber,
          'description': 'هدية $giftName داخل الغرفة',
        },
      );

      if (!mounted) return;
      _giftBannerTimer?.cancel();
      setState(() {
        activeGiftBanner = '$giftEmoji أُرسلت $giftName إلى $recipientLabel';
      });
      _giftBannerTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => activeGiftBanner = null);
      });

      showMessage('تم إرسال الهدية بنجاح ✨');
      await loadRoomData();
    } catch (e) {
      showMessage('تعذر إرسال الهدية: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
    void openGiftBox({int? preselectedSeatNumber}) {
    if (giftsLoading) {
      showMessage('جاري تحميل الهدايا...');
      return;
    }

    if (_gifts.isEmpty) {
      showMessage('لا توجد هدايا متاحة حاليًا');
      loadGifts();
      return;
    }

    final occupiedSeats = seats.where((seat) {
      final userId = seat['userId']?.toString();
      return userId != null && userId.isNotEmpty && userId != currentUserId;
    }).toList();

    if (occupiedSeats.isEmpty) {
      showMessage('يجب وجود مضيف أو عضو على مقعد لإرسال هدية');
      return;
    }

    int selectedGiftIndex = 0;
    int? selectedSeatNumber = preselectedSeatNumber;

    final hasPreselected = selectedSeatNumber != null &&
        occupiedSeats.any(
          (s) => (s['seatNumber'] as num?)?.toInt() == selectedSeatNumber,
        );

    if (!hasPreselected) {
      selectedSeatNumber = (occupiedSeats.first['seatNumber'] as num?)?.toInt();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: luxuryObsidian,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (selectedGiftIndex >= _gifts.length) {
              selectedGiftIndex = 0;
            }
            final selectedGift = _gifts[selectedGiftIndex];

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 14,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 18,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 48,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [champagneGold, antiqueGold],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const Text(
                        '✨ خزنة الهدايا الفاخرة',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: champagneGold,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'اختر المستلم على المقعد:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: occupiedSeats.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, idx) {
                            final seat = Map<String, dynamic>.from(
                              occupiedSeats[idx],
                            );
                            final numSeat =
                                (seat['seatNumber'] as num?)?.toInt() ?? -1;
                            final isSelected = selectedSeatNumber == numSeat;
                            final label = formatMemberLabel(seat);

                            return ChoiceChip(
                              selected: isSelected,
                              selectedColor: pureGold,
                              backgroundColor: luxuryPanel,
                              side: BorderSide(
                                color: isSelected
                                    ? champagneGold
                                    : pureGold.withOpacity(0.4),
                              ),
                              label: Text(
                                'مقعد $numSeat · $label',
                                style: TextStyle(
                                  color: isSelected ? luxuryVoid : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              onSelected: (_) {
                                setSheetState(() {
                                  selectedSeatNumber = numSeat;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'اختر الهدية:',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _gifts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.88,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) {
                          final gift = _gifts[index];
                          final emoji = gift['emoji']?.toString() ?? '🎁';
                          final name = gift['name']?.toString() ?? 'هدية';
                          final price = gift['coinPrice']?.toString() ?? '0';
                          final selected = selectedGiftIndex == index;

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setSheetState(() {
                                selectedGiftIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                gradient: selected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF471B9E),
                                          Color(0xFF1F0C47),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : const LinearGradient(
                                        colors: [
                                          luxuryPanel,
                                          luxuryObsidian,
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: selected
                                      ? champagneGold
                                      : pureGold.withOpacity(0.22),
                                  width: selected ? 2 : 1,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: pureGold.withOpacity(0.32),
                                          blurRadius: 12,
                                        ),
                                      ]
                                    : null,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: pureGold.withOpacity(0.35),
                                      ),
                                    ),
                                    child: Text(
                                      '$price عملة',
                                      style: const TextStyle(
                                        color: champagneGold,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [champagneGold, pureGold, antiqueGold],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: pureGold.withOpacity(0.4),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: luxuryVoid,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: selectedSeatNumber == null || busy
                              ? null
                              : () {
                                  final matchingSeats = occupiedSeats.where(
                                    (seat) =>
                                        (seat['seatNumber'] as num?)?.toInt() ==
                                        selectedSeatNumber,
                                  );
                                  if (matchingSeats.isEmpty) return;

                                  final targetSeat = Map<String, dynamic>.from(
                                    matchingSeats.first,
                                  );
                                  final hostId =
                                      targetSeat['userId']?.toString() ?? '';
                                  final label = formatMemberLabel(targetSeat);

                                  Navigator.pop(sheetContext);
                                  _sendGiftToSeat(
                                    selectedGift,
                                    selectedSeatNumber!,
                                    hostId,
                                    label,
                                  );
                                },
                          icon: const Icon(Icons.diamond_rounded),
                          label: Text(
                            'إرسال ${selectedGift['name'] ?? 'الهدية'} (${selectedGift['coinPrice'] ?? 0} عملة)',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Map<String, dynamic>? _findSeatByNumber(int seatNumber) {
    for (final raw in seats) {
      if ((raw['seatNumber'] as num?)?.toInt() == seatNumber) {
        return Map<String, dynamic>.from(raw);
      }
    }
    return null;
  }

  Widget _buildLuxuryHeader() {
    final displayTitle =
        room?['title']?.toString().trim().isNotEmpty == true
            ? room!['title'].toString()
            : widget.roomTitle;

    final cleanHostName = !_looksLikeUuid(widget.hostName) &&
            widget.hostName.trim().isNotEmpty
        ? widget.hostName
        : 'مضيف #${formatShortId(ownerUserId)}';

    final shortRoomCode = formatShortId(widget.roomId);
    final occupiedCount = seats
        .where((s) => s['userId'] != null && s['userId'].toString().isNotEmpty)
        .length;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            luxurySurface,
            luxuryPanel,
            luxuryObsidian,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: pureGold.withOpacity(0.6), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: pureGold.withOpacity(0.14),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [champagneGold, pureGold, antiqueGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: pureGold.withOpacity(0.45),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: luxuryVoid,
              size: 25,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            pureGold.withOpacity(0.25),
                            antiqueGold.withOpacity(0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: pureGold.withOpacity(0.65)),
                      ),
                      child: Text(
                        'ID: $shortRoomCode',
                        style: const TextStyle(
                          color: champagneGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.workspace_premium,
                        color: pureGold, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        cleanHostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.people_alt_rounded,
                        color: pureGold.withOpacity(0.9), size: 14),
                    const SizedBox(width: 3),
                    Text(
                      '$occupiedCount/$maxSeats',
                      style: const TextStyle(
                        color: champagneGold,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
                      )
            Widget _buildTabsAndFeed() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              luxuryObsidian.withOpacity(0.85),
              luxuryVoid.withOpacity(0.92),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: pureGold.withOpacity(0.32)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: Row(
                children: [
                  _buildTabChip(
                    'الدردشة',
                    0,
                    Icons.chat_bubble_outline_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildTabChip(
                    'قواعد الصالون',
                    1,
                    Icons.auto_awesome_rounded,
                  ),
                ],
              ),
            ),
            Divider(color: pureGold.withOpacity(0.14), height: 1),
            Expanded(
              child: _selectedTabIndex == 0
                  ? ListView.builder(
                      controller: _chatScrollController,
                      padding: const EdgeInsets.all(10),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        final isSystem = msg['isSystem'] == 'true';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSystem
                                ? LinearGradient(
                                    colors: [
                                      pureGold.withOpacity(0.18),
                                      antiqueGold.withOpacity(0.08),
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      luxuryPanel.withOpacity(0.85),
                                      luxuryObsidian.withOpacity(0.85),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(
                              color: isSystem
                                  ? pureGold.withOpacity(0.5)
                                  : pureGold.withOpacity(0.14),
                            ),
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${msg['user']}: ',
                                  style: TextStyle(
                                    color: isSystem
                                        ? champagneGold
                                        : pureGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                TextSpan(
                                  text: msg['text'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Padding(
                      padding: const EdgeInsets.all(14),
                      child: ListView(
                        children: [
                          _buildInfoRow(
                            Icons.diamond_rounded,
                            'إرسال الهدايا الفاخرة',
                            'تُرسل الهدايا مباشرة للمضيف أو العضو الجالس على المقعد المختار عبر السيرفر.',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            Icons.mic_rounded,
                            'المايك والمقاعد',
                            'اضغط على مقعد متاح للصعود عليه، ثم تحكم في المايك من الشريط السفلي.',
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            Icons.shield_rounded,
                            'أجواء الصالون',
                            'نحافظ على تجربة راقية ومحترمة لجميع أعضاء KOKI PARTY.',
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label, int index, IconData icon) {
    final active = _selectedTabIndex == index;
    return InkWell(
      borderRadius: BorderRadius.circular(13),
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [champagneGold, pureGold, antiqueGold],
                )
              : null,
          color: active ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(13),
          border: active
              ? null
              : Border.all(color: pureGold.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: active ? luxuryVoid : Colors.white70,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? luxuryVoid : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: luxuryPanel.withOpacity(0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: pureGold.withOpacity(0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: pureGold, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: champagneGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [luxuryObsidian, luxuryVoid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          top: BorderSide(color: pureGold.withOpacity(0.38)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                color: luxuryPanel,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: pureGold.withOpacity(0.45)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendLocalMessage(),
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة في الصالون...',
                        hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _sendLocalMessage,
                    icon: const Icon(
                      Icons.send_rounded,
                      color: pureGold,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          InkWell(
            onTap: toggleMic,
            borderRadius: BorderRadius.circular(23),
            child: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMicMuted
                    ? luxuryPanel
                    : Colors.green.withOpacity(0.25),
                border: Border.all(
                  color: isMicMuted
                      ? pureGold.withOpacity(0.35)
                      : Colors.greenAccent,
                ),
              ),
              child: Icon(
                isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                color: isMicMuted ? champagneGold : Colors.greenAccent,
                size: 21,
              ),
            ),
          ),

          if (isCurrentUserSeated) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: leaveSeat,
              borderRadius: BorderRadius.circular(23),
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent.withOpacity(0.18),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.6)),
                ),
                child: const Icon(
                  Icons.exit_to_app_rounded,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ),
          ],

          const SizedBox(width: 8),

          InkWell(
            onTap: () => openGiftBox(),
            borderRadius: BorderRadius.circular(25),
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [champagneGold, pureGold, antiqueGold],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: pureGold.withOpacity(0.5),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: const Icon(
                Icons.card_giftcard_rounded,
                color: luxuryVoid,
                size: 24,
              ),
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
        backgroundColor: luxuryVoid,
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF06020F),
                    Color(0xFF1A0B3B),
                    Color(0xFF0C051F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned.fill(
              child: CustomPaint(
                painter: _LuxuryAuraPainter(),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildLuxuryHeader(),

                  if (activeGiftBanner != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [antiqueGold, champagneGold, antiqueGold],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: pureGold.withOpacity(0.45),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            color: luxuryVoid,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              activeGiftBanner!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: luxuryVoid,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (loading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: pureGold),
                      ),
                    )
                  else if (errorMessage != null)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.wifi_off_rounded,
                                color: pureGold,
                                size: 42,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pureGold,
                                  foregroundColor: luxuryVoid,
                                ),
                                onPressed: loadRoomData,
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('إعادة المحاولة'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else ...[
                    _buildSeatsGrid(),
                    _buildTabsAndFeed(),
                    _buildBottomActionBar(),
                  ],
                ],
              ),
            ),

            if (busy)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  color: pureGold,
                  backgroundColor: luxuryObsidian,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
class _LuxuryAuraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..style = PaintingStyle.fill;
    final rng = math.Random(99);

    for (int i = 0; i < 55; i++) {
      final dx = rng.nextDouble() * size.width;
      final dy = rng.nextDouble() * (size.height * 0.7);
      final radius = 0.7 + rng.nextDouble() * 1.7;
      final opacity = 0.14 + rng.nextDouble() * 0.5;

      starPaint.color = (i % 3 == 0
              ? const Color(0xFFFFF0B3)
              : Colors.white)
          .withOpacity(opacity);
      canvas.drawCircle(Offset(dx, dy), radius, starPaint);
    }

    final topGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFC93C).withOpacity(0.11),
          const Color(0xFF7C4DFF).withOpacity(0.14),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.5, size.height * 0.24),
          radius: size.width * 0.62,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.24),
      size.width * 0.62,
      topGlow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
          
