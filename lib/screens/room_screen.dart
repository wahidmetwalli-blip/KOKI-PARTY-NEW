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

      setState(() {
        room = Map<String, dynamic>.from(results[0]);
        seats = List<dynamic>.from(results[1]);
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
