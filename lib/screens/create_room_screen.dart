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

      showMessage(
        'خطأ من السيرفر (${response.statusCode}): $message',
      );
    } catch (e) {
      showMessage('تفاصيل الخطأ: $e');
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
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 8),
      ),
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

              const SizedBox(height: 25),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: gold.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: gold,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'الغرفة هتبدأ بـ 8 مقاعد، وتقدر تغيّر عدد المقاعد بعد الإنشاء من إعدادات الغرفة.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: isCreating ? null : createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: bg,
                  disabledBackgroundColor:
                      gold.withValues(alpha: 0.5),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isCreating
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: bg,
                        ),
                      )
                    : const Text(
                        'إنشاء الغرفة',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.white38,
            ),
            filled: true,
            fillColor: panel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Colors.white12,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: gold),
            ),
          ),
        ),
      ],
    );
  }
}
