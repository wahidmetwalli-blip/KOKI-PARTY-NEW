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
  bool giftsLoading = false;

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

  // الهدايا بتيجي من السيرفر، مش من أسعار ثابتة داخل التطبيق.
  List<Map<String, dynamic>> _gifts = [];

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
    loadGifts();
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  Future<void> loadGifts() async {
    if (giftsLoading) return;

    if (mounted) {
      setState(() {
        giftsLoading = true;
      });
    }

    try {
      final response = await apiRequest(
        'GET',
        '/api/gifts',
      );

      final data = response['data'];

      if (data is! List) {
        throw Exception('قائمة الهدايا غير صحيحة');
      }

      if (!mounted) return;

      setState(() {
        _gifts = data
            .map<Map<String, dynamic>>(
              (gift) => Map<String, dynamic>.from(gift),
            )
            .toList();
      });
    } catch (e) {
      if (mounted) {
        showMessage('تعذر تحميل الهدايا: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          giftsLoading = false;
        });
      }
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
        apiRequest(
          'GET',
          '/api/rooms/${widget.roomId}',
        ),
        apiRequest(
          'GET',
          '/api/rooms/${widget.roomId}/seats',
        ),
      ]);

      if (!mounted) return;

      final loadedSeats =
          List<dynamic>.from(results[1]);

      final mySeat = loadedSeats.where(
        (seat) =>
            seat['userId']?.toString() == currentUserId,
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
    setState(() => busy = true);

    try {
      await apiRequest(
        'POST',
        '/api/rooms/${widget.roomId}/seats/$seatNumber/take',
      );
      await loadRoomData();
      showMessage('تم حجز المقعد بنجاح 🎤');
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
      showMessage('تم مغادرة المقعد');
    } catch (e) {
      showMessage('تعذر مغادرة المقعد: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> toggleMic() async {
    final mySeats = seats.where(
      (seat) =>
          seat['userId']?.toString() == currentUserId,
    ).toList();

    if (mySeats.isEmpty) {
      showMessage('احجز مقعد الأول علشان تفتح المايك');
      return;
    }

    final seatNumber =
        (mySeats.first['seatNumber'] as num).toInt();
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
      showMessage('تم تحديث عدد المقاعد');
    } catch (e) {
      showMessage('تعذر تحديث المقاعد: $e');
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
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openSeatSettings() {
    if (!isRoomOwner) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: purple,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'إعدادات مقاعد الغرفة',
                  style: TextStyle(
                    color: gold,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                ...[8, 10, 12, 15, 20].map(
                  (count) => ListTile(
                    title: Text(
                      '$count مقعد',
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: count == maxSeats
                        ? const Icon(
                            Icons.check_circle,
                            color: gold,
                          )
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
    Future<void> _sendGiftToSeat(
    Map<String, dynamic> gift,
    int seatNumber,
    String hostUserId,
  ) async {
    if (busy) return;

    final senderId = currentUserId;

    if (senderId == null || senderId.isEmpty) {
      showMessage('سجل الدخول الأول');
      return;
    }

    final giftId = gift['id']?.toString();
    final giftName = gift['name']?.toString() ?? 'هدية';
    final rawEmoji = gift['emoji']?.toString();
    final giftEmoji =
        rawEmoji == null || rawEmoji.isEmpty ? '🎁' : rawEmoji;
    final giftPrice = gift['coinPrice']?.toString() ?? '0';

    if (giftId == null || giftId.isEmpty) {
      showMessage('الهدية غير صالحة');
      return;
    }

    if (hostUserId.isEmpty || hostUserId == senderId) {
      showMessage('اختار مضيف تاني لإرسال الهدية');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: purple,
          title: const Text(
            'تأكيد إرسال الهدية',
            style: TextStyle(color: gold),
          ),
          content: Text(
            'إرسال $giftEmoji $giftName مقابل $giftPrice عملة؟',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: const Text('إرسال'),
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

      final latestSeats =
          List<dynamic>.from(latestSeatsResponse);

      final recipientStillSeated = latestSeats.any(
        (seat) =>
            seat['seatNumber']?.toString() ==
                seatNumber.toString() &&
            seat['userId']?.toString() == hostUserId,
      );

      if (!recipientStillSeated) {
        throw Exception('المضيف غادر المقعد، اختار مقعد تاني');
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

      setState(() {
        activeGiftBanner = '$giftEmoji $giftName';
      });

      showMessage('تم إرسال الهدية بنجاح 🎁');
      await loadRoomData();
    } catch (e) {
      showMessage('تعذر إرسال الهدية: $e');
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  void openGiftBox() {
    if (giftsLoading) {
      showMessage('جاري تحميل الهدايا...');
      return;
    }

    if (_gifts.isEmpty) {
      showMessage('مفيش هدايا متاحة حالياً');
      loadGifts();
      return;
    }

    final occupiedSeats = seats.where((seat) {
      final userId = seat['userId']?.toString();
      return userId != null &&
          userId.isNotEmpty &&
          userId != currentUserId;
    }).toList();

    if (occupiedSeats.isEmpty) {
      showMessage('لازم يكون فيه مضيف على مقعد لإرسال هدية');
      return;
    }

    int selectedGiftIndex = 0;
    int? selectedSeatNumber;

    final firstSeat = occupiedSeats.first;
    selectedSeatNumber =
        (firstSeat['seatNumber'] as num?)?.toInt();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: purple,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (_gifts.isEmpty) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'مفيش هدايا متاحة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          await loadGifts();
                          if (mounted) {
                            setSheetState(() {});
                          }
                        },
                        child: const Text('إعادة التحميل'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (selectedGiftIndex >= _gifts.length) {
              selectedGiftIndex = 0;
            }

            final selectedGift = _gifts[selectedGiftIndex];

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '🎁 متجر الهدايا الملكي',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: gold,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'اختار المضيف',
                        style: TextStyle(color: Colors.white),
                      ),
                      ...occupiedSeats.map((seat) {
                        final number =
                            (seat['seatNumber'] as num?)?.toInt();
                        final userId =
                            seat['userId']?.toString() ?? '';

                        return RadioListTile<int>(
                          value: number ?? -1,
                          groupValue: selectedSeatNumber,
                          activeColor: gold,
                          title: Text(
                            'المقعد ${number ?? '-'} · ${seat['userName'] ?? userId}',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onChanged: (value) {
                            setSheetState(() {
                              selectedSeatNumber = value;
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 12),
                      const Text(
                        'اختار الهدية',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        itemCount: _gifts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.9,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (context, index) {
                          final gift = _gifts[index];
                          final emoji =
                              gift['emoji']?.toString() ?? '🎁';
                          final name =
                              gift['name']?.toString() ?? 'هدية';
                          final price =
                              gift['coinPrice']?.toString() ?? '0';
                          final selected =
                              selectedGiftIndex == index;

                          return InkWell(
                            onTap: () {
                              setSheetState(() {
                                selectedGiftIndex = index;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.deepPurple
                                    : Colors.black26,
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected ? gold : Colors.white24,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Text(
                                    emoji,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '$price عملة',
                                    style: const TextStyle(
                                      color: gold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: selectedSeatNumber == null || busy
                            ? null
                            : () {
                                final selectedSeat = occupiedSeats
                                    .where(
                                      (seat) =>
                                          (seat['seatNumber'] as num?)
                                              ?.toInt() ==
                                          selectedSeatNumber,
                                    )
                                    .toList();

                                if (selectedSeat.isEmpty) {
                                  showMessage('المقعد غير متاح');
                                  return;
                                }

                                final hostUserId = selectedSeat
                                    .first['userId']
                                    .toString();

                                Navigator.pop(sheetContext);

                                _sendGiftToSeat(
                                  Map<String, dynamic>.from(
                                      selectedGift),
                                  selectedSeatNumber!,
                                  hostUserId,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('إرسال الهدية 🎁'),
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
    void sendMessage() {
    final message = _chatController.text.trim();

    if (message.isEmpty) return;

    if (!mounted) return;

    setState(() {
      _messages.add({
        'user': AuthSession.user?['name']?.toString() ?? 'مستخدم',
        'text': message,
      });

      _chatController.clear();
    });
  }

  Widget buildSeat(int seatNumber) {
    final matchingSeats = seats.where(
      (seat) =>
          (seat['seatNumber'] as num?)?.toInt() == seatNumber,
    ).toList();

    final seat = matchingSeats.isEmpty ? null : matchingSeats.first;

    final userId = seat?['userId']?.toString();
    final isOccupied = userId != null && userId.isNotEmpty;
    final isMySeat = isOccupied && userId == currentUserId;
    final isMuted = seat?['isMuted'] == true;

    final userName =
        seat?['userName']?.toString() ?? 'مستخدم';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (busy) return;

        if (!isOccupied) {
          takeSeat(seatNumber);
        } else if (isMySeat) {
          leaveSeat();
        } else {
          showMessage('المقعد محجوز بواسطة $userName');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isOccupied
              ? const Color(0xFF35204F)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isMySeat ? gold : Colors.white24,
            width: isMySeat ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: isOccupied
                      ? Colors.deepPurple
                      : Colors.white12,
                  child: Icon(
                    isOccupied
                        ? Icons.person
                        : Icons.mic_none,
                    color: isOccupied ? gold : Colors.white54,
                    size: 25,
                  ),
                ),
                if (isOccupied && isMuted)
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.red,
                    child: Icon(
                      Icons.mic_off,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              isOccupied ? userName : 'مقعد $seatNumber',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              isOccupied
                  ? (isMySeat ? 'مقعدك' : 'متحدث')
                  : 'متاح',
              style: TextStyle(
                color: isOccupied ? gold : Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRoomHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.roomTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: gold,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'الغرفة رقم ${widget.roomId}',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (isRoomOwner)
          IconButton(
            onPressed: openSeatSettings,
            tooltip: 'إعدادات المقاعد',
            icon: const Icon(
              Icons.settings,
              color: gold,
            ),
          ),
        IconButton(
          onPressed: loadRoomData,
          tooltip: 'تحديث الغرفة',
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
    @override
  Widget build(BuildContext context) {
    final mySeat = seats.where(
      (seat) =>
          seat['userId']?.toString() == currentUserId,
    ).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: purple,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF24103D),
                Color(0xFF10091D),
                Color(0xFF080510),
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
                                color: Colors.redAccent,
                                size: 45,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 15),
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
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: buildRoomHeader(),
                          ),

                          if (activeGiftBanner != null)
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: gold),
                              ),
                              child: Text(
                                '🎉 تم إرسال $activeGiftBanner',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                          Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white12,
                              ),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.deepPurple,
                                  child: Icon(
                                    Icons.workspace_premium,
                                    color: gold,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.hostName,
                                        style: const TextStyle(
                                          color: gold,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'مرحباً بكم في الغرفة الملكية 👑',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.graphic_eq,
                                  color: gold,
                                  size: 27,
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 5,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  '🎙️ مقاعد المتحدثين',
                                  style: TextStyle(
                                    color: gold,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${seats.where((s) => s['userId'] != null).length}/$maxSeats',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: GridView.builder(
                                itemCount: maxSeats,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.82,
                                  crossAxisSpacing: 9,
                                  mainAxisSpacing: 9,
                                ),
                                itemBuilder: (context, index) {
                                  return buildSeat(index + 1);
                                },
                              ),
                            ),
                          ),

                          Container(
                            height: 145,
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: Colors.white12,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '💬 دردشة الغرفة',
                                  style: TextStyle(
                                    color: gold,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 7),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _messages.length,
                                    itemBuilder: (context, index) {
                                      final message = _messages[index];

                                      return Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text:
                                                    '${message['user']}: ',
                                                style: const TextStyle(
                                                  color: gold,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              TextSpan(
                                                text: message['text'] ?? '',
                                                style: const TextStyle(
                                                  color: Colors.white,
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
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              12,
                              8,
                              12,
                              12,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'اكتب رسالة...',
                                      hintStyle: const TextStyle(
                                        color: Colors.white54,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white10,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 10,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onSubmitted: (_) => sendMessage(),
                                  ),
                                ),
                                IconButton(
                                  onPressed: sendMessage,
                                  icon: const Icon(
                                    Icons.send,
                                    color: gold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: toggleMic,
                                  icon: Icon(
                                    isMicMuted
                                        ? Icons.mic_off
                                        : Icons.mic,
                                    color: isMicMuted
                                        ? Colors.redAccent
                                        : gold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: openGiftBox,
                                  icon: const Icon(
                                    Icons.card_giftcard,
                                    color: gold,
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
