
import 'package:flutter/material.dart';

const Color roomBg = Color(0xFF090711);
const Color roomPanel = Color(0xFF191529);
const Color roomGold = Color(0xFFD8B45A);
const Color roomPurple = Color(0xFF8957F5);

class CreateRoomScreen extends StatefulWidget {
  const CreateRoomScreen({super.key});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPrivate = false;
  bool hasPassword = false;
  bool allowRequests = true;
  bool isCreating = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value),
        backgroundColor: roomPanel,
      ),
    );
  }

  void createRoom() {
    if (nameController.text.trim().isEmpty) {
      showMessage('اكتب اسم الروم الأول');
      return;
    }

    if (hasPassword && passwordController.text.length < 4) {
      showMessage('كلمة المرور لازم تكون 4 أرقام أو حروف على الأقل');
      return;
    }

    showMessage('بيانات الروم جاهزة للربط بنظام إنشاء الغرف');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: roomBg,
        appBar: AppBar(
          backgroundColor: roomBg,
          foregroundColor: roomGold,
          title: const Text(
            'إنشاء روم جديد',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            coverSection(),
            const SizedBox(height: 24),
            sectionTitle('بيانات الروم'),
            inputField(
              controller: nameController,
              label: 'اسم الروم',
              hint: 'مثال: مملكة KOKI',
              icon: Icons.meeting_room,
            ),
            const SizedBox(height: 14),
            inputField(
              controller: descriptionController,
              label: 'وصف الروم',
              hint: 'اكتب وصف بسيط عن الروم',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 25),
            sectionTitle('خصوصية الروم'),
            settingTile(
              icon: Icons.lock,
              title: 'روم خاص',
              subtitle: 'الدخول للروم يكون حسب إعدادات الخصوصية',
              value: isPrivate,
              onChanged: (value) {
                setState(() => isPrivate = value);
              },
            ),
            settingTile(
              icon: Icons.password,
              title: 'حماية بكلمة مرور',
              subtitle: 'اطلب كلمة مرور قبل دخول الروم',
              value: hasPassword,
              onChanged: (value) {
                setState(() => hasPassword = value);
              },
            ),
            if (hasPassword) ...[
              const SizedBox(height: 10),
              inputField(
                controller: passwordController,
                label: 'كلمة مرور الروم',
                hint: '4 أحرف أو أرقام على الأقل',
                icon: Icons.key,
              ),
            ],
            const SizedBox(height: 14),
            settingTile(
              icon: Icons.mic,
              title: 'طلبات الصعود للمايك',
              subtitle: 'السماح للأعضاء بطلب الصعود للمقاعد',
              value: allowRequests,
              onChanged: (value) {
                setState(() => allowRequests = value);
              },
            ),
            const SizedBox(height: 25),
            sectionTitle('المقاعد الصوتية'),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: roomPanel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: roomGold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.groups,
                    color: roomGold,
                    size: 38,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '8 مقاعد صوتية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 13,
                    runSpacing: 13,
                    children: List.generate(
                      8,
                      (index) => Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: roomPurple.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: roomGold),
                        ),
                        child: const Icon(
                          Icons.mic_none,
                          color: roomGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                onPressed: createRoom,
                icon: const Icon(Icons.add_circle),
                label: const Text(
                  'إنشاء الروم',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: roomGold,
                  foregroundColor: roomBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget coverSection() {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: roomPanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: roomGold.withOpacity(0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          showMessage(
            'اختيار صورة من المعرض هنفعّله في خطوة ربط الصور',
          );
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              color: roomGold,
              size: 55,
            ),
            SizedBox(height: 12),
            Text(
              'اختار صورة غلاف الروم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 7),
            Text(
              'تقدر تغيّر الصورة في أي وقت',
              style: TextStyle(color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Text(
        title,
        style: const TextStyle(
          color: roomGold,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: Icon(icon, color: roomGold),
        filled: true,
        fillColor: roomPanel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
      ),
    );
  }

  Widget settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: roomPanel,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeColor: roomGold,
        secondary: Icon(icon, color: roomGold),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ),
    );
  }
}

