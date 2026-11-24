import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../services/auth_session.dart';
import 'home_screen.dart';

class LuxuryAuthScreen extends StatefulWidget {
  const LuxuryAuthScreen({super.key});

  @override
  State<LuxuryAuthScreen> createState() => _LuxuryAuthScreenState();
}

class _LuxuryAuthScreenState extends State<LuxuryAuthScreen> {
  static const String apiUrl = 'https://koki-party-new.onrender.com';

  // لوحة ألوان KOKI PARTY الفاخرة
  static const Color luxuryVoid = Color(0xFF070312);
  static const Color luxuryObsidian = Color(0xFF130829);
  static const Color luxuryPanel = Color(0xFF1E0D40);
  static const Color luxurySurface = Color(0xFF2B135C);
  static const Color champagneGold = Color(0xFFFFF0B3);
  static const Color pureGold = Color(0xFFFFC93C);
  static const Color antiqueGold = Color(0xFFB87914);

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _submitting = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال بيانات الحساب وكلمة المرور.';
      });
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    final client = HttpClient();
    try {
      final endpoint = _isRegisterMode ? '/api/auth/register' : '/api/auth/login';
      final uri = Uri.parse('$apiUrl$endpoint');
      final request = await client.openUrl('POST', uri);
      request.headers.set('Accept', 'application/json');
      request.headers.set('Content-Type', 'application/json');

      final body = <String, dynamic>{
        'identifier': identifier,
        'password': password,
      };
      request.write(jsonEncode(body));

      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('تعذر إتمام العملية (${response.statusCode}): $responseText');
      }

      if (responseText.isNotEmpty) {
        final decoded = jsonDecode(responseText);
        if (decoded is Map) {
          final data = decoded['data'];
          final token = decoded['access_token'] ??
              decoded['accessToken'] ??
              decoded['token'] ??
              (data is Map
                  ? data['access_token'] ?? data['accessToken'] ?? data['token']
                  : null);
          if (token != null && token.toString().isNotEmpty) {
            AuthSession.accessToken = token.toString();
          }

          final userObj = decoded['user'] ??
              (data is Map ? data['user'] : null);
          if (userObj is Map) {
            AuthSession.user = Map<String, dynamic>.from(userObj);
          }
        }
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LuxuryHomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorMessage = e.toString();
      });
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: luxuryVoid,
        body: Container(
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
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [luxurySurface, luxuryPanel],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: pureGold.withOpacity(0.6), width: 1.3),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [champagneGold, pureGold, antiqueGold],
                          ),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: luxuryVoid,
                          size: 36,
                        ),
                      ),
                      const Text(
                        'KOKI PARTY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: champagneGold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isRegisterMode
                            ? 'إنشاء حساب جديد في العالم الملكي'
                            : 'تسجيل الدخول إلى صالونات KOKI PARTY',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 12.5),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _identifierController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'البريد الإلكتروني أو اسم المستخدم',
                          labelStyle: const TextStyle(color: champagneGold),
                          filled: true,
                          fillColor: luxuryObsidian,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: pureGold.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: champagneGold, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          labelStyle: const TextStyle(color: champagneGold),
                          filled: true,
                          fillColor: luxuryObsidian,
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: pureGold,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: pureGold.withOpacity(0.4)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: champagneGold, width: 1.5),
                          ),
                        ),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pureGold,
                            foregroundColor: luxuryVoid,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _submitting ? null : _submitAuth,
                          child: _submitting
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: luxuryVoid,
                                  ),
                                )
                              : Text(
                                  _isRegisterMode ? 'إنشاء الحساب' : 'دخول',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () => setState(() {
                          _isRegisterMode = !_isRegisterMode;
                          _errorMessage = null;
                        }),
                        child: Text(
                          _isRegisterMode
                              ? 'لديك حساب بالفعل؟ سجل الدخول'
                              : 'ليس لديك حساب؟ أنشئ حسابًا جديدًا',
                          style: const TextStyle(color: champagneGold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
