
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'home_screen.dart';

class AuthSession {
  static String? accessToken;
  static Map<String, dynamic>? user;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const Color bg = Color(0xFF090711);
  static const Color panel = Color(0xFF191529);
  static const Color gold = Color(0xFFFFD36A);
  static const Color purple = Color(0xFF8957F5);

  static const String apiUrl =
      'https://koki-party-new.onrender.com/api/auth/login';

  final TextEditingController emailController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final identifier = emailController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      showMessage('اكتب البريد أو رقم الهاتف وكلمة المرور.');
      return;
    }

    setState(() => isLoading = true);

    HttpClient? client;

    try {
      client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 20);

      final request = await client.postUrl(Uri.parse(apiUrl));

      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({
        'identifier': identifier,
        'password': password,
      }));

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );

      final responseText = await response
          .transform(utf8.decoder)
          .join();

      final dynamic decoded = jsonDecode(responseText);

      if (response.statusCode == 200 &&
          decoded is Map<String, dynamic> &&
          decoded['access_token'] != null) {
        AuthSession.accessToken =
            decoded['access_token'].toString();

        AuthSession.user =
            decoded['user'] is Map<String, dynamic>
                ? decoded['user']
                : null;

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      } else {
        String message = 'بيانات الدخول غير صحيحة.';

        if (decoded is Map && decoded['message'] != null) {
          final serverMessage = decoded['message'];

          if (serverMessage is String) {
            message = serverMessage;
          } else if (serverMessage is List) {
            message = serverMessage.join('\n');
          }
        }

        showMessage(message);
      }
    } on SocketException {
      showMessage('تعذر الاتصال بالسيرفر. حاول مرة تانية.');
    } on FormatException {
      showMessage('السيرفر أرسل استجابة غير مفهومة.');
    } catch (e) {
      showMessage('حصل خطأ أثناء تسجيل الدخول.');
    } finally {
      client?.close(force: true);

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF38204F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.45),
              radius: 1.1,
              colors: [
                purple.withValues(alpha: 0.22),
                bg,
                const Color(0xFF05040A),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: panel,
                        border: Border.all(
                          color: gold.withValues(alpha: 0.55),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: gold.withValues(alpha: 0.2),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium,
                        color: gold,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'KOKI PARTY',
                      style: TextStyle(
                        color: gold,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'THE ROYAL WORLD',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        letterSpacing: 3,
                      ),
                    ),
                    const SizedBox(height: 40),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          color: gold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'البريد الإلكتروني أو رقم الهاتف',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: gold,
                        ),
                        filled: true,
                        fillColor: panel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: purple.withValues(alpha: 0.25),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      obscureText: hidePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'كلمة المرور',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: gold,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              hidePassword = !hidePassword;
                            });
                          },
                          icon: Icon(
                            hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: gold,
                          ),
                        ),
                        filled: true,
                        fillColor: panel,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide(
                            color: purple.withValues(alpha: 0.25),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(color: gold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: gold,
                          foregroundColor: bg,
                          disabledBackgroundColor:
                              gold.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: bg,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text(
                                'دخول إلى KOKI PARTY',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'THE ROYAL WORLD 👑',
                      style: TextStyle(
                        color: gold,
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
