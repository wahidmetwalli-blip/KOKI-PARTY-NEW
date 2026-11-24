import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../services/auth_session.dart';

class LuxuryCreateRoomScreen extends StatefulWidget {
  const LuxuryCreateRoomScreen({super.key});

  @override
  State<LuxuryCreateRoomScreen> createState() => _LuxuryCreateRoomScreenState();
}

class _LuxuryCreateRoomScreenState extends State<LuxuryCreateRoomScreen> {
  static const String apiUrl = 'https://koki-party-new.onrender.com';

  // لوحة ألوان KOKI PARTY الفاخرة
  static const Color luxuryVoid = Color(0xFF070312);
  static const Color luxuryObsidian = Color(0xFF130829);
  static const Color luxuryPanel = Color(0xFF1E0D40);
  static const Color luxurySurface = Color(0xFF2B135C);
  static const Color champagneGold = Color(0xFFFFF0B3);
  static const Color pureGold = Color(0xFFFFC93C);
  static const Color antiqueGold = Color(0xFFB87914);
  static const Color royalAmethyst = Color(0xFF9C5CFF);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _announcementController = TextEditingController();

  int _seatsCount = 8;
  bool _isVip = false;
  String _selectedCountry = 'EG';
  bool _submitting = false;
  String? _errorText;

  Map<String, String> get headers {
    final token = AuthSession.accessToken;
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  @override
  void dispose() {
    _titleController.dispose();
    _announcementController.dispose();
    super.dispose();
  }

  Future<void> _submitRoom() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = 'يرجى إدخال عنوان الغرفة أولًا.');
      return;
    }

    setState(() {
      _submitting = true;
      _errorText = null;
    });

    final client = HttpClient();
    try {
      final uri = Uri.parse('$apiUrl/api/rooms');
      final request = await client.openUrl('POST', uri);
      headers.forEach((key, value) => request.headers.set(key, value));

      final payload = <String, dynamic>{
        'title': title,
        'seatsCount': _seatsCount,
        'maxSeats': _seatsCount,
        'isVip': _isVip,
        'vipLevel': _isVip ? 1 : 0,
        'country': _selectedCountry,
        if (_announcementController.text.trim().isNotEmpty)
          'announcement': _announcementController.text.trim(),
      };

      request.write(jsonEncode(payload));
      final response = await request.close();
      final responseText = await response.transform(utf8.decoder).join();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('تعذر إنشاء الغرفة (${response.statusCode}): $responseText');
      }

      Map<String, dynamic> createdRoom = {
        ...payload,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      if (responseText.isNotEmpty) {
        final decoded = jsonDecode(responseText);
        if (decoded is Map<String, dynamic>) {
          final inner = decoded['data'] ?? decoded['room'] ?? decoded;
          if (inner is Map) {
            createdRoom = {
              ...createdRoom,
              ...Map<String, dynamic>.from(inner),
            };
          }
        }
      }

      if (!mounted) return;
      Navigator.of(context).pop(createdRoom);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _errorText = e.toString();
      });
    } finally {
      client.close();
    }
  }
    Widget _buildCountryChip(String label, String code) {
    final selected = _selectedCountry == code;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedCountry = code),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [champagneGold, pureGold, antiqueGold],
                  )
                : null,
            color: selected ? null : luxuryPanel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? champagneGold : pureGold.withOpacity(0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? luxuryVoid : Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSeatChip(int seats) {
    final selected = _seatsCount == seats;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _seatsCount = seats),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? royalAmethyst.withOpacity(0.35) : luxuryPanel,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? champagneGold : pureGold.withOpacity(0.4),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '$seats مقاعد',
            style: TextStyle(
              color: selected ? champagneGold : Colors.white70,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: luxuryVoid,
        appBar: AppBar(
          backgroundColor: luxuryObsidian,
          foregroundColor: champagneGold,
          elevation: 0,
          title: const Text(
            'إنشاء صالون صوتي جديد',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [luxurySurface, luxuryPanel],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: pureGold.withOpacity(0.55)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'عنوان الغرفة',
                      style: TextStyle(
                        color: champagneGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'مثال: سهرات الملوك - KOKI PARTY',
                        hintStyle: const TextStyle(color: Colors.white38),
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
                    const SizedBox(height: 16),
                    const Text(
                      'إعلان الغرفة (اختياري)',
                      style: TextStyle(
                        color: champagneGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _announcementController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'اكتب ترحيبًا أو قوانين الصالون...',
                        hintStyle: const TextStyle(color: Colors.white38),
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
                    const SizedBox(height: 18),
                    const Text(
                      'الدولة / المنطقة',
                      style: TextStyle(
                        color: champagneGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildCountryChip('مصر', 'EG'),
                        _buildCountryChip('اليمن', 'YE'),
                        _buildCountryChip('عام', 'ALL'),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'عدد المقاعد الصوتية',
                      style: TextStyle(
                        color: champagneGold,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildSeatChip(6),
                        _buildSeatChip(8),
                        _buildSeatChip(12),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: luxuryObsidian.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: pureGold.withOpacity(0.4)),
                      ),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: luxuryVoid,
                        activeTrackColor: pureGold,
                        title: const Text(
                          'غرفة VIP ملكية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: const Text(
                          'إبراز الغرفة في تصنيف كبار الشخصيات',
                          style: TextStyle(color: Colors.white60, fontSize: 11.5),
                        ),
                        value: _isVip,
                        onChanged: (val) => setState(() => _isVip = val),
                      ),
                    ),
                  ],
                ),
              ),
              if (_errorText != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.5)),
                  ),
                  child: Text(
                    _errorText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pureGold,
                    foregroundColor: luxuryVoid,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _submitting ? null : _submitRoom,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: luxuryVoid,
                          ),
                        )
                      : const Text(
                          'إنشاء الغرفة الآن',
                          style: TextStyle(
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
  }
}
