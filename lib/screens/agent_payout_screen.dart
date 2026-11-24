import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import '../services/auth_session.dart';

class AgentPayoutScreen extends StatefulWidget {
  const AgentPayoutScreen({super.key});

  @override
  State<AgentPayoutScreen> createState() =>
      _AgentPayoutScreenState();
}

class _AgentPayoutScreenState extends State<AgentPayoutScreen> {
  static const String baseUrl =
      'https://koki-party-new.onrender.com/api/agents';

  final amountController = TextEditingController();

  Map<String, dynamic>? summary;
  List<dynamic> payouts = [];

  bool loading = true;
  bool submitting = false;
  String? error;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<dynamic> apiCall(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final token = AuthSession.accessToken;

    if (token == null || token.isEmpty) {
      throw Exception('سجّل الدخول من جديد.');
    }

    final client = HttpClient();

    try {
      final request = await client.openUrl(
        method,
        Uri.parse('$baseUrl$path'),
      );

      request.headers.set(
        HttpHeaders.authorizationHeader,
        'Bearer $token',
      );
      request.headers.contentType = ContentType.json;

      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );

      final responseText =
          await response.transform(utf8.decoder).join();

      final data = responseText.isEmpty
          ? {}
          : jsonDecode(responseText);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        final message = data is Map
            ? data['message']?.toString()
            : null;

        throw Exception(
          message ?? 'تعذر تنفيذ الطلب.',
        );
      }

      return data;
    } finally {
      client.close(force: true);
    }
  }

  Future<void> loadData() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final results = await Future.wait([
        apiCall('/me/financial-summary'),
        apiCall('/me/payouts'),
      ]);

      if (!mounted) return;

      setState(() {
        summary = Map<String, dynamic>.from(results[0]);
        payouts = results[1] is List ? results[1] : [];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        loading = false;
      });
    }
  }

  String money(dynamic cents) {
    final value = int.tryParse(cents?.toString() ?? '') ?? 0;
    return '\$${(value / 100).toStringAsFixed(2)} USD';
  }

  Future<void> requestPayout() async {
    final value = amountController.text.trim();

    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
      showMessage('اكتب مبلغ صحيح بحد أقصى منزلتين عشريتين.');
      return;
    }

    final dollars = double.tryParse(value);

    if (dollars == null || dollars <= 0) {
      showMessage('المبلغ لازم يكون أكبر من صفر.');
      return;
    }

    final cents = (dollars * 100).round();

    setState(() => submitting = true);

    try {
      await apiCall(
        '/me/payouts',
        method: 'POST',
        body: {'amount': cents.toString()},
      );

      amountController.clear();

      showMessage('تم إرسال طلب السحب للمراجعة.');
      await loadData();
    } catch (e) {
      showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => submitting = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String statusName(String? status) {
    switch (status) {
      case 'PENDING':
        return 'قيد المراجعة';
      case 'APPROVED':
        return 'تمت الموافقة';
      case 'REJECTED':
        return 'مرفوض';
      case 'PAID':
        return 'تم الدفع';
      case 'CANCELLED':
        return 'ملغي';
      default:
        return status ?? 'غير معروف';
    }
  }

  Widget infoCard(String title, dynamic value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191529),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8D7540)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white60),
          ),
          const SizedBox(height: 8),
          Text(
            money(value),
            style: const TextStyle(
              color: Color(0xFFFFD36A),
              fontSize: 21,
              fontWeight: FontWeight.bold,
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
        backgroundColor: const Color(0xFF090711),
        appBar: AppBar(
          title: const Text('أرباح وكيل الشحن'),
          backgroundColor: const Color(0xFF191529),
          foregroundColor: const Color(0xFFFFD36A),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFD36A),
                ),
              )
            : error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: loadData,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadData,
                    child: ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        infoCard(
                          'الرصيد المتاح للسحب',
                          summary?['availableBalance'],
                        ),
                        infoCard(
                          'طلبات قيد المراجعة',
                          summary?['pendingPayouts'],
                        ),
                        infoCard(
                          'طلبات تمت الموافقة عليها',
                          summary?['approvedPayouts'],
                        ),
                        infoCard(
                          'إجمالي ما تم دفعه',
                          summary?['paidPayouts'],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'طلب سحب جديد',
                          style: TextStyle(
                            color: Color(0xFFFFD36A),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: amountController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'المبلغ بالدولار مثل 10.00',
                            hintStyle:
                                const TextStyle(color: Colors.white38),
                            filled: true,
                            fillColor: const Color(0xFF191529),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                submitting ? null : requestPayout,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFFFD36A),
                              foregroundColor:
                                  const Color(0xFF090711),
                            ),
                            child: submitting
                                ? const CircularProgressIndicator()
                                : const Text('إرسال طلب السحب'),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'سجل طلبات السحب',
                          style: TextStyle(
                            color: Color(0xFFFFD36A),
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (payouts.isEmpty)
                          const Text(
                            'لا توجد طلبات سحب حتى الآن.',
                            style: TextStyle(color: Colors.white60),
                          ),
                        ...payouts.map((item) {
                          final payout =
                              Map<String, dynamic>.from(item);

                          return Card(
                            color: const Color(0xFF191529),
                            child: ListTile(
                              title: Text(
                                money(payout['amount']),
                                style: const TextStyle(
                                  color: Color(0xFFFFD36A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                statusName(
                                  payout['status']?.toString(),
                                ),
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
      ),
    );
  }
}
