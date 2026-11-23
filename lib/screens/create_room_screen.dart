import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../services/auth_session.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() =>
      _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  static const String apiUrl =
      'https://koki-party-new.onrender.com/api/rooms';

  static const Color bg = Color(0xFF090711);
  static const Color panel = Color(0xFF191529);
  static const Color gold = Color(0xFFFFD36A);
  static const Color purple = Color(0xFF8957F5);

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  bool isCreating = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> createRoom() async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final token = AuthSession.accessToken;

    if (name.isEmpty) {
      showMessage('اكتب اسم الغرفة الأول');
      return;
    }

    if (token == null || token.isEmpty) {
      showMessage('سجّل دخولك الأول قبل إنشاء الغرفة');
      return;
    }

    setState(() => isCreating = true);

    HttpClient? client;

    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 25);

      final request =
          await client.postUrl(Uri.parse(apiUrl));

      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json',
      );

      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $token',
      );

      request.write(jsonEncode({
        'name': name,
        'description': description,
      }));

      final response = await request.close().timeout(
        const Duration(seconds: 35),
      );

      final responseText =
          await response.transform(utf8.decoder).join();

      if (response.statusCode == 201 ||
          response.statusCode == 200) {
        if (!mounted) return;

        Navigator.pop(context, true);
        return;
      }

      String message = 'فشل إنشاء الغرفة';

      try {
        final decoded = jsonDecode(responseText);
        if (decoded is Map && decoded['message'] != null) {
          message = decoded['message'].toString();
        }
      } catch (_) {}

      showMessage(message);
    } catch (e) {
      showMessage('حصل خطأ في الاتصال بالسيرفر. حاول تاني.');
    } finally {
      client?.close(force: true);

      if (mounted) {
        setState(() => isCreating = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: panel,
          foregroundColor: gold,
          title: const Text('إنشاء غرفة جديدة'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.meeting_room,
                color: gold,
                size: 65,
              ),
              const SizedBox(height: 20),
              buildField(
                controller: nameController,
                label: 'اسم الغرفة',
                hint: 'مثال: غرفة الملوك',
              ),
              const SizedBox(height: 15),
              buildField(
                controller: descriptionController,
                label: 'وصف الغرفة',
                hint: 'اكتب وصف الغرفة',
                maxLines: 3,
              ),
