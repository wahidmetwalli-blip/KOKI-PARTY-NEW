
import 'package:flutter/material.dart';

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() =>
      _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  static const Color bg = Color(0xFF090711);
  static const Color panel = Color(0xFF191529);
  static const Color gold = Color(0xFFFFD36A);
  static const Color purple = Color(0xFF8957F5);

  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController descriptionController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();

  bool isPrivate = false;
  bool hasPassword = false;
  bool allowRequests = true;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void createRoom() {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتب اسم الغرفة الأول'),
        ),
      );
      return;
    }

    if (hasPassword && passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتب كلمة مرور الغرفة'),
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'name': name,
      'description': descriptionController.text.trim(),
      'owner': 'KOKI USER',
      'isPrivate': isPrivate,
      'hasPassword': hasPassword,
      'password': passwordController.text.trim(),
      'allowRequests': allowRequests,
    });
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
                hint: 'اكتب وصفًا للغرفة',
                maxLines: 3,
              ),
              const SizedBox(height: 18),
              buildSwitch(
                'غرفة خاصة',
                'إظهار أن الغرفة خاصة',
                isPrivate,
                (value) => setState(() => isPrivate = value),
              ),
              buildSwitch(
                'حماية بكلمة مرور',
                'تجربة إعداد كلمة مرور',
                hasPassword,
                (value) => setState(() => hasPassword = value),
              ),
              if (hasPassword) ...[
                const SizedBox(height: 12),
                buildField(
                  controller: passwordController,
                  label: 'كلمة المرور',
                  hint: 'اكتب كلمة المرور',
                ),
              ],
              buildSwitch(
                'السماح بطلب المايك',
                'السماح للأعضاء بطلب الصعود للمقاعد',
                allowRequests,
                (value) =>
                    setState(() => allowRequests = value),
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: createRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: gold,
                  foregroundColor: bg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
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
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: panel,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: BorderSide(color: Colors.white12),
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

  Widget buildSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(13),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: gold,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
